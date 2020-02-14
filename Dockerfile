ARG BITCOIND_VERSION=0.19.0.1

FROM alpine:3.11 AS builder

ARG BITCOIND_VERSION

WORKDIR /bitcoin

RUN set -eux; \
  apkArch="$(apk --print-arch)"; \
  \
  case "$apkArch" in \
    x86) \
      url=https://bitcoincore.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-i686-pc-linux-gnu.tar.gz ;; \
    x86_64) \
      url=https://bitcoin.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-x86_64-linux-gnu.tar.gz ;; \
    armv7) \
      url=https://bitcoincore.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-arm-linux-gnueabihf.tar.gz ;; \
    aarch64) \
      url=https://bitcoincore.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-aarch64-linux-gnu.tar.gz ;; \
    *) \
      echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
  esac; \
  \
  wget -q -O- $url |tar xz -C /bitcoin --strip-components=1


# Start a new, final image.
FROM alpine:3.11 AS final

ARG BUILD_DATE
ARG VCS_REF
ARG BITCOIND_VERSION

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="legacycode/bitcoind" \
  org.label-schema.description="A Docker image based on Alpine Linux ready to run a bitcoin full node!" \
  org.label-schema.usage="https://hub.docker.com/r/legacycode/bitcoind" \
  org.label-schema.url="https://hub.docker.com/r/legacycode/bitcoind" \
  org.label-schema.vcs-url="https://github.com/legacycode/bitcoind-docker" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.version=$BITCOIND_VERSION \
  maintainer="info@legacycode.org"

# Install dependencies and build the binaries.
RUN apk add --no-cache --update \
   boost \
   libevent \
   openssl \
   libzmq

# Add user and group for bitcoin process.
RUN addgroup -S bitcoin \
  && adduser -S bitcoin -G bitcoin \
  && mkdir /home/bitcoin/.bitcoin \
  && chown bitcoin:bitcoin /home/bitcoin/.bitcoin

# Change user.
USER bitcoin

# Define a root volume for data persistence.
VOLUME ["/home/bitcoin/.bitcoin"]

# Copy the binaries from the builder image.
COPY --from=builder /bitcoin/bin/bitcoind /usr/local/bin/bitcoind

# Expose btcd ports (p2p, rpc).
EXPOSE 8333 8332

# Specify the start command and entrypoint as the btcd daemon.
ENTRYPOINT ["bitcoind"]

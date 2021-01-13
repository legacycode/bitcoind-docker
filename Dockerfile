ARG BITCOIND_VERSION=0.20.1

FROM debian:buster-slim AS builder

ARG BITCOIND_VERSION

# Install dependencies and build the binaries.
RUN apt-get update --yes \
  && apt-get install --no-install-recommends --yes \
    ca-certificates=20190110 \
    dirmngr=2.2.12-1+deb10u1 \
    gpg=2.2.12-1+deb10u1 \
    gpg-agent=2.2.12-1+deb10u1 \
    wget=1.20.1-1.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /bitcoin

RUN set -eux; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) \
      url=https://bitcoin.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-x86_64-linux-gnu.tar.gz ;; \
    armhf) \
      url=https://bitcoincore.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-arm-linux-gnueabihf.tar.gz ;; \
    arm64) \
      url=https://bitcoincore.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-aarch64-linux-gnu.tar.gz ;; \
    *) \
      echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
  esac; \
  \
  wget --quiet $url \
  && wget --quiet https://bitcoin.org/bin/bitcoin-core-$BITCOIND_VERSION/SHA256SUMS.asc \
  && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 01EA5486DE18A882D4C2684590C8019E36C2E964 \
  && gpg --verify SHA256SUMS.asc \
  && grep "${url##*/}" SHA256SUMS.asc | sha256sum -c - \
  && mkdir /bitcoind \
  && tar -xzf ./*.tar.gz -C /bitcoin --strip-components=1


# Start a new, final image.
FROM debian:buster-slim AS final

ARG BUILD_DATE
ARG VCS_REF
ARG BITCOIND_VERSION

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="legacycode/bitcoind" \
  org.label-schema.description="A Docker image based on Debian Linux ready to run a bitcoin full node!" \
  org.label-schema.usage="https://hub.docker.com/r/legacycode/bitcoind" \
  org.label-schema.url="https://hub.docker.com/r/legacycode/bitcoind" \
  org.label-schema.vcs-url="https://github.com/legacycode/bitcoind-docker" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.version=$BITCOIND_VERSION \
  maintainer="info@legacycode.org"

# Add user and group for bitcoin process.
RUN useradd -r bitcoin \
  && mkdir -p /home/bitcoin/.bitcoin \
  && chmod 700 /home/bitcoin/.bitcoin \
  && chown -R bitcoin /home/bitcoin/.bitcoin

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

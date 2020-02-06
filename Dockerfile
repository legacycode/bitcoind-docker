ARG BITCOIND_VERSION=v0.19.0.1

FROM alpine:3.10 AS builder

ARG BITCOIND_VERSION

# Install dependencies and build the binaries.
RUN apk add --no-cache --update alpine-sdk \
   autoconf \
   automake \
   boost-dev \
   git \
   libtool \
   libevent-dev \
   openssl-dev \
   zeromq-dev

WORKDIR /bitcoin

RUN git clone https://github.com/bitcoin/bitcoin.git --branch=$BITCOIND_VERSION --depth=1 /bitcoin \
  && ./autogen.sh \
  && ./configure --disable-wallet \
  && make -j4 \
  && make install


# Start a new, final image.
FROM alpine:3.10 AS final

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
COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/bitcoind

# Expose btcd ports (p2p, rpc).
EXPOSE 8333 8332

# Specify the start command and entrypoint as the btcd daemon.
ENTRYPOINT ["bitcoind"]

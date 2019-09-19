FROM alpine:3.10 AS builder

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

RUN git clone https://github.com/bitcoin/bitcoin.git --branch=v0.18.1 /bitcoin \
  && ./autogen.sh \
  && ./configure --disable-wallet \
  && make -j4 \
  && make install


# Start a new, final image.
FROM alpine:3.10 AS final

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

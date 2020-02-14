# Bitcoind Docker Image

![MicroBadger Layers](https://img.shields.io/microbadger/layers/legacycode/bitcoind) ![Docker Pulls](https://img.shields.io/docker/pulls/legacycode/bitcoind) ![Docker Stars](https://img.shields.io/docker/stars/legacycode/bitcoind) ![Codacy grade](https://img.shields.io/codacy/grade/109e2de909e645aebaa73d8b099c72b9) ![CircleCI](https://img.shields.io/circleci/build/github/legacycode/bitcoind-docker)

## Introduction

With Docker you can easily set up _bitcoind_ and create your Bitcoin full node.
The Docker source file of this image is located at [Dockerfile][1].

This documentation focus on running Docker container with _docker-compose.yml_ files. These files are better to read and you can use them as a template. For more information about Docker and Docker compose visit the official [Docker documentation][2].

## Supported tags and architectures

This bitcoind images supports following tags for e.g. Linux, Raspberry, Pine64 etc.:

-   [`latest`](https://github.com/legacycode/bitcoind-docker/blob/latest/Dockerfile) [`v0.19.0.1`](https://github.com/legacycode/bitcoind-docker/blob/v0.19.0.1/Dockerfile) [`v0.19.0`](https://github.com/legacycode/bitcoind-docker/blob/v0.19.0/Dockerfile) [`v0.18.1`](https://github.com/legacycode/bitcoind-docker/blob/v0.18.1/Dockerfile) - stable bitcoind builds

This images supports following architectures [(more info)](8):

-   `amd64` - for most desktop processors

-   `arm7v` - for 32-Bit ARM images like Raspbian (Raspberry 1, 2, 3 and 4)

-   `arm64` - for 64-Bit ARM images like armbian

-   `386` - for legacy desktop processors

## Starting your bitcoind node

To quick start your _bitcoind_ node just clone this repository and run Docker:

```shell
git clone https://github.com/legacycode/bitcoind-docker.git
cd bitcoind-docker
docker-compose up -d
```

Or create the Docker compose file by yourself and run Docker:

1.  Create a _docker-compose.yml_ file with the following content:

    ```yaml
    version: "2"

    services:
      bitcoind:
        container_name: bitcoind
        hostname: bitcoind
        image: legacycode/bitcoind:latest
        restart: unless-stopped
        volumes:
          - bitcoind-data:/home/bitcoin/.bitcoin
        ports:
          - 8333:8333
        command: [
          "-server",
          "-txindex",
        ]

    volumes:
      bitcoind-data:
    ```

2.  Run the container by entering the following command into your terminal:
    `docker-compose up`

## Docker volumes

**Special diskspace hint**: The examples are using a Docker managed volume. The volume is named _bitcoind-data_ This will use a lot of disk space, because it contains the full Bitcoin blockchain. Please make yourself familiar with [Docker volumes][3].

The _bitcoind-data_ volume will be reused, if you upgrade your _docker-compose.yml_ file. Keep in mind, that the docker volume is not automatically removed by Docker, if you delete the bitcoind container. If you don't need the volume anymore, please delete it manually with the command:

```bash
docker volume ls
docker volume rm bitcoind-data
```

For binding a local folder to your _bitcoind_ container please read the [Docker documentation][2]. The preferred way is to use a Docker managed volume.

## License

This [bitcoind Dockerfile][1] is provided under the [MIT License][4].

For license information about [bitcoind][5] visit the [bitcoind GitHub source][6].

The Docker images are based on the [alpine Docker image][7]. Refer to the official [alpine Docker image][7] page for license information.

[1]: https://github.com/legacycode/bitcoind-docker

[2]: https://docs.docker.com/

[3]: https://docs.docker.com/storage/volumes/

[4]: https://github.com/legacycode/bitcoind-docker/blob/latest/LICENSE.md

[5]: https://github.com/bitcoin/bitcoin

[6]: https://github.com/bitcoin/bitcoin/blob/master/COPYING

[7]: https://hub.docker.com/_/alpine

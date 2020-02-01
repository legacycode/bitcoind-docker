# Bitcoind Docker Image

![MicroBadger Size](https://img.shields.io/microbadger/image-size/leacycode/bitcoind) ![MicroBadger Layers](https://img.shields.io/microbadger/layers/legacycode/bitcoind) ![Docker Pulls](https://img.shields.io/docker/pulls/legacycode/bitcoind) ![Docker Stars](https://img.shields.io/docker/stars/legacycode/bitcoind)

## Introduction

With Docker you can easily set up *bitcoind* and create your Bitcoin full node.
The Docker source file of this image is located at [Dockerfile](https://github.com/legacycode/bitcoind-docker).

This documentation focus on running Docker container with *docker-compose.yml* files. These files are better to read and you can use them as a template. For more information about Docker and Docker compose visit the official [Docker documentation](https://docs.docker.com/).

## Supported tags and respective Dockerfile links

[`latest`](https://github.com/legacycode/bitcoind-docker/blob/master/Dockerfile) [`v0.19.0.1`](https://github.com/legacycode/bitcoind-docker/blob/v0.19.0.1/Dockerfile) [`v0.19.0`](https://github.com/legacycode/bitcoind-docker/blob/v0.19.0/Dockerfile) [`v0.18.1`](https://github.com/legacycode/bitcoind-docker/blob/v0.18.1/Dockerfile)

## Starting your bitcoind node

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

## Docker volumes

**Special diskspace hint**: The examples are using a Docker managed volume. The volume is named *bitcoind-data* This will use a lot of disk space, because it contains the full Bitcoin blockchain. Please make yourself familiar with [Docker volumes](https://docs.docker.com/storage/volumes/).

The *bitcoind-data* volume will be reused, if you upgrade your *docker-compose.yml* file. Keep in mind, that the docker volume is not automatically removed by Docker, if you delete the bitcoind container. If you don't need the volume anymore, please delete it manually with the command:

```bash
docker volume ls
docker volume rm bitcoind-data
```

For binding a local folder to your *bitcoind* container please read the [Docker documentation](https://docs.docker.com/). The preferred way is to use a Docker managed volume.

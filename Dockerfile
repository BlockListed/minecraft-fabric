FROM ubuntu:22.04 as MODRINTH_BUILDER
ENV MODRINTH_VERSION=1.5.11
WORKDIR /usr/bin
RUN curl -1LO https://github.com/BlockListed/modrinth_downloader/releases/download/${MODRINTH_VERSION}/modrinth-downloader

FROM ubuntu:22.04 as RCON_BUILDER
ENV RCON_VERSION=0.10.3
WORKDIR /usr/src/rcon-cli
RUN apt-get update && apt-get install -y curl tar && rm -rf /var/apt/lists/*
RUN curl -1L https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz -o rcon.tar.gz
RUN tar -xvf rcon.tar.gz
RUN cp rcon-*_linux/rcon /usr/local/bin/

FROM alpine:3
RUN apk add --no-cache curl openjdk17-jre

COPY --from=BUILDER /usr/local/cargo/bin/modrinth-downloader /usr/bin/
COPY entrypoint.sh /
COPY entrypoint-afterroot.sh /
COPY config.toml /default/config.toml
COPY --from=RCON_BUILDER /usr/local/bin/rcon /usr/bin/
COPY rcon.yaml /

ENV PUID=1000
ENV PGID=1000
ENV RAM=1G

EXPOSE 25565

ENTRYPOINT [ "/entrypoint.sh" ]

FROM ubuntu:22.04 as MODRINTH_BUILDER
ENV MODRINTH_VERSION=1.5.11
WORKDIR /usr/local/bin
RUN apt-get update && apt-get install -y curl
RUN curl -1LO https://github.com/BlockListed/modrinth_downloader/releases/download/${MODRINTH_VERSION}/modrinth-downloader
RUN chmod +x modrinth-downloader

FROM ubuntu:22.04 as RCON_BUILDER
ENV RCON_VERSION=0.10.3
WORKDIR /usr/src/rcon-cli
RUN apt-get update && apt-get install -y curl tar
RUN curl -1L https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz -o rcon.tar.gz
RUN tar -xvf rcon.tar.gz
RUN cp rcon-*_linux/rcon /usr/local/bin/

FROM alpine:3
RUN apk add --no-cache curl openjdk17-jre python3

COPY --from=MODRINTH_BUILDER /usr/local/bin/modrinth-downloader /usr/bin/
COPY --from=RCON_BUILDER /usr/local/bin/rcon /usr/bin/

COPY entrypoint.sh /
COPY entrypoint-afterroot.py /
COPY config.toml /default/config.toml
COPY rcon.yaml /

ENV PUID=1000
ENV PGID=1000
ENV RAM=1G

EXPOSE 25565

ENTRYPOINT [ "/entrypoint.sh" ]

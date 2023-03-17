FROM rust:slim-buster as BUILDER
WORKDIR /usr/src/modrinth_downloader
COPY modrinth_downloader .

RUN apt-get update && apt-get install -y musl-tools
RUN rustup target add x86_64-unknown-linux-musl
RUN CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse cargo install --target=x86_64-unknown-linux-musl --path .

FROM ubuntu:22.04 as RCON_BUILDER
WORKDIR /usr/src/rcon-cli
RUN apt-get update && apt-get install -y curl tar && rm -rf /var/apt/lists/*
RUN curl -1L https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz -o rcon.tar.gz
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

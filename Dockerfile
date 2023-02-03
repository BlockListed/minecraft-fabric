FROM rust:slim-buster as BUILDER
WORKDIR /usr/src/modrinth_downloader
COPY modrinth_downloader .

RUN apt-get update && apt-get install -y musl-tools
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install --target=x86_64-unknown-linux-musl --path .

FROM alpine:3
RUN apk add --no-cache curl sudo openjdk17-jre

COPY --from=BUILDER /usr/local/cargo/bin/modrinth_downloader /usr/bin/
COPY entrypoint.sh /
COPY entrypoint-afterroot.sh /
COPY config.toml /default/config.toml

ENV PUID=500
ENV PGID=500
ENV RAM=1G

EXPOSE 25565

ENTRYPOINT [ "/entrypoint.sh" ]
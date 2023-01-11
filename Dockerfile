FROM rust:1.66-slim-buster as BUILDER
WORKDIR /usr/src/modrinth_downloader
COPY modrinth_downloader .

RUN cargo install --path .

FROM eclipse-temurin:17
RUN apt-get update && apt-get upgrade -y && apt-get install sudo -y && rm -rf /var/lib/apt/lists/*

COPY --from=BUILDER /usr/local/cargo/bin/modrinth_downloader /usr/bin/
COPY entrypoint.sh /
COPY entrypoint-afterroot.sh /
COPY config.toml /default/config.toml

ENV PUID=500
ENV PGID=500
ENV RAM=1G

EXPOSE 25565

ENTRYPOINT [ "/entrypoint.sh" ]
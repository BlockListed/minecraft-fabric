FROM --platform=$BUILDPLATFORM ubuntu:22.04 as MODRINTH_BUILDER
ARG TARGETPLATFORM
ARG MODRINTH_VERSION=1.8.0
WORKDIR /usr/local/bin
RUN echo "BUILDING FOR $TARGETPLATFORM"
RUN apt-get update && apt-get install -y curl
RUN curl -1L -o modrinth-downloader\
  https://github.com/BlockListed/modrinth_downloader/releases/download/${MODRINTH_VERSION}/$([ "$TARGETPLATFORM" = "linux/arm64" ] && echo -n "aarch64-modrinth-donwloader" || echo -n "modrinth-downloader")
RUN chmod +x modrinth-downloader

FROM --platform=$BUILDPLATFORM ubuntu:22.04 as RCON_BUILDER
ARG TARGETPLATFORM
ARG RCON_VERSION=0.10.3
WORKDIR /usr/src/rcon-cli
RUN echo "BUILDING FOR $TARGETPLATFORM"
RUN apt-get update && apt-get install -y curl tar git
RUN curl -1L https://go.dev/dl/go1.22.1.linux-amd64.tar.gz | tar -C /usr/local -xzf -
RUN git clone -b "v$RCON_VERSION" https://github.com/gorcon/rcon-cli.git
RUN cd rcon-cli && \
  PATH=$PATH:/usr/local/go/bin \
  GOARCH=$([ "$TARGETPLATFORM" = "linux/arm64" ] && echo -n "arm64" || echo -n "amd64") \
  go build -o /usr/local/bin/rcon ./cmd/gorcon/main.go

FROM --platform=$TARGETPLATFORM alpine:3
RUN apk add --no-cache curl openjdk17-jre-headless python3 py3-requests py3-colorama

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

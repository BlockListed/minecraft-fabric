# minecraft-fabric
docker container for minecraft which downloads mods

## Usage
- Mount your server directory, where persistent data, including the world file, will be saved, to `/minecraft`.
- Pass through port 25565 for Minecraft and (optionally) 25575 for rcon.
- (Optionally) mount you custom configuration for `modrinth_downloader` to `/config/config.toml`, this must not be a read-only mount.
- Set the `RAM` environment variable to the desired amount of memory to be allocated to mineraft, eg `2500M` or `3G`, make sure to leave buffer space for your OS and the JVM.
- (Optionally) set the `RCON` environment variable to `1`, if you desire the ability to access the console without launching the container in interactive mode.

## Example
Firstly spawn the docker container with:

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

Next edit the eula.txt file in `SERVER_DIR` and accept the eula.
Finally you can spawn the docker container in either interactive or detached mode.

Interactive:

```
docker run -it --rm -v SERVER_DIR:/mineraft -p 25565:25565 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

Detached:

```
docker run -d --name minecraft --restart unless-stopped -v SERVER_DIR:/minecraft -p 25565:25565 ghcr.io/blocklisted/minecraft-fabric-1.20.4
```

## Ram config
You can set the server to use a custom amount of RAM

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 -e RAM=4G ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

## Modrinth config
Y``
ou can mount a custom `modrinth-downloader` `config.toml` to `/config/config.toml
```

```
docker run -it --rm -v SERVER_DIR:/minecraft -v CUSTOM_CONFIG:/config/config.toml -p 25565:25565 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

## RCON usage
Firstly you need to enable RCON using the `RCON` environment variable.
Do not, that if the `RCON_PASSWORD` variable isn't set, the password defaults to `minecraft`.

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 -e RCON=1 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

With a password set:

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 -e RCON=1 -e RCON_PASSWORD=hunter2 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

With RCON exposed with the default password (not recommended):

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 -e RCON=1 -p 25575:25575 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

With a password set and RCON exposed:

```
docker run -it --rm -v SERVER_DIR:/minecraft -p 25565:25565 -e RCON=1 -e RCON_PASSWORD=hunter2 -p 25575:25575 ghcr.io/blocklisted/minecraft-fabric:1.20.4
```

You can then access any of thes rcone, either using a regular RCON client in the exposed cases or using the included `rcon-cli` utility accessible under `rcon`:
(This example only works, if your container is called minecraft)

```
docker exec -it minecraft rcon
```

#!/usr/bin/python3
import os
from pathlib import Path
import subprocess


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


MINECRAFT_VERSION = "1.19.4"
FABRIC_LOADER_VERSION = "0.14.19"
FABRIC_INSTALLER_VERSION = "0.11.2"

# Download fabric in background
fabric_download = subprocess.Popen(
    [
        "curl",
        "-1L",
        f"https://meta.fabricmc.net/v2/versions/loader/{MINECRAFT_VERSION}/{FABRIC_LOADER_VERSION}/{FABRIC_INSTALLER_VERSION}/server/jar",
        "-o",
        "/minecraft/fabric.jar"
    ],
)

# Make sure mod directory exists
try:
    Path("/minecraft/mods").mkdir()
except FileExistsError:
    # Don't care
    pass
except Exception:
    print(
        "%sCouldn't create minecraft mods folder!%s"
        % (bcolors.FAIL, bcolors.ENDC))

    os.exit()

# Start downloading mods
mod_download = subprocess.Popen(["/usr/bin/modrinth-downloader"])

if Path("/minecraft/server.properties").is_file():
    # RCON
    if os.getenv("RCON") == "1":
        print("Enabling RCON")
        subprocess.run(
            [
                "sed",
                "-i",
                "'s/^enable-rcon=false$/enable-rcon=true/'",
                "/minecraft/server.properties",
            ]
        )
        rcon_password = os.environ.get("RCON_PASSWORD", "minecraft")
        subprocess.run(
            [
                "sed",
                "-i",
                f"'s/^rcon.password=$/rcon.password={rcon_password}/'",
                "/minecraft/server.properties",
            ]
        )

fabric_download.wait()
mod_download.wait()

ram = os.environ["RAM"]

os.chdir("/minecraft")
os.execvp("java", [
    f"-Xms{ram}",
    f"-Xmx{ram}",
    "-XX:+UseG1GC",
    "-XX:+ParallelRefProcEnabled",
    "-XX:MaxGCPauseMillis=200",
    "-XX:+UnlockExperimentalVMOptions",
    "-XX:+DisableExplicitGC",
    "-XX:+AlwaysPreTouch",
    "-XX:G1NewSizePercent=30",
    "-XX:G1MaxNewSizePercent=40",
    "-XX:G1HeapRegionSize=8M",
    "-XX:G1ReservePercent=20",
    "-XX:G1HeapWastePercent=5",
    "-XX:G1MixedGCCountTarget=4",
    "-XX:InitiatingHeapOccupancyPercent=15",
    "-XX:G1MixedGCLiveThresholdPercent=90",
    "-XX:G1RSetUpdatingPauseTimePercent=5",
    "-XX:SurvivorRatio=32",
    "-XX:+PerfDisableSharedMem",
    "-XX:MaxTenuringThreshold=1",
    "-Dusing.aikars.flags=https://mcflags.emc.gs",
    "-Daikars.new.flags=true",
    "-jar",
    "/minecraft/fabric.jar",
    "--nogui",
])

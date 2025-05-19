#!/usr/bin/python3
import os
from pathlib import Path
import subprocess
import requests
from colorama import Fore, Style


MINECRAFT_VERSION = "{{minecraft_version}}"
FABRIC_LOADER_VERSION = requests.get(
    "https://meta.fabricmc.net/v2/versions/loader").json()[0]["version"]
FABRIC_INSTALLER_VERSION = requests.get(
    "https://meta.fabricmc.net/v2/versions/installer").json()[0]["version"]

print(
    f"Downloading fabric {MINECRAFT_VERSION}-{FABRIC_LOADER_VERSION}-{FABRIC_INSTALLER_VERSION}")

# Download fabric in background
fabric_download = subprocess.Popen(
    [
        "curl",
        "-1L",
        f"https://meta.fabricmc.net/v2/versions/loader/{MINECRAFT_VERSION}/{FABRIC_LOADER_VERSION}/{FABRIC_INSTALLER_VERSION}/server/jar",  # noqa: E501
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
        Fore.RED + "Couldn't create minecraft mods folder!" + Style.RESET_ALL
    )

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
                "s/^enable-rcon=false$/enable-rcon=true/",
                "/minecraft/server.properties",
            ]
        )
        rcon_password = os.environ.get("RCON_PASSWORD", "minecraft")
        subprocess.run(
            [
                "sed",
                "-i",
                f"s/^rcon.password=$/rcon.password={rcon_password}/",
                "/minecraft/server.properties",
            ]
        )

fabric_download.wait()
mod_download.wait()

ram = os.environ["RAM"]

ram_args = [f"-Xms{ram}", f"-Xmx{ram}"]

gc_args = "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"  # noqa: E501

if os.environ.get("ZGC") == "1":
    gc_args = "-XX:+UnlockExperimentalVMOptions -XX:+UseZGC -XX:+ZGenerational -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:-ZUncommit -XX:+ParallelRefProcEnabled"
if "CUSTOM_GC" in os.environ:
    gc_args = os.environ["CUSTOM_GC"]

gc_args = gc_args.split()

print(Style.BRIGHT + "Starting minecraft server with jvm options: " + Style.RESET_ALL + Fore.GREEN + "\"{}\"".format(" ".join(ram_args + gc_args)) + Style.RESET_ALL)

args = ram_args + gc_args + ["-jar", "fabric.jar", "--nogui"]

os.chdir("/minecraft")
os.execvp("java", args)

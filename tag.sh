#!/bin/bash
set -e

date=$(date --iso-8601=date)

MINECRAFT_VERSION="1.20.2"

git tag -s "${MINECRAFT_VERSION}_${date}"
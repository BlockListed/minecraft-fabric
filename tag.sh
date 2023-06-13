#!/bin/bash
set -e

date=$(date --iso-8601=date)

GAME_VERSION="1.20"

git tag -s "${GAME_VERSION}_${date}"
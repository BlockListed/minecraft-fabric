#!/bin/bash
set -e

date=$(date --iso-8601=date)

GAME_VERSION="1.20"

[ $# != 1 ] && (echo "SINGLE ARGUMENT REQUIRED" && exit 1)
[ -z "$1" ] && (echo "MESSAGE EMPTY" && exit 1)

echo git tag -s "${GAME_VERSION}_${date}" -m "$1"
#!/bin/bash
set -e

date=$(date --iso-8601=date)

GAME_VERSION="1.19.4"

[ $# != 1 ] && (echo "SINGLE ARGUMENT REQUIRED" && exit 1)
[ -z "$1" ] && (echo "MESSAGE EMPTY" && exit 1)

git tag -s "${GAME_VERSION}_${date}" -m "$1"
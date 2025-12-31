#!/usr/bin/env bash
set -e

date=$(date --iso-8601=date)

git tag -s "${date}"

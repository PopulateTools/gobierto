#!/bin/bash
set -e

if [ ! -d $PWD/app ]; then
    echo "[INFO] New mount volume, move content to directory with persistence"
    echo -e "[INFO] Moving the content"
    mv /app/* $PWD && mv /app/.[!.]* $PWD
else
    echo -e "[INFO] Detected Volume with data"
fi
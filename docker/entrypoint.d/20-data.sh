#!/bin/bash
set -e

if [ ! -d $PWD/app ]; then
    echo "[INFO] New mount volume, move content to directory with persistence"
    echo -e "[INFO] Moving the content"
    mv /app/* $PWD && mv /app/.[!.]* $PWD
    echo -e "[INFO] Access to directory"
    cd $PWD
    echo -e "[INFO] Copy file database.yml, copy file .env and create link .env"
    cp config/database.yml.example config/database.yml
    cp .env.example .env
    ln -s .env .rbenv-vars
else
    echo -e "[INFO] Detected Volume with data"
fi
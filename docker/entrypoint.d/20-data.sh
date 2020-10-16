#!/bin/bash
set -e

if [ ! -d $PWD_APP/app ]; then
    echo "[INFO] New mount volume, move content to directory with persistence"
    echo -e "[INFO] Moving the content"
    mv /app/* $PWD_APP && mv /app/.[!.]* $PWD_APP
    echo -e "[INFO] Access to directory"
    cd $PWD_APP
    echo -e "[INFO] Copy file database.yml, copy file .env and create link .env"
    cp config/database.yml.example config/database.yml
    cp .env.example .env
    ln -s .env .rbenv-vars
else
    echo -e "[INFO] Detected Volume with data"
fi
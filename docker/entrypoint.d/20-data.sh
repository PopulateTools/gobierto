#!/bin/bash
set -e

if [ ! -d $PWD/app ]; then
    echo "[INFO] New mount volume, move content to directory with persistence"
    echo -e "[INFO] Moving the content"
    mv /app/* $PWD && mv /app/.[!.]* $PWD
    if [ ! -f $PWD/config/database.yml ]; then
        echo "[INFO] Change name of file database.yml.example to database.yml"
        cd $PWD
        ls -la config/
        cp config/database.yml.example config/database.yml
    fi

    if [ ! -f $PWD/.env ]; then
        echo "[INFO] Change name of file .env.example to .env"
        cd $PWD
        cp .env.example .env
    fi

    if [ ! -L $PWD/.rbenv-vars ]; then
        echo "[INFO] Symbolic link of .env with name .rbenv-vars"
        cd $PWD
        ln -s .env .rbenv-vars
    fi
else
    echo -e "[INFO] Detected Volume with data"
fi
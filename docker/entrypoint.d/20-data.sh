#!/bin/bash
set -e

if [ ! -d $PWD_APP/app ]; then
    echo "[INFO] New mount volume, move content to directory with persistence"
    echo -e "[INFO] Moving the content"
    mv /app/* $PWD_APP && mv /app/.[!.]* $PWD_APP
    
    if [ ! -f $PWD_APP/config/database.yml ]; then
        echo "[INFO] Change name of file database.yml.example to database.yml"
        cd $PWD_APP
        cp config/database.yml.example config/database.yml
    fi

    if [ ! -f $PWD_APP/.env ]; then
        echo "[INFO] Change name of file .env.example to .env"
        cd $PWD_APP
        cp .env.example .env
    fi

    if [ ! -L $PWD_APP/.rbenv-vars ]; then
        echo "[INFO] Symbolic link of .env with name .rbenv-vars"
        cd $PWD_APP
        ln -s .env .rbenv-vars
    fi
else
    echo -e "[INFO] Detected Volume with data"
fi
#!/bin/bash

if [ ! -d $PWD/app ]; then
    echo "New mount volume, move content to directory with persistence"
    echo -e "\e[5mMoving the content\e[25m"
    mv /app/* $PWD && mv /app/.[!.]* $PWD
    echo -e "Access to directory"
    cd $PWD
    echo -e "Copy file database.yml, copy file .env and create link .env"
    cp config/database.yml.example config/database.yml
    cp .env.example .env
    ln -s .env .rbenv-vars
    sed -i "s/CONFIGHOST/`echo $HOST`/g" $PWD/config/environments/development.rb
else
    echo -e "\e[92mDetected Volume with data\e[39m"
fi
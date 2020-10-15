#!/bin/bash
set -e

echo "[INFO] Init container"
echo "127.0.0.1 $HOST" >> /etc/hosts
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cp $PWD/config/database.yml.example $PWD/config/database.yml
cp $PWD/.env.example $PWD/.env
ln -s $PWD/.env $PWD/.rbenv-vars
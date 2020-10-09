#!/bin/bash
echo "INIT CONTAINER"
echo "127.0.0.1 $HOST" >> /etc/hosts
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
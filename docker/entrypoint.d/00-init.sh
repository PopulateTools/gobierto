#!/bin/sh
set -e

echo "[INFO] User: $(whoami)"

if [ "${DEBUG}" == "True" ]; then
    export
fi


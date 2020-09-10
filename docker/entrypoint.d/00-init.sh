#!/bin/sh
set -e

echo "[INFO] User: $(whoami)"

if [ "${DEBUG}" == "True" ]; then
    export
    pip freeze
fi

cp docker/executable/python/local_settings.py .

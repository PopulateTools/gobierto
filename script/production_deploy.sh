#!/bin/bash

curl -XPOST -H "Authorization: Token token="$DEPLOY_BOT_TOKEN $GOBIERTO_PRODUCTION_DEPLOY_URL

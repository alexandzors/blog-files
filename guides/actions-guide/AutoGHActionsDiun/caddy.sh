#!/bin/bash
#caddy.sh

curl -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token <TOKEN>" \
    --request POST \
    --data '{"event_type": "caddy"}' \
    https://api.github.com/repos/<git_repo>/dispatches
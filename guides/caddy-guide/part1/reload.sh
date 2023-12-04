#!/bin/sh
# This script runs caddy reload, caddy validate, caddy fmt, and caddy version inside the container via docker exec.
# Usage:
# -r    caddy reload
# -v    caddy validate
# -f    caddy fmt
# -V    caddy version
# Caddy docs: https://caddyserver.com/docs/command-line
# Created by: https://github.com/alexandzors/caddy
# Created for: https://blog.alexsguardian.net/guides/#caddy
caddy_container_name="caddy-server-1"
caddy_container_id=$(docker ps | grep $caddy_container_name | awk '{print $1;}')

while getopts ":r:v:f:V" option; do
  case $option in
  r)
    docker exec -w /etc/caddy $caddy_container_id caddy reload
    ;;
  v)
    docker exec -w /etc/caddy $caddy_container_id caddy validate --config /etc/caddy/Caddyfile
    ;;
  f)
    docker exec -w /etc/caddy $caddy_container_id caddy fmt --config /etc/caddy/Caddyfile
    ;;
  V)
    docker exec -w /etc/caddy $caddy_container_id caddy version
    ;;
  esac
done
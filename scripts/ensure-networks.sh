#!/usr/bin/env bash
# Create every backend network Traefik attaches to. Idempotent; run on BOTH
# hosts before `docker compose up` in traefik/ (and the stacks). Networks for
# stacks that run on the other host just stay empty.
#
# Each network takes a subnet from Docker's address pool. The default pool runs
# out after ~15-30 networks, so set a larger one in /etc/docker/daemon.json
# (then restart dockerd), e.g.:
#   { "default-address-pools": [{ "base": "10.200.0.0/16", "size": 24 }] }
set -euo pipefail

networks=(
  arrs
  ainet
  immich
  searxng
  speakr
  edge-bentopdf
  edge-comfyui
  edge-converter
  edge-homeassistant
  edge-jellyfin
  edge-mealie
  edge-unifi
)

for n in "${networks[@]}"; do
  if docker network inspect "$n" >/dev/null 2>&1; then
    echo "exists  $n"
  else
    docker network create "$n" >/dev/null && echo "created $n"
  fi
done

##!/bin/bash
set +e
sudo rm -f /var/docker-compose/docker-compose.yml || true
sudo cp -rf ./docker-compose.yml /var/docker-compose/docker-compose.yml
sudo rm -f docker-compose.yml || true
sudo chown -R student:student /var/docker-compose/
cd /var/docker-compose/
set -e

docker-compose up -d frontend
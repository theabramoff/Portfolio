#!/bin/bash
set +e
cat > .env <<EOF
 SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
 SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
 SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
 SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
EOF
sudo rm -f /var/docker-compose/docker-compose.yml || true
sudo cp -rf ./docker-compose.yml /var/docker-compose/docker-compose.yml
sudo rm -f docker-compose.yml || true
sudo chown -R student:student /var/docker-compose/
cd /var/docker-compose/

set -e

docker-compose --env-file .env up -d backend

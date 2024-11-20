#/bin/bash

echo "[+] Running : docker compose --env-file .env up -d"
docker compose --env-file .env up -d

# Set permissions for recordings
chown -R 1000:1001 ./record
chmod -R 2750 ./record

IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "[+] Guacamole frontend available on https://$IP_ADDRESS:8443/"
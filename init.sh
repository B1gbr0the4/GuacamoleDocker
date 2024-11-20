#!/bin/bash

##############################################
# VARIABLES

# Following variables can be customized
DAYS_VALID=365
SUBJECT="/C=QC/ST=Saguenay/L=Chicoutimi/O=UQAC/OU=G11 Secu/CN=Guacamole"

# Following variables should not modified unless you know what you are doing
CERTS_PATH="./certs"

##############################################
# BEGINNING OF THE SCRIPT

# Load .env file
source .env

# check if docker is running
if ! (docker ps >/dev/null 2>&1)
then
	echo "[!] Docker daemon not running, will exit here!"
	exit
fi

echo "[i] Preparing folder init and creating ./init/initdb.sql"
mkdir ./init >/dev/null 2>&1
chmod -R +x ./init

# Generate the initdb.sql file
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > ./init/initdb.sql

# Generate the initdb.sql file
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > ./init/initdb.sql

echo "[i] Build debian image with ssh server"
cp Dockerfile.example Dockerfile
sed -i "s/sudo -u 1000 test/sudo -u 1000 $SSH_USER/" Dockerfile
sed -i "s/user:CHANGEME/$SSH_USER:$SSH_PASSWORD/" Dockerfile
docker build -t debian_ssh .

# Generate the SSL certificate
echo "[i] Generating certificate"
mkdir -p $CERTS_PATH
openssl req -newkey rsa:4096 -keyout "$CERTS_PATH/server.key" -out "$CERTS_PATH/server.csr" -subj "$SUBJECT" -nodes
openssl x509 -req -days $DAYS_VALID -in "$CERTS_PATH/server.csr" -signkey "$CERTS_PATH/server.key" -out "$CERTS_PATH/server.crt"
rm "$CERTS_PATH/server.csr"

echo "All done"
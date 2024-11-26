#!bin/bash

HOST=localhost:2375
DOCKER_ETC=/etc/docker
CERTS_DIR=$DOCKER_ETC/$HOST

# ENDPOINT=
# DBNAME=
# USERNAME=
# PASSWORD=

sudo amazon-linux-extras install epel

# sudo yum install certbot
sudo mkdir -p $CERTS_DIR
sudo yum install -y docker
sudo dnf install postgresql15 -y

# sudo openssl genrsa \
#     -out $CERTS_DIR/docker-client.key 4096
# sudo openssl req \
#     -new \
#     -x509 \
#     -text \
#     -key $CERTS_DIR/docker-client.key \
#     -out $CERTS_DIR/docker-client.cert \
#     -subj "/C=XX/L=Default City/O=Default Company Ltd"
sudo dockerd
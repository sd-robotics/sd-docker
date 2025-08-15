#! /bin/bash

# Get UID and GID
export UID=$(id -u $USER)
export GID=$(id -g $USER)

docker compose build spacerobot-container
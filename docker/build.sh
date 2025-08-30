#! /bin/bash

# Load environment variables
source .env

# Get LOCAL_UID and LOCAL_GID
export LOCAL_UID=$(id -u ${USER})
export LOCAL_GID=$(id -g ${USER})

docker compose build spacerobot-container
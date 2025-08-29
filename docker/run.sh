#!/bin/bash

# Load environment variables
source .env

# Get LOCAL_UID and LOCAL_GID
export LOCAL_UID=$(id -u) 
export LOCAL_GID=$(id -g)

SERVICE_NAME="spacerobot-container"

# Start the appropriate container
docker compose -f docker-compose.yml up -d ${SERVICE_NAME}
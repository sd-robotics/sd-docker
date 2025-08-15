#!/bin/bash

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Get UID and GID
export UID=$(id -u) 
export GID=$(id -g)

echo "Starting Docker container for ${COMPUTE_TYPE} environment..."

SERVICE_NAME="spacerobot-container"

# Start the appropriate container
docker compose -f docker-compose.yml up -d "$SERVICE_NAME"
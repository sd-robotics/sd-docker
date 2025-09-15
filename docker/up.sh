#!/bin/bash

# Load environment variables
if [[ -f "./env.sh" ]]; then
  source ./env.sh
else
  echo "env.sh not found"; exit 1
fi

PROJECT_NAME=${CONTAINER_NAME}

# Start the appropriate container
docker compose -p ${PROJECT_NAME} up -d spacerobot-container
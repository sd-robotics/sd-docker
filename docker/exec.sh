#!/bin/bash

# Load environment variables
source .env

# Check if container is running
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} is not running."
    echo "Please run './run.sh' first to start the container."
    exit 1
fi

echo "Entering container: ${CONTAINER_NAME}"
docker exec -it --user ${USERNAME} ${CONTAINER_NAME} bash
#!/bin/bash

# Load environment variables from .env file
source .env

docker compose -f docker-compose.yml exec -it --user ${USER_NAME} spacerobot-container /bin/bash

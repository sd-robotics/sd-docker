#! /bin/bash

# Load environment variables
if [[ -f "./env.sh" ]]; then
  source ./env.sh
else
  echo "env.sh not found"; exit 1
fi

# Generate .env file
cat > .env <<EOF
LOCAL_UID=${LOCAL_UID}
LOCAL_GID=${LOCAL_GID}
ARCHITECTURE=${ARCHITECTURE}
USERNAME=${USERNAME}
CONTAINER_NAME=${CONTAINER_NAME}
EOF
echo "Generated .env file"

docker compose build spacerobot-container
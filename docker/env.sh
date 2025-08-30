# Docker Environment Configuration

# Get LOCAL_UID and LOCAL_GID
LOCAL_UID=$(id -u)
LOCAL_GID=$(id -g)

# System Configuration
ARCHITECTURE=amd64 # amd64 or jetson

# User Configuration
USERNAME=spacerobot
CONTAINER_NAME=$(basename $(dirname $(pwd)))
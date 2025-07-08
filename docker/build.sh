#!/bin/bash

DIR=$(pwd)
str=`echo ${DIR} | awk -F "/" '{ print $(NF - 1) }'`

docker build \
    --tag sd-robotics/${str} \
    --network host \
    --build-arg LOCAL_UNAME=${USERNAME} \
    --build-arg LOCAL_UID=$(id -u ${USER}) \
    --build-arg LOCAL_GID=$(id -g ${USER}) \
    .


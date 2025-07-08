#!/bin/bash

DIR=$(pwd)
str=`echo ${DIR} | awk -F "/" '{ print $(NF - 1) }'`

docker exec \
    -it \
    ${str} \
    /bin/bash


#!/bin/sh

CONTAINER="$1"

if [ "$1" == "" ]
then
    echo "Expected container name"
    
    exit 1
fi

docker logs $CONTAINER 2>&1

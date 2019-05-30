#!/bin/sh

docker network create docker-mailserver_default
docker run -d --network docker-mailserver_default --network-alias mailhog --name mailhog mailhog/mailhog

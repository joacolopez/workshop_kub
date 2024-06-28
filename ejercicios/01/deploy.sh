#!/bin/bash

# Input control and usage
if [ $# -ne 3 ]; then
    echo "This script must should be executed on the directory where the configs files for the container are"
    echo "Uso: $0 [docker user: pepito] [image name:basic-web] [image version: v0.1.1 or latest]"
    exit 1
fi

# Inputs
DOCKER_USER=$1
IMAGE_NAME=$2
IMAGE_VERSION=$3

# Vars
FULL_IMAGE_NAME="$DOCKER_USER/$IMAGE_NAME:$IMAGE_VERSION"
CONTAINER_NAME="basic-webpage-container"
HOST_PORT=8080
CONTAINER_PORT=80
HTML_FILE="index.html"
NGINX_HTML_DIR="/usr/share/nginx/html"

# Docker build
echo "## Building up container ##"
docker build -t $FULL_IMAGE_NAME .

# Docker container is running? Stop it
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "## Stopping container ##"
    docker stop $CONTAINER_NAME
fi

# Docker container exists? Remove it
if [ $(docker ps -a -q -f name=$CONTAINER_NAME) ]; then
    echo "## Removing container ##"
    docker rm $CONTAINER_NAME
fi

# Docker run w/ volume. This prevents building the container if index.html file changes
echo "## Running detached container ##"
docker run -d --name $CONTAINER_NAME -p $HOST_PORT:$CONTAINER_PORT -v $(pwd)/$HTML_FILE:$NGINX_HTML_DIR/$HTML_FILE $FULL_IMAGE_NAME

#Output
echo "$ Docker container is running at: http://localhost:$HOST_PORT"

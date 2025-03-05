#!/usr/bin/env bash

image="basantmandal/hk2-php8.2-fpm"
version="1.0"

result=$(docker images -q ${image})
if [[ -n "$result" ]]; then
    echo "Image exists"
    sudo docker image rm -f ${result}
else
    docker build --no-cache -t ${image}:${version} . >> docker_build.log
    docker tag ${image}:${version} ${image}:${version}
fi

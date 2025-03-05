#!/usr/bin/env bash

image="basantmandal/hk2-php8.2-fpm"
version="1.0"

result=$(docker images -q ${image})
if [[ -n "$result" ]]; then
    echo "Image Found - Push Image to Docker Hub"
    docker push ${image}:${version}
fi

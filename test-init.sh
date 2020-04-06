#!/usr/bin/env bash

docker login -u admin -p admin123 nexus-docker.local:32489
docker pull dockercloud/hello-world
docker tag dockercloud/hello-world nexus-docker.local:32489/dockercloud/hello-world:0.1
docker push nexus-docker.local:32489/dockercloud/hello-world:0.1

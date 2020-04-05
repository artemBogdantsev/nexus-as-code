#!/usr/bin/env bash

kubectl create secret docker-registry regsecret --docker-server=nexus-docker.local:32489 \
--docker-username=admin --docker-password=admin123 --docker-email=abt@norcom.de --namespace hello-world

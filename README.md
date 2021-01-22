# docker-alpine-k8s-tools

## intro
This docker image contains following tools:
* awscli(v2)
* git
* eksctl
* helm
* jq
* kubectl
* yq

## build
for `alpine:3.12.3`:
```
docker build -t k8s-tools:latest .
docker exec -it $(docker run -dit k8s-tools:latest) bash
```
or for `amazon/aws-cli:2.1.19`:
```
docker build -t k8s-tools:amazon -f .\Dockerfile-amazon .
docker exec -it $(docker run -dit k8s-tools:amazon) bash
```
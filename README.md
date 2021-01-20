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
```
docker build -t k8s-tools:latest .
docker exec -it $(docker run -dit k8s-tools:latest) bash
```
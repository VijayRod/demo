```
# To create a working directory
mkdir /tmp/docker; cd /tmp/docker

# Dockerfile
FROM ubuntu:latest
WORKDIR /app

# To build the image
az acr build --registry $registry --image image22gacrtasks:v1 .
kubectl run image22gacrtasks --image=imageshack.azurecr.io/image22gacrtasks:v1
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task

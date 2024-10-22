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

```
# You can bypass Docker installation by using `az acr login --expose-token`.
cat <<EOF > /tmp/docker/Dockerfile
FROM nginx:latest
EOF
# cat /tmp/docker/Docker
# See the section on `az acr login -n imageshack --expose-token`
az acr build --registry $registry --image nginx .
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task
- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli

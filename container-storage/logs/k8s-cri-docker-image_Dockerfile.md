## Dockerfile

```
# See the secion on vs.app.console.container.Dockerfile

# Dockerfile
FROM debian:latest
WORKDIR /app
RUN touch myfile

# To build the image
docker build -t mydebian .
docker image list | grep mydebian

# To cleanup
rm Dockerfile
```

```
cat <<EOF > /tmp/docker/Dockerfile
FROM ubuntu:latest
WORKDIR /app
EOF
# cat /tmp/docker/Dockerfile

# tbd nginx - custom
# https://www.baeldung.com/linux/nginx-docker-container
FROM ubuntu
RUN apt-get -y update && apt-get -y install nginx
COPY default /etc/nginx/sites-available/default
EXPOSE 80/tcp
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
```

- https://docs.docker.com/reference/dockerfile/
- https://docs.docker.com/engine/reference/builder/

## Dockerfile.build.AzureContainerRegistry

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
az acr build --registry $registry --image nginx . # Run ID: dt1 was successful after 47s
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task
- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli

## Dockerfile.build.VisualStudio

```
# See the section on vs.app.console.container.

# It's best to first compile the project and run it locally using F5, which will launch it in a Docker container and display the kubectl logs.
# Solution Explorer: Right-click on the project, Publish, Target=Azure, Azure Container Registry, pick you sub, Container build = Docker Desktop (Dockerfile required), hit Close. Publish.

# Image name: The image name is the same as the project name. To have a different image name, create a copy of the project, for instance, by using an exported template. # Attempting to add it as a separate project in the same solution but under a different name didn’t work out (same image name as earlier). Try creating a copy of the solution.
```

## Dockerfile.dynamic

- https://www.baeldung.com/ops/dockerfile-env-variable

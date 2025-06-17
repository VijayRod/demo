## k8s.cri.docker

```
# See the section on storage-device-filesystem_overlayfs and Dockerfile

sudo apt update && sudo apt install podman-docker -y # preferred over docker.io since it's rootless
# apt update && apt install docker.io -y # Execute it in a laptop instead of a containerd worker node

cat $HOME/.docker/config.json
```

- https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/
- https://github.com/Yelp/dumb-init?tab=readme-ov-file#why-you-need-an-init-system: Normally, when you launch a Docker container, the process you're executing becomes PID 1...

## k8s.cri.docker.cli

```
# docker image

# To download an image from a registry
docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
3153aa388d02: Already exists
Digest: sha256:0bced47fffa3361afa981854fcabcd4577cd43cebbb808cea2b1f33a3dd7f508
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest

# To list images
docker image list
REPOSITORY                          TAG       IMAGE ID       CREATED       SIZE
ubuntu                              latest    5a81c4b8502e   4 weeks ago   77.8MB

# To create a tagged image that refers to a source image
docker tag ubuntu $registry.azurecr.io/samples/ubuntu

# To list images (after creating the tag)
docker image list
REPOSITORY                             TAG       IMAGE ID       CREATED       SIZE
ubuntu                                 latest    5a81c4b8502e   4 weeks ago   77.8MB
imageshack.azurecr.io/samples/ubuntu   latest    5a81c4b8502e   4 weeks ago   77.8MB

# To remove an image
docker image rm ubuntu
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:0bced47fffa3361afa981854fcabcd4577cd43cebbb808cea2b1f33a3dd7f508

# To force remove an image
docker image rm imageshack.azurecr.io/samples/ubuntu --force
Untagged: imageshack.azurecr.io/samples/ubuntu:latest
Untagged: imageshack.azurecr.io/samples/ubuntu@sha256:75399abc111a48bcabcfe40c8fa5d1d44fb99e078ab449338d08f06dad34127e
Deleted: sha256:5a81c4b8502e4979e75bd8f91343b95b0d695ab67f241dbed0d1530a35bde1eb
```

- https://docs.docker.com/engine/reference/commandline/image/
- https://hub.docker.com/search?image_filter=official&type=image&q=

```
docker info
```

- https://docs.docker.com/desktop/wsl/
- https://docs.docker.com/engine/install/#supported-platforms
- https://docs.docker.com/get-started/

```
docker pull ubuntu
docker pull mcr.microsoft.com/mcr/hello-world
docker image list
```

- https://docs.docker.com/engine/reference/commandline/pull/
- https://mcr.microsoft.com/en-us/product/mcr/hello-world/about

```
docker run --rm mcr.microsoft.com/mcr/hello-world
docker run -it ubuntu bash ## exit
docker image list
```

- https://docs.docker.com/engine/reference/run/
- https://docs.docker.com/engine/reference/commandline/run/
  
## k8s.cri.docker.Dockerfile

```
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

```
# Dockerfile.build.AzureContainerRegistry

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
# Dockerfile.build.AzureContainerRegistry.az acr login

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

```
# Dockerfile.build.VisualStudio

# It's best to first compile the project and run it locally using F5, which will launch it in a Docker container and display the kubectl logs.
# Solution Explorer: Right-click on the project, Publish, Target=Azure, Azure Container Registry, pick you sub, Container build = Docker Desktop (Dockerfile required), hit Close. Publish.

# Image name: The image name is the same as the project name. To have a different image name, create a copy of the project, for instance, by using an exported template. # Attempting to add it as a separate project in the same solution but under a different name didn’t work out (same image name as earlier). Try creating a copy of the solution.
```

```
# Dockerfile.build.VisualStudio.console.container

# Visual Studio, New Project, Console App (Enable container support, Container OS = Linux, Container build type = Dockerfile), Create
# Program.cs: Console.WriteLine(DateTimeOffset.UtcNow + ": Hello, World!");
# F5 # 11/02/2024 14:28:08 +00:00: Hello, World! The program 'dotnet' has exited with code 0 (0x0).
# Publish: For example. to an Azure Container Registry.

kubectl run consoleapp1 --image=registry13959.azurecr.io/consoleapp1:latest
sleep 5
k get po -owide # consoleapp1   0/1     Completed   2 (25s ago)   27s
k logs consoleapp1 -c consoleapp1 -f # 11/02/2024 14:24:36 +00:00: Hello, World!
```

- tbd https://www.paraesthesia.com/archive/2019/06/18/tips-on-container-tools-for-visual-studio/

```
# Dockerfile.build.VisualStudio.console.container.Dockerfile

# The following lines are set up to run on a Linux container OS:
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
```

- https://aka.ms/customizecontainer
- https://learn.microsoft.com/en-us/visualstudio/containers/container-build

```
# Dockerfile.build.VisualStudio.console.container.dynamic

# In addition to environment variables, we can similarly process values through ConfigMaps and Secrets.

# System environment variable
Program.cs: Console.WriteLine(DateTimeOffset.UtcNow + ": Hello, World!" + Environment.GetEnvironmentVariable("HOSTNAME"));
k logs consoleapp1 -c consoleapp1 -f # 11/02/2024 15:33:16 +00:00: Hello, World!fada77427588

# Custom environment variable
Solution Explorer: Navigate to \Properties\PublishProfiles\registry13959.pubxml and include "<DockerfileRunEnvironmentFiles>Dockerfile.env</DockerfileRunEnvironmentFiles>" in the PropertyGroup section. Remember, you can use any file name, just don't include the quotes
Solution Explorer: Right-click the project to add a new Item with this file name. Once created, open this file and insert "conn=test", omitting the quotes.
Console.WriteLine(DateTimeOffset.UtcNow + ": Hello, World!" + Environment.GetEnvironmentVariable("conn"));
k logs consoleapp1 -c consoleapp1 -f # 11/02/2024 15:39:16 +00:00: Hello, World!test

# secret
See the section in redis.app.client.net (StackExchange.Redis)
```

- https://www.baeldung.com/ops/dockerfile-env-variable
- https://stackoverflow.com/questions/52370812/passing-environment-variables-to-docker-container-when-running-in-visual-studio: DockerfileRunEnvironmentFiles
- https://learn.microsoft.com/en-us/visualstudio/containers/container-msbuild-properties: DockerfileRunEnvironmentFiles
- tbd https://www.digitalocean.com/community/tutorials/commands-and-arguments-kubernetes#1-using-env-variables-to-define-arguments
- tbd https://www.slingacademy.com/article/dynamic-configuration-in-kubernetes-using-configmap-with-examples/#Accessing_ConfigMap_Values_in_Pods
- https://stackoverflow.com/questions/52933055/vs2017-adding-environment-variables-to-docker-container-for-debugging: add a line to the PropertyGroup which also has your TargetFramework tag with the tag DockerfileRunEnvironmentFiles
- https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#use-environment-variables-to-define-arguments

```
# Dockerfile.build.VisualStudio.console.container.dynamic.envsubst

envsubst < deployment.yaml | kubectl apply -f -
```

- https://stackoverflow.com/questions/48296082/how-to-set-dynamic-values-with-kubernetes-yaml-file

## k8s.cri.docker.Dockerfile.image.large

Ideally, pods containing large image files should be deployed in node pools equipped with ephemeral OS disks.

```
# Dockerfile (Credits: Jacob Baek)
FROM ubuntu:latest
#RUN dd if=/dev/urandom of=/largeimage bs=1 count=0 seek=10G
RUN dd if=/dev/urandom of=/largeimage bs=1G count=23
RUN apt update
RUN apt install nginx -y
EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]

# To build, upload, and deploy an image
registry="registry$RANDOM"
imagename=image23g
docker build -t $imagename .
docker tag $imagename $registry.azurecr.io/samples/$imagename
az acr login --name $registry
docker push $registry.azurecr.io/samples/$imagename
kubectl run $imagename --image=$registry.azurecr.io/samples/$imagename

# docker image list | grep $imagename
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/samples/image23g   latest    e490bd696fe6   6 hours ago    24.9GB

# crictl images | grep $imagename
imageshack.azurecr.io/samples/image23g                                                latest   e490bd696fe6a       24.8GB

/var/log/syslog (Standard_DS2_v2, ManagedDisks)
Aug  9 14:41:11 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-09T14:41:11.281884785Z" level=info msg="Pulled image \"imageshack.azurecr.io/samples/image23g:latest\" with image id \"sha256:e490bd696fe6a58f3b43d0f6ef60da436f645ddc72adca268499fe7800f9d4ad\", repo tag \"imageshack.azurecr.io/samples/image23g:latest\", repo digest \"imageshack.azurecr.io/samples/image23g@sha256:44216f0658f4a847f6f0b520dc088807f1951aced8d417c97d83d7c83c01fce2\", size \"24787252196\" in 8m34.073429831s"
```

The result below did not produce a large image as observed in the `crictl` output, probably due to Docker push compression. For more information, please refer to: https://docs.docker.com/engine/reference/commandline/push/

```
# Dockerfile.
FROM debian:latest
WORKDIR /app
RUN dd if=/dev/zero of=./gentoo_root.img bs=4k iflag=fullblock,count_bytes count=22G

# To build the image with Docker
docker build -t image22g .
docker tag image22g $registry.azurecr.io/samples/image22g
docker push $registry.azurecr.io/samples/image22g

# docker image list
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/samples/image30g   latest    29fcd1d0c3d0   6 hours ago    32.3GB
image30g                                 latest    29fcd1d0c3d0   6 hours ago    32.3GB

# Use the command "crictl image | grep image22g" after running "kubectl run image22g --image=$registry.azurecr.io/samples/image22g". Take note that the image size is now much smaller.
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/samples/image22g   latest   0865f9228fa25       72.5MB
```

```
# Dockerfile.
FROM ubuntu:latest
WORKDIR /app
RUN fallocate -l 30G gentoo_root.img

# To build the image with Docker
docker build -t image30g .
docker tag image30g $registry.azurecr.io/samples/image30g
docker push $registry.azurecr.io/samples/image30g

# docker image list
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/samples/image30g   latest    29fcd1d0c3d0   6 hours ago    32.3GB
image30g                                 latest    29fcd1d0c3d0   6 hours ago    32.3GB

# Use the command "crictl image | grep image30g" after running "kubectl run image30g --image=$registry.azurecr.io/samples/image30g". Take note that the image size is now much smaller.
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/samples/image30g   latest   29fcd1d0c3d0a       61.7MB
```

```
# Dockerfile.
FROM debian:latest
WORKDIR /app
RUN dd if=/dev/zero of=./gentoo_root.img bs=4k iflag=fullblock,count_bytes count=22G

# To build the image with ACR Tasks
az acr build --registry $registry --image image22gacrtasks:v1 .

# Use the command "crictl image | grep image22gacrtasks" after running "kubectl run image22gacrtasks --image=$registry.azurecr.io/samples/image22gacrtasks". Take note that the image size is now much smaller.
REPOSITORY                               TAG       IMAGE ID       CREATED        SIZE
imageshack.azurecr.io/image22gacrtasks   v1   f5e72dfaad617       72.5MB
```

- https://stackoverflow.com/questions/257844/quickly-create-a-large-file-on-a-linux-system
- https://www.augmentedmind.de/2022/02/06/optimize-docker-image-size/
    
## k8s.cri.docker.install

```
# install.wsl

# initial
wsl/Ubuntu: docker
The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.
For details about using Docker Desktop with WSL 2, visit:
https://docs.docker.com/go/wsl2/

# To install Docker Desktop, follow the steps on this guide https://docs.docker.com/go/wsl2/
# Then, open the Docker Desktop app from the Start Menu.
# Right-click on Docker Desktop in the notification area to the right, select Resources, and then WSL Integration. Make sure to enable integration for both the default distros and Ubuntu. This will restart Docker Desktop, but you won't need to restart WSL.

# after the installation of Docker Desktop and integration with wsl
wsl/Ubuntu: docker
Usage:  docker [OPTIONS] COMMAND
...
```

```
# k8s.cri.docker.install.error The following packages have unmet dependencies: moby-containerd : Conflicts: containerd

# Execute it in a laptop instead of a containerd worker node, else get the docker install error:
The following packages have unmet dependencies:
 moby-containerd : Conflicts: containerd
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

```
# k8s.cri.docker.spec.daemon.error.Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running

# For those who only need Docker installed for login purposes and don't need the Docker daemon to be running, see the section on az acr login -n imageshack --expose-token

docker version
Client:
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.21.1
 Git commit:        24.0.7-0ubuntu2~20.04.1
 Built:             Wed Mar 13 20:29:24 2024
 OS/Arch:           linux/amd64
 Context:           default
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?

docker info
Client:
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-buildx" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-buildx: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-compose" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-compose: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-dev" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-dev: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-extension" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-extension: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-init" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-init: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-sbom" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-sbom: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-scan" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-scan: no such file or directory
WARNING: Plugin "/usr/local/lib/docker/cli-plugins/docker-scout" is not valid: failed to fetch metadata: fork/exec /usr/local/lib/docker/cli-plugins/docker-scout: no such file or directory
Server:
ERROR: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
errors pretty printing info

tbd Run the Docker daemon using the 'docker start' command.
```

## k8s.cri.docker.spec.image.build.acr

```
# For those who only need Docker installed for login purposes and don't need the Docker daemon to be running:
# First, execute `az acr login -n $registry --expose-token` to get the access token (password) and the login server.
# Next, use `docker login $acrLoginServer -u 00000000-0000-0000-0000-000000000000`.
# Finally, run `az acr build --registry $registry --image image-sample .` in the Dockerfile location to build and upload the image. 
```

## k8s.cri.docker.spec.image.build.VisualStudio

```
# Open the .sln file in Visual Studio, right click Dockerfile, Build Docker Image
```

TBD since the below images eventually were smaller as seen in the crictl output.

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

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
registry=imageshack
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

/var/log/syslog
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

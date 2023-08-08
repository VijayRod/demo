```
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
```

```
# To create a tagged image that refers to a source image
docker tag ubuntu $registry.azurecr.io/samples/ubuntu

# To list images (after creating the tag)
docker image list
REPOSITORY                             TAG       IMAGE ID       CREATED       SIZE
ubuntu                                 latest    5a81c4b8502e   4 weeks ago   77.8MB
imageshack.azurecr.io/samples/ubuntu   latest    5a81c4b8502e   4 weeks ago   77.8MB
```

```
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

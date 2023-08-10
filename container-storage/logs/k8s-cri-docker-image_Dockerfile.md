```
# Dockerfile
FROM debian:latest
WORKDIR /app
RUN touch myfile
```

```
# To build the image
docker build -t mydebian .
docker image list | grep mydebian
```

```
# To cleanup
rm Dockerfile
```

- https://docs.docker.com/engine/reference/builder/

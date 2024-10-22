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
- https://docs.docker.com/engine/reference/builder/

## docker.install

```
# Execute it in a laptop instead of a containerd worker node
apt update && apt install docker.io -y
```

### docker.install.error The following packages have unmet dependencies: moby-containerd : Conflicts: containerd

```
# Execute it in a laptop instead of a containerd worker node, else get the docker install error:
The following packages have unmet dependencies:
 moby-containerd : Conflicts: containerd
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

## docker.error.Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running

```
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

# If you don't need docker, see the section on az acr login -n imageshack --expose-token

## docker

```
apt update && apt install docker.io -y # Execute it in a laptop instead of a containerd worker node

$HOME/.docker/config.json
```

### docker.install.wsl

```
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

### docker.install.error The following packages have unmet dependencies: moby-containerd : Conflicts: containerd

```
# Execute it in a laptop instead of a containerd worker node, else get the docker install error:
The following packages have unmet dependencies:
 moby-containerd : Conflicts: containerd
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

## docker.spec.daemon.error.Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running

```
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

## docker.spec.image.build.acr

```
# For those who only need Docker installed for login purposes and don't need the Docker daemon to be running, see the section on az acr login -n imageshack --expose-token
```

## docker.spec.image.build.VisualStudio

```
# Open the .sln file in Visual Studio, right click Dockerfile, Build Docker Image
```

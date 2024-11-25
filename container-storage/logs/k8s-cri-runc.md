## runc

- https://github.com/opencontainers/runc: runc is a CLI tool for spawning and running containers on Linux according to the OCI specification.
- https://kubernetes.io/blog/2019/02/11/runc-and-cve-2019-5736/#what-is-runc: runc is the low-level tool which does the heavy lifting of spawning a Linux container. Other tools like Docker, Containerd, and CRI-O sit on top of runc to deal with things like data formatting and serialization, but runc is at the heart of all of these systems. Kubernetes in turn sits on top of those tools, and so while no part of Kubernetes itself is vulnerable, most Kubernetes installations are using runc under the hood.
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd: To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set. [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]. SystemdCgroup = true

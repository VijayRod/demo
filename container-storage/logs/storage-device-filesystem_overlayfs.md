## storage-device-filesystem_overlayfs

```
root@aks-nodepool1-33178142-vmss000000:/# df -h
overlay         124G   24G  101G  20% /run/containerd/io.containerd.runtime.v2.task/k8s.io/2a1be93f6966eb4a720ccadb38c09d4d773302f6d153faf92b131803e41989e0/rootfs
overlay         124G   24G  101G  20% /run/containerd/io.containerd.runtime.v2.task/k8s.io/e502f81b1969bc797831e897c8b7e6f19d3d26383fef50eabfe4bc87c04bbb28/rootfs
```

- https://lwn.net/Kernel/Index/#Overlayfs
- https://www.martinheinz.dev/blog/44: Deep Dive into Docker Internals - Union Filesystem
- https://jvns.ca/blog/2019/11/18/how-containers-work--overlayfs/
- https://blog.codefarm.me/2021/11/26/linux-overlayfs-and-container/
- https://docs.docker.com/engine/storage/containerd/: overlay2 driver (alternative is containerd snapshotters)
- https://github.com/containerd/fuse-overlayfs-snapshotter

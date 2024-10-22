```
crictl image list
crictl inspecti imageshack.azurecr.io/image22gacrtasks:v1

root@aks-nodepool1-74128781-vmss000001:/# crictl rmi nginx
Deleted: docker.io/library/nginx:latest

root@aks-nodepool1-74128781-vmss000001:/# crictl pull nginx
Image is up to date for sha256:3b25b682ea82b2db3cc4fd48db818be788ee3f902ac7378090cf2624ec2442df
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
- https://github.com/containerd/containerd/blob/main/docs/cri/crictl.md
- https://github.com/containerd/containerd/blob/main/pkg/cri/server/image_pull.go
- https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling#pull-crictl

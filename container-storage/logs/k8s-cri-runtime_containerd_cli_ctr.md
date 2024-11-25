```
# The ctr commands can be run in both Linux and Windows nodes.
## Linux: root@aks-nodepool1-74128781-vmss000000:/# ctr ns ls
## Windows: azureuser@aksnp201900000O C:\Users\azureuser>ctr -n k8s.io image list "name~=mcr.microsoft.com/oss/kubernetes" -q

ctr help

root@aks-nodepool1-74128781-vmss000000:/# ctr version
Client:
  Version:  1.7.22-1
  Revision: 7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c
  Go version: go1.21.12
Server:
  Version:  1.7.22-1
  Revision: 7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c
  UUID: 7c322dee-68ab-486a-b920-d1da523a8727

root@aks-nodepool1-74128781-vmss000000:/# ctr ns ls
NAME    LABELS
default
k8s.io

ctr -n k8s.io container list
CONTAINER                                                           IMAGE                                          RUNTIME
080e846f519dea600ac80fe0c692930f0a348e8f2120eb0118cfa06ef53eafa5    mcr.microsoft.com/oss/kubernetes/pause:3.6                                                io.containerd.runc.v2
091b5165f011620100907f23ba136dffea19211538614804851933a9774c28c3    mcr.microsoft.com/oss/kubernetes-csi/csi-node-driver-registrar:v2.10.1
...

azureuser@aksnp201900000O C:\Users\azureuser>ctr -n k8s.io image list "name~=mcr.microsoft.com/oss/kubernetes" -q
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.26.4
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.26.5
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.27.1
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi@sha256:63c...

ctr -n k8s.io plugins list # List containerd plugins in kubernetes namespace.
TYPE                                   ID                       PLATFORMS      STATUS
io.containerd.snapshotter.v1           aufs                     linux/amd64    skip
io.containerd.event.v1                 exchange                 -              ok
io.containerd.internal.v1              opt                      -              ok
io.containerd.warning.v1               deprecations             -              ok
io.containerd.snapshotter.v1           blockfile                linux/amd64    skip
io.containerd.snapshotter.v1           btrfs                    linux/amd64    skip
...

ctr events # containerd events
2024-10-23 18:15:14.919361592 +0000 UTC k8s.io /tasks/exec-added {"container_id":"bc5f6c2074eae60887bb8af8852e3fe45ed58cd6ca3f5d40d28245d8e55a4adb","exec_id":"72da6c7db42e9b74be12cf958891e33b7b9a519a3875c0dbf66ec3b3f41f911e"}
2024-10-23 18:15:14.939292576 +0000 UTC k8s.io /tasks/exec-started {"container_id":"bc5f6c2074eae60887bb8af8852e3fe45ed58cd6ca3f5d40d28245d8e55a4adb","exec_id":"72da6c7db42e9b74be12cf958891e33b7b9a519a3875c0dbf66ec3b3f41f911e","pid":1523369}
2024-10-23 18:15:14.94376525 +0000 UTC k8s.io /tasks/exit {"container_id":"bc5f6c2074eae60887bb8af8852e3fe45ed58cd6ca3f5d40d28245d8e55a4adb","id":"72da6c7db42e9b74be12cf958891e33b7b9a519a3875c0dbf66ec3b3f41f911e","pid":1523369,"exited_at":{"seconds":1729678514,"nanos":943747450}}
...
```

- https://pkg.go.dev/github.com/containerd/containerd/cmd/ctr
- https://github.com/containerd/containerd/blob/main/docs/getting-started.md#interacting-with-containerd-via-cli
- https://github.com/projectatomic/containerd/blob/master/docs/cli.md
- https://computingforgeeks.com/interact-with-containerd-runtime-in-kubernetes/: ctr is unsupported debug and administrative client for interacting with the containerd daemon.

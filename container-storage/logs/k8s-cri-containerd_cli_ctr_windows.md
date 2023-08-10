```
# azureuser@aksnp201900000O C:\Users\azureuser>ctr -n k8s.io image list "name~=mcr.microsoft.com/oss/kubernetes" -q
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.26.4
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.26.5
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.27.1
mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi@sha256:63c...
```

- https://pkg.go.dev/github.com/containerd/containerd/cmd/ctr
- https://github.com/containerd/containerd/blob/main/docs/getting-started.md#interacting-with-containerd-via-cli
- https://github.com/projectatomic/containerd/blob/master/docs/cli.md

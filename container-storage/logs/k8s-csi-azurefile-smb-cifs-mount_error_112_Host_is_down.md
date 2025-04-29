- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files-troubleshoot-linux-smb#dns-account-migration: dmesg logs...
- https://github.com/Azure/AKS/issues/2678#issuecomment-997135485
  - Host is down error could be due to azure file account migration...
  - IP will not change with Azure Files NFS.

```
# csi driver log
I utils.go:101] GRPC call: /csi.v1.Node/NodePublishVolume
E utils.go:106] GRPC error: rpc error: code = Internal desc = failed to stat file /var/lib/kubelet/pods/redactp-1111-1111-1111-111111111111/volumes/kubernetes.io~csi/my-pvname/mount: lstat /var/lib/kubelet/pods/redactp-1111-1111-1111-111111111111/volumes/kubernetes.io~csi/my-pvname/mount: host is down
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files-troubleshoot-linux-smb#dns-account-migration: dmesg logs...
- https://github.com/Azure/AKS/issues/2678#issuecomment-997135485
  - Host is down error could be due to azure file account migration...
  - IP will not change with Azure Files NFS.

```
# csi driver log
I utils.go:101] GRPC call: /csi.v1.Node/NodePublishVolume
E utils.go:106] GRPC error: rpc error: code = Internal desc = failed to stat file /var/lib/kubelet/pods/redactp-1111-1111-1111-111111111111/volumes/kubernetes.io~csi/my-pvname/mount: lstat /var/lib/kubelet/pods/redactp-1111-1111-1111-111111111111/volumes/kubernetes.io~csi/my-pvname/mount: host is down

# syslog
Oct 20 16:45:59 aks-genericname kernel: CIFS: VFS: \\genericstorageaccount.file.core.windows.net Send error in SessSetup = -512
Oct 20 16:45:59 aks-genericname kernel: CIFS: Status code returned 0xc000006d STATUS_LOGON_FAILURE
Oct 20 16:45:59 aks-genericname containerd[1705]: time="2025-09-22T05:49:56Z" level=error msg="CreateContainer within sandbox \"474b99d8c8408c20ca8285fd95ecb54f5c2435bb03c12fe1fce6b5f0574ea65a\" for &ContainerMetadata{Name:generic-object,Attempt:0,} failed" error="failed to generate container \"325e3689222845eab85dc9d9537cc2291e11199f98babe43fc2375a80b5a0f4d\" spec: failed to generate spec: failed to stat \"/var/lib/kubelet/pods/69fa9f3e6676a54b3aa4ffc01261625172c0/volumes/kubernetes.io~csi/generic-storage/mount\": stat /var/lib/kubelet/pods/69fa9f3e6676a54b3aa4ffc01261625172c0/volumes/kubernetes.io~csi/generic-storage/mount: host is down"
```

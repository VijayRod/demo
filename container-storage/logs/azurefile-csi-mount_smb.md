The default protocol for Azure File storage classes is SMB, as indicated in https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#dynamic-provisioning-parameters. CIFS, which is also seen in node logs for a file share mount, is a dialect of SMB, as indicated in https://learn.microsoft.com/en-us/windows/win32/fileio/microsoft-smb-protocol-and-cifs-protocol-overview.

```
# Here is a sample output below from a cluster node during pod creation with an Azure File share mount.
Jul  5 09:33:53 aks-nodepool1-51397738-vmss000007 kernel: [ 1183.470774] CIFS: No dialect specified on mount. Default has changed to a more secure dialect, SMB2.1 or later (e.g. SMB3.1.1), from CIFS (SMB1). To use the less secure SMB1 dialect to access old servers which do not support SMB3.1.1 (or even SMB3 or SMB2.1) specify vers=1.0 on mount.
Jul  5 09:33:53 aks-nodepool1-51397738-vmss000007 kernel: [ 1183.470777] CIFS: Attempting to mount \\fe009272cfd2b4a3d8340d5.file.core.windows.net\pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2
```

```
kubectl describe pv | grep VolumeHandle
    VolumeHandle:      mc_rg27_aks_swedencentral#ff784ce8f4cfc4a7fa78fab#pvc-f3a69a2f-afdb-4ce6-b326-3615302e50f8###default

mkdir /tmp/test
sudo mount -v -t cifs //ff784ce8f4cfc4a7fa78fab.file.core.windows.net/pvc-f3a69a2f-afdb-4ce6-b326-3615302e50f8 /tmp/test -o  username=ff784ce8f4cfc4a7fa78fab,password=accountkey,dir_mode=0777,file_mode=0777,cache=strict,actimeo=30
ls /tmp/test
umount /tmp/test
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md#smb
- https://linux.die.net/man/8/mount.cifs

For scenarios where bandwidth is not an issue, but there is latency in seeing files in the same share from a pod on a different node, consider adjusting the cache attributes to improve data synchronization. Set the cache attributes acregmax=0 and acdirmax=30 and remove the cache duration actimeo=30 from the mount options in the persistent volume (PV) or storage class. After making these changes, restart the pods to ensure proper functionality. The below test was conducted using the default SMB protocol.

```
# In bash terminal 1
kubectl exec -it fluentd-elasticsearch-9s5cn -- dd if=/dev/zero of=/mnt/azure/myfile$(date -Iseconds).img bs=4k iflag=fullblock,count_bytes count=4G

# In bash terminal 2
kubectl exec -it fluentd-elasticsearch-9s5cn -- ls -l /mnt/azure | grep myfile
kubectl exec -it fluentd-elasticsearch-xgh2v -- ls -l /mnt/azure | grep myfile
```

As the file size increases, the output temporarily shows a file size of 0 or a different value in the second pod, which runs on a different node but uses the same file share. This indicates a data synchronization delay.

```
-rwxrwxrwx 1 root root 1660809216 Jul 19 13:22 myfile2023-07-19T13:22:19+00:00.img
-rwxrwxrwx 1 root root          0 Jul 19 13:22 myfile2023-07-19T13:22:19+00:00.img
```

To resolve this, add the following lines and remove actimeo if present. Afterward, restart the pods. As the file size increases, we see the file size values should be almost the same.

```
  mountOptions: 
    - acregmax=0
    - acdirmax=30
    
-rwxrwxrwx 1 root root  684658688 Jul 19 13:35 myfile2023-07-19T13:35:07+00:00.img
-rwxrwxrwx 1 root root  631242752 Jul 19 13:35 myfile2023-07-19T13:35:07+00:00.img
```

- https://learn.microsoft.com/en-us/azure/azure-netapp-files/performance-linux-mount-options
- https://blogs.sap.com/2015/11/20/performance-impact-of-disabling-nfs-attribute-caching/
- https://linux.die.net/man/5/nfs
- https://linux.die.net/man/8/mount.cifs
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/azurefile.go

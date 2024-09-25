Scenario: File edits made through the blob (fuse) container are not immediately visible in the associated pod volume. For instance, edits can be performed in Storage Explorer by either double-clicking the file or selecting the file and clicking "Open", then updating the file.

- Environment: This pertains to a pod within an AKS cluster configured with --enable-blob-driver, using either a static or dynamic blobfuse volume.

- Root Cause Analysis (RCA): The issue stems from the local page cache at the node/pod level.

- Temporary Mitigation: To address this issue temporarily, ensure that blob file updates become visible in the pod by deleting the local cache on the node using the command associated with /proc/sys/vm/drop_caches.

- Solution: To resolve this, consider using the following configuration in a custom storage class for dynamic volumes or in a static persistent volume to disable the kernel page cache. Keep in mind that disabling the kernel cache may lead to increased calls to Azure Storage, potentially impacting cost and performance. You can verify the presence of these options using kubectl get pv -oyaml.

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azureblob-fuse-premium2
provisioner: blob.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
mountOptions:
  - -o allow_other
  - --cancel-list-on-mount-seconds=10  # prevent billing charges on mounting
  - --log-level=LOG_WARNING
  - --file-cache-timeout-in-seconds=0 # this
  - --use-attr-cache=false # this
  - --cache-size-mb=0 # this
  - -o direct_io # this
  - -o attr_timeout=0 # this too
  - -o entry_timeout=0 # this too
  - -o negative_timeout=0 # this too

kubectl exec -it mypod2 -- cat /mnt/blob/empty.txt
```

- https://github.com/Azure/azure-storage-fuse: Blobfuse2 supports both reads and writes however, it does not guarantee continuous sync of data written to storage using other APIs or other mounts of Blobfuse2. For data integrity it is recommended that multiple sources do not modify the same blob/file.
- https://github.com/Azure/azure-storage-fuse#frequently-asked-questions: Why am I not able to see the updated contents of file(s), which were updated through means other than Blobfuse2 mount?...
- https://github.com/Azure/azure-storage-fuse/issues/1235#issuecomment-1700767145

```
# Random mount failure likely because its taking too long to set the volume ownership
# We observe that fsGroup in the pod securityContext is indeed being set. This can cause the blob CSI driver to take a long time to set the volume ownership, which involves changing the permissions on every file. The duration depends on the number of blobs in the storage account and may have led to the first aborted operation with a context deadline exceeded. How many blobs are in the storage account blob container?
# Can the customer try removing fsGroup and using fsGroupChangePolicy instead to see if the issue persists? Maybe the customer could try this in a test environment first.

# logs
# Could you please share the csi-blob-node pod logs, particularly the blob containers, from when this issue occurred?
# Could the customer please reproduce the issue without mitigating (without restarting the csi-blob-node pod) and send the full (csi-blob-node) pod logs from pod creation until 10 minutes after the first failed NodeStageVolume? Additionally, could the customer provide the pod definition to check if they are specifying an fsGroup in the securityContext of the pod?

2025-01-05 05:22 I0106 05:22    6576 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
2025-01-05 05:22 E0206 05:22    6525 utils.go:109] GRPC error: rpc error: code = Aborted desc = An operation with the given Volume ID MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb already exists
2025-01-05 05:22 I0106 05:22    6525 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/11111/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["nconnect=4"],"volume_mount_group":"0"}},"access_mode":{"mode":5}},"volume_context":{"containerName":"storagecontainer","protocol":"nfs","resourceGroup":"mc_rg_aks_swedencentral","server":"faf7a164ba5d246afaf9fa6.privatelink.blob.core.windows.net","storageAccount":"faf7a164ba5d246afaf9fa6"},"volume_id":"MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb"}
2025-01-05 05:22 I0106 05:22    6525 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
2025-01-05 05:22 W0106 05:22    6231 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/11111/globalmount and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699

# test
# tbd ~11k blobs in the file share
```

- https://github.com/kubernetes/kubernetes/issues/67014#issuecomment-413546283: fsGroup option. Today, I just removed and started pod again, it started in 1 minutes. I guess on each disk attach, its trying to change group id of all files which is in disk and this causing to time out error.
- https://github.com/kubernetes/kubernetes/issues/67014#issuecomment-589915496: chown slowness. pod run as root. set supplementalGroup to match the gid of the volume (safer since not run as root)
- https://github.com/kubernetes/kubernetes/issues/69699: fsgroup setting is recursively set on every mount. This can make mount very slow if the volume has many files
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods: For large volumes, checking and changing ownership and permissions can take a lot of time, slowing Pod startup.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error5: ApplyFSGroup failed for vol. To resolve this error, we recommend that you set fsGroupChangePolicy: "OnRootMismatch" in the securityContext of a Deployment, a StatefulSet or a pod.

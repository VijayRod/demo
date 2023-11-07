```
kubectl describe pv | grep VolumeHandle
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5

# volume_id in the GRPC request
kubectl get po -owide
kubectl get po -l app=csi-azuredisk-node -A -owide | grep vmss000000
kubectl logs -n kube-system csi-azuredisk-node-wf47f -c azuredisk | grep "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"
I0914 10:36:53.289446       1 utils.go:77] GRPC call: /csi.v1.Node/NodeStageVolume
I0914 10:36:53.289460       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
I0914 10:36:55.796672       1 utils.go:77] GRPC call: /csi.v1.Node/NodePublishVolume
I0914 10:36:55.796684       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","target_path":"/var/lib/kubelet/pods/8c896175-ee76-470c-bc0f-9dfe25a4cdd9/volumes/kubernetes.io~csi/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
```

- https://kubernetes.io/docs/concepts/storage/volumes/: volumeHandle: A string value...
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/: VolumeHandle:      44830fa8-79b4-406b-8b58-621ba25353fd
- https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/: volumeHandle: existingVolumeName
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/azurefile.go: get file share info according to volume id

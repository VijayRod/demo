```
# To create the resources with the YAML links
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

# Alternatively, use the following YAML to create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: managed-csi-premium
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
      name: nginx-azuredisk
      command:
        - "/bin/sh"
        - "-c"
        - while true; do echo $(date) >> /mnt/azuredisk/outfile; sleep 1; done
      volumeMounts:
        - name: azuredisk01
          mountPath: "/mnt/azuredisk"
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
```

```
# kubectl get po,pv,pvc
NAME                  READY   STATUS    RESTARTS   AGE
pod/nginx-azuredisk   1/1     Running   0          64s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
persistentvolume/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e   10Gi       RWO            Delete           Bound    default/pvc-azuredisk   managed-csi             61s
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Bound    pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e   10Gi       RWO
managed-csi    66s

# kubectl get po -owide
NAME              READY   STATUS    RESTARTS   AGE     IP           NODE                                NOMINATED NODE   READINESS GATES
nginx-azuredisk   1/1     Running   0          2m49s   10.244.1.4   aks-nodepool1-51397738-vmss00000o   <none>           <none>
                
# kubectl exec nginx-azuredisk -it -- df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/sdc                  9.7G     32.0K      9.7G   0% /mnt/azuredisk

# kubectl exec nginx-azuredisk -it -- mount | grep pvc
/dev/sdc on /mnt/azuredisk type ext4 (rw,relatime)

# kubectl exec nginx-azuredisk -it -- mount -t ext4
/dev/sdc on /mnt/azuredisk type ext4 (rw,relatime)

# root@aks-nodepool1-51397738-vmss00000O:/# mount | grep pvc
/dev/sdc on /var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount type ext4 (rw,relatime)

# /var/log/syslog
Jul 26 10:36:16 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:16.723974    1701 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") " pod="default/nginx-azuredisk"
Jul 26 10:36:16 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:16.732320    1701 operation_generator.go:1582] "Controller attach succeeded for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") device path: \"\"" pod="default/nginx-azuredisk"
Jul 26 10:36:16 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:16.824901    1701 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") " pod="default/nginx-azuredisk"
Jul 26 10:36:16 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:16.825266    1701 operation_generator.go:616] "MountVolume.WaitForAttach entering for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") DevicePath \"\"" pod="default/nginx-azuredisk"
Jul 26 10:36:16 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:16.829852    1701 operation_generator.go:626] "MountVolume.WaitForAttach succeeded for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") DevicePath \"csi-8f86e7de1d16ae32edce11f0f109e31eca029dd1ddbb4289e0769c849db9c83b\"" pod="default/nginx-azuredisk"
Jul 26 10:36:19 aks-nodepool1-51397738-vmss00000O kernel: [  426.321637] EXT4-fs (sdc): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
Jul 26 10:36:19 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:19.151256    1701 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount\"" pod="default/nginx-azuredisk"
Jul 26 10:36:19 aks-nodepool1-51397738-vmss00000O kubelet[1701]: I0726 10:36:19.161298    1701 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e\") pod \"nginx-azuredisk\" (UID: \"3e3fc466-5db0-499a-b678-0c6a80d58f38\") " pod="default/nginx-azuredisk"

# kubectl get po -n kube-system -owide | grep azuredisk | grep vmss00000o
csi-azuredisk-node-pqm7v              3/3     Running   0             21m   10.224.0.5    aks-nodepool1-51397738-vmss00000o   <none>           <none>

# kubectl logs -n kube-system csi-azuredisk-node-pqm7v -c azuredisk
I0726 10:36:16.845785       1 utils.go:77] GRPC call: /csi.v1.Node/NodeStageVolume
I0726 10:36:16.845800       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690367309246-7353-disk.csi.azure.com"},"volume_id":"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e"}
I0726 10:36:17.836360       1 azure_common_linux.go:185] azureDisk - found /dev/disk/azure/scsi1/lun0 by sdc under /dev/disk/azure/scsi1/
I0726 10:36:17.836395       1 nodeserver.go:116] NodeStageVolume: perf optimization is disabled for /dev/disk/azure/scsi1/lun0. perfProfile none accountType StandardSSD_LRS
I0726 10:36:17.836883       1 nodeserver.go:157] NodeStageVolume: formatting /dev/disk/azure/scsi1/lun0 and mounting at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount with mount options([])
I0726 10:36:17.836900       1 mount_linux.go:567] Attempting to determine if disk "/dev/disk/azure/scsi1/lun0" is formatted using blkid with args: ([-p -s TYPE -s PTTYPE -o export /dev/disk/azure/scsi1/lun0])
I0726 10:36:17.840879       1 mount_linux.go:570] Output: ""
I0726 10:36:17.840908       1 mount_linux.go:529] Disk "/dev/disk/azure/scsi1/lun0" appears to be unformatted, attempting to format as type: "ext4" with options: [-F -m0 /dev/disk/azure/scsi1/lun0]
I0726 10:36:19.104351       1 mount_linux.go:539] Disk successfully formatted (mkfs): ext4 - /dev/disk/azure/scsi1/lun0 /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount
I0726 10:36:19.104521       1 mount_linux.go:557] Attempting to mount disk /dev/disk/azure/scsi1/lun0 in ext4 format at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount
I0726 10:36:19.104984       1 mount_linux.go:245] Detected OS without systemd
I0726 10:36:19.104995       1 mount_linux.go:220] Mounting cmd (mount) with arguments (-t ext4 -o defaults /dev/disk/azure/scsi1/lun0 /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount)
I0726 10:36:19.130595       1 nodeserver.go:161] NodeStageVolume: format /dev/disk/azure/scsi1/lun0 and mounting at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount successfully.
I0726 10:36:19.132799       1 mount_linux.go:567] Attempting to determine if disk "/dev/disk/azure/scsi1/lun0" is formatted using blkid with args: ([-p -s TYPE -s PTTYPE -o export /dev/disk/azure/scsi1/lun0])
I0726 10:36:19.148789       1 mount_linux.go:570] Output: "DEVNAME=/dev/disk/azure/scsi1/lun0\nTYPE=ext4\n"
I0726 10:36:19.148836       1 resizefs_linux.go:139] ResizeFs.needResize - checking mounted volume /dev/disk/azure/scsi1/lun0
I0726 10:36:19.150221       1 resizefs_linux.go:143] Ext size: filesystem size=10737418240, block size=4096
I0726 10:36:19.150744       1 resizefs_linux.go:158] Volume /dev/disk/azure/scsi1/lun0: device size=10737418240, filesystem size=10737418240, block size=4096
I0726 10:36:19.150765       1 utils.go:84] GRPC response: {}
I0726 10:36:19.158956       1 utils.go:77] GRPC call: /csi.v1.Node/NodePublishVolume
I0726 10:36:19.158969       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount","target_path":"/var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690367309246-7353-disk.csi.azure.com"},"volume_id":"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e"}
I0726 10:36:19.159382       1 nodeserver.go:279] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount at /var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount
I0726 10:36:19.159399       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount /var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount)
I0726 10:36:19.160242       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount /var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount)
I0726 10:36:19.161019       1 nodeserver.go:284] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/6dc3cd53eaf051e43ec0e3d86a0239a2271526306597ae68fee5a4a0cbffea43/globalmount at /var/lib/kubelet/pods/3e3fc466-5db0-499a-b678-0c6a80d58f38/volumes/kubernetes.io~csi/pvc-0e88eb2c-7b6d-4acf-a3ae-567c6628632e/mount successfully
I0726 10:36:19.161045       1 utils.go:84] GRPC response: {}
```

```
# To cleanup
kubectl delete po nginx-azuredisk
kubectl delete pvc pvc-azuredisk
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi
- https://github.com/Azure/AKS/tree/master/vhd-notes

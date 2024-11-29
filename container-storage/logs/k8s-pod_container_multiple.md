```
kubectl delete po multiple
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: multiple
spec:
  containers:
  - image: nginx
    name: nginx
  - command:
    - sh
    - -c
    - sleep 1d
    image: busybox
    name: busybox
EOF
kubectl get po -w

root@aks-nodepool1-23707431-vmss000000:/# cat /var/log/syslog | grep multiple
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.449865    2983 kubelet.go:2433] "SyncLoop ADD" source="api" pods=["default/multiple"]
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.449931    2983 topology_manager.go:215] "Topology Admit Handler" podUID="ecf6beca-4e57-4562-8f89-b6e72312b3fd" podNamespace="default" podName="multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.450269    2983 util.go:30] "No sandbox for pod can be found. Need to start a new one" pod="default/multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.597271    2983 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-k8dc8\" (UniqueName: \"kubernetes.io/projected/ecf6beca-4e57-4562-8f89-b6e72312b3fd-kube-api-access-k8dc8\") pod \"multiple\" (UID: \"ecf6beca-4e57-4562-8f89-b6e72312b3fd\") " pod="default/multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.697977    2983 reconciler_common.go:231] "operationExecutor.MountVolume started for volume \"kube-api-access-k8dc8\" (UniqueName: \"kubernetes.io/projected/ecf6beca-4e57-4562-8f89-b6e72312b3fd-kube-api-access-k8dc8\") pod \"multiple\" (UID: \"ecf6beca-4e57-4562-8f89-b6e72312b3fd\") " pod="default/multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.720403    2983 operation_generator.go:721] "MountVolume.SetUp succeeded for volume \"kube-api-access-k8dc8\" (UniqueName: \"kubernetes.io/projected/ecf6beca-4e57-4562-8f89-b6e72312b3fd-kube-api-access-k8dc8\") pod \"multiple\" (UID: \"ecf6beca-4e57-4562-8f89-b6e72312b3fd\") " pod="default/multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:25.774645    2983 util.go:30] "No sandbox for pod can be found. Need to start a new one" pod="default/multiple"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:25.775569203Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:multiple,Uid:ecf6beca-4e57-4562-8f89-b6e72312b3fd,Namespace:default,Attempt:0,}"
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:25.940422419Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:multiple,Uid:ecf6beca-4e57-4562-8f89-b6e72312b3fd,Namespace:default,Attempt:0,} returns sandbox id \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\""
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:26.509801    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361"}
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:27.512522    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b"}
Nov 29 18:33:28 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:28.515993    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c"}
Nov 29 18:34:33 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:34:33.818482    2983 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="default/multiple" podStartSLOduration=66.945167598 podStartE2EDuration="1m8.818440372s" podCreationTimestamp="2024-11-29 16:33:25 +0000 UTC" firstStartedPulling="2024-11-29 16:33:25.942453883 +0000 UTC m=+23257.472205557" lastFinishedPulling="2024-11-29 16:33:27.815726657 +0000 UTC m=+23259.345478331" observedRunningTime="2024-11-29 16:33:28.533354264 +0000 UTC m=+23260.063106038" watchObservedRunningTime="2024-11-29 16:34:33.818440372 +0000 UTC m=+23325.348192146"

# sandbox containerid (two CreateContainer)
root@aks-nodepool1-23707431-vmss000000:/# cat /var/log/syslog | grep 9782e0c
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 systemd[1]: Started libcontainer container 9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361.
Nov 29 18:33:25 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:25.940422419Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:multiple,Uid:ecf6beca-4e57-4562-8f89-b6e72312b3fd,Namespace:default,Attempt:0,} returns sandbox id \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\""
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:26.509801    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361"}
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:26.843221885Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for container &ContainerMetadata{Name:nginx,Attempt:0,}"
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:26.879149322Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b\""
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:27.817086800Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for container &ContainerMetadata{Name:busybox,Attempt:0,}"
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:27.851830599Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for &ContainerMetadata{Name:busybox,Attempt:0,} returns container id \"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c\""

root@aks-nodepool1-23707431-vmss000000:/# cat /var/log/syslog | grep ee805
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:26.879149322Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b\""
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:26.880145653Z" level=info msg="StartContainer for \"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b\""
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 systemd[1]: Started libcontainer container ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b.
Nov 29 18:33:26 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:26.948809726Z" level=info msg="StartContainer for \"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b\" returns successfully"
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:27.512522    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"ee80536be282db884ee5f5a7db9fbc9d2c4fad4ae80569175641377743b3716b"}

root@aks-nodepool1-23707431-vmss000000:/# cat /var/log/syslog | grep 24d55e
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:27.851830599Z" level=info msg="CreateContainer within sandbox \"9782e0cf6742898144c14978eabdbed4af963d2f8eb9d857d4832d98986cf361\" for &ContainerMetadata{Name:busybox,Attempt:0,} returns container id \"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c\""
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:27.852646325Z" level=info msg="StartContainer for \"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c\""
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 systemd[1]: Started libcontainer container 24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c.
Nov 29 18:33:27 aks-nodepool1-23707431-vmss000000 containerd[2699]: time="2024-11-29T18:33:27.907950775Z" level=info msg="StartContainer for \"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c\" returns successfully"
Nov 29 18:33:28 aks-nodepool1-23707431-vmss000000 kubelet[2983]: I1129 18:33:28.515993    2983 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/multiple" event={"ID":"ecf6beca-4e57-4562-8f89-b6e72312b3fd","Type":"ContainerStarted","Data":"24d55eabe04151fa7766c73e00018c36e99e28faa35299cf8f7d01b5bcfd792c"}
```

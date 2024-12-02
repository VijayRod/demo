```
# See the section on k8s-cni.azure.networkProfile networkoverlay
```

```
# sandbox and actual container Ids (create, delete)

kubectl run nginx --image=nginx
kubectl delete po nginx

# sandbox containerid 3cfe7b (pod create)
root@aks-np2-39852331-vmss000000:/# cat /var/log/syslog | grep 3cfe7b
Nov 29 18:13:10 aks-np2-39852331-vmss000000 systemd[1]: Started libcontainer container 3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17.
Nov 29 18:13:10 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:10.764041708Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:nginx,Uid:5da5612b-9738-493c-af51-a213072997f6,Namespace:default,Attempt:0,} returns sandbox id \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.923963    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17"}
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.653242786Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for container &ContainerMetadata{Name:nginx,Attempt:0,}"
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.682692569Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""

# actual containerid c65a36 (pod create)
root@aks-np2-39852331-vmss000000:/# cat /var/log/syslog | grep c65a36
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.682692569Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.683197669Z" level=info msg="StartContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:13:11 aks-np2-39852331-vmss000000 systemd[1]: Started libcontainer container c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab.
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.737579537Z" level=info msg="StartContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" returns successfully"
Nov 29 18:13:11 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:11.927120    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"}

# default/nginx (pod create)
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.314127    2775 kubelet.go:2433] "SyncLoop ADD" source="api" pods=["default/nginx"]
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.314355    2775 util.go:30] "No sandbox for pod can be found. Need to start a new one" pod="default/nginx"
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.429871    2775 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-jv6dl\" (UniqueName: \"kubernetes.io/projected/5da5612b-9738-493c-af51-a213072997f6-kube-api-access-jv6dl\") pod \"nginx\" (UID: \"5da5612b-9738-493c-af51-a213072997f6\") " pod="default/nginx"
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.530843    2775 reconciler_common.go:231] "operationExecutor.MountVolume started for volume \"kube-api-access-jv6dl\" (UniqueName: \"kubernetes.io/projected/5da5612b-9738-493c-af51-a213072997f6-kube-api-access-jv6dl\") pod \"nginx\" (UID: \"5da5612b-9738-493c-af51-a213072997f6\") " pod="default/nginx"
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.555036    2775 operation_generator.go:721] "MountVolume.SetUp succeeded for volume \"kube-api-access-jv6dl\" (UniqueName: \"kubernetes.io/projected/5da5612b-9738-493c-af51-a213072997f6-kube-api-access-jv6dl\") pod \"nginx\" (UID: \"5da5612b-9738-493c-af51-a213072997f6\") " pod="default/nginx"
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.634451    2775 util.go:30] "No sandbox for pod can be found. Need to start a new one" pod="default/nginx"
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.923963    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17"}
Nov 29 18:13:11 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:11.927120    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"}
Nov 29 18:13:11 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:11.940322    2775 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="default/nginx" podStartSLOduration=1.053410939 podStartE2EDuration="1.940293018s" podCreationTimestamp="2024-11-29 16:13:10 +0000 UTC" firstStartedPulling="2024-11-29 16:13:10.765063108 +0000 UTC m=+21817.014756659" lastFinishedPulling="2024-11-29 16:13:11.651945187 +0000 UTC m=+21817.901638738" observedRunningTime="2024-11-29 16:13:11.940258918 +0000 UTC m=+21818.189952569" watchObservedRunningTime="2024-11-29 16:13:11.940293018 +0000 UTC m=+21818.189986669"

# default/nginx (pod delete)
root@aks-np2-39852331-vmss000000:/# cat /var/log/syslog | grep nginx
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.242812    2775 kubelet.go:2449] "SyncLoop DELETE" source="api" pods=["default/nginx"]
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.242970    2775 kuberuntime_container.go:770] "Killing container with a grace period" pod="default/nginx" podUID="5da5612b-9738-493c-af51-a213072997f6" containerName="nginx" containerID="containerd://c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab" gracePeriod=30
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.449071    2775 util.go:48] "No ready sandbox for pod can be found. Need to start a new one" pod="default/nginx"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668321    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerDied","Data":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"}
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668322    2775 util.go:48] "No ready sandbox for pod can be found. Need to start a new one" pod="default/nginx"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668339    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerDied","Data":"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17"}
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.687394    2775 kubelet.go:2449] "SyncLoop DELETE" source="api" pods=["default/nginx"]
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.690409    2775 kubelet.go:2443] "SyncLoop REMOVE" source="api" pods=["default/nginx"]

# actual containerid c65a36 (pod delete)
root@aks-np2-39852331-vmss000000:/# cat /var/log/syslog | grep c65a36
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.682692569Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.683197669Z" level=info msg="StartContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:13:11 aks-np2-39852331-vmss000000 systemd[1]: Started libcontainer container c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab.
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.737579537Z" level=info msg="StartContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" returns successfully"
Nov 29 18:13:11 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:11.927120    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"}
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.242970    2775 kuberuntime_container.go:770] "Killing container with a grace period" pod="default/nginx" podUID="5da5612b-9738-493c-af51-a213072997f6" containerName="nginx" containerID="containerd://c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab" gracePeriod=30
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.243415851Z" level=info msg="StopContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" with timeout 30 (s)"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.243705450Z" level=info msg="Stop container \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" with signal quit"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 systemd[1]: cri-containerd-c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab.scope: Deactivated successfully.
Nov 29 18:20:18 aks-np2-39852331-vmss000000 systemd[1]: run-containerd-io.containerd.runtime.v2.task-k8s.io-c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab-rootfs.mount: Deactivated successfully.
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.329810628Z" level=info msg="shim disconnected" id=c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab namespace=k8s.io
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.329856528Z" level=warning msg="cleaning up after shim disconnected" id=c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab namespace=k8s.io
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.345761705Z" level=info msg="StopContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" returns successfully"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.346554404Z" level=info msg="Container to stop \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" must be in running or unknown state, current state \"CONTAINER_EXITED\""
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668292    2775 generic.go:334] "Generic (PLEG): container finished" podID="5da5612b-9738-493c-af51-a213072997f6" containerID="c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab" exitCode=0
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668321    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerDied","Data":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"}
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668354    2775 scope.go:117] "RemoveContainer" containerID="c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.674148738Z" level=info msg="RemoveContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.683015125Z" level=info msg="RemoveContainer for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" returns successfully"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.683167    2775 scope.go:117] "RemoveContainer" containerID="c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.683397225Z" level=error msg="ContainerStatus for \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\" failed" error="rpc error: code = NotFound desc = an error occurred when try to find container \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\": not found"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: E1129 16:20:18.683569    2775 remote_runtime.go:432] "ContainerStatus from runtime service failed" err="rpc error: code = NotFound desc = an error occurred when try to find container \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\": not found" containerID="c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.683600    2775 pod_container_deletor.go:53] "DeleteContainer returned error" containerID={"Type":"containerd","ID":"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab"} err="failed to get container status \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\": rpc error: code = NotFound desc = an error occurred when try to find container \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\": not found"

# sandbox containerid 3cfe7b (pod delete)
root@aks-np2-39852331-vmss000000:/# cat /var/log/syslog | grep 3cfe7b
Nov 29 18:13:10 aks-np2-39852331-vmss000000 systemd[1]: Started libcontainer container 3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17.
Nov 29 18:13:10 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:10.764041708Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:nginx,Uid:5da5612b-9738-493c-af51-a213072997f6,Namespace:default,Attempt:0,} returns sandbox id \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:13:10 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:13:10.923963    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerStarted","Data":"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17"}
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.653242786Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for container &ContainerMetadata{Name:nginx,Attempt:0,}"
Nov 29 18:13:11 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:13:11.682692569Z" level=info msg="CreateContainer within sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"c65a36d4090569f70b6badb5b6127ad773ebd7e5ce18d3872b8e93ee4fb52cab\""
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.346393504Z" level=info msg="StopPodSandbox for \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:20:18 aks-np2-39852331-vmss000000 systemd[1]: run-containerd-io.containerd.grpc.v1.cri-sandboxes-3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17-shm.mount: Deactivated successfully.
Nov 29 18:20:18 aks-np2-39852331-vmss000000 systemd[1]: cri-containerd-3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17.scope: Deactivated successfully.
Nov 29 18:20:18 aks-np2-39852331-vmss000000 systemd[1]: run-containerd-io.containerd.runtime.v2.task-k8s.io-3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17-rootfs.mount: Deactivated successfully.
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.398062631Z" level=info msg="shim disconnected" id=3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17 namespace=k8s.io
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.398267230Z" level=warning msg="cleaning up after shim disconnected" id=3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17 namespace=k8s.io
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.445817963Z" level=info msg="TearDown network for sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" successfully"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:18.445846363Z" level=info msg="StopPodSandbox for \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" returns successfully"
Nov 29 18:20:18 aks-np2-39852331-vmss000000 kubelet[2775]: I1129 18:20:18.668339    2775 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"5da5612b-9738-493c-af51-a213072997f6","Type":"ContainerDied","Data":"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17"}
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.857690649Z" level=info msg="StopPodSandbox for \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.864977499Z" level=info msg="TearDown network for sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" successfully"
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.865000899Z" level=info msg="StopPodSandbox for \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" returns successfully"
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.865421708Z" level=info msg="RemovePodSandbox for \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.865553210Z" level=info msg="Forcibly stopping sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\""
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.871838539Z" level=info msg="TearDown network for sandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" successfully"
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.880808422Z" level=warning msg="Failed to get podSandbox status for container event for sandboxID \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\": an error occurred when try to find sandbox: not found. Sending the event with nil podSandboxStatus."
Nov 29 18:20:38 aks-np2-39852331-vmss000000 containerd[2506]: time="2024-11-29T18:20:38.880872924Z" level=info msg="RemovePodSandbox \"3cfe7b007c290255f1a416b2bd9404604e6ef5967348211d30cd41e00912fe17\" returns successfully"
```

```
# k8s azure-cni linux container create logs

# pod UID
cat /var/log/syslog | grep d02bf488
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:16.613526    2782 topology_manager.go:215] "Topology Admit Handler" podUID="d02bf488-3589-4d20-9dcf-5aee17dac3a7" podNamespace="default" podName="nginx"
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 systemd[1]: Created slice libcontainer container kubepods-besteffort-podd02bf488_3589_4d20_9dcf_5aee17dac3a7.slice.
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:16.622509    2782 reconciler_common.go:258] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-fbgmp\" (UniqueName: \"kubernetes.io/projected/d02bf488-3589-4d20-9dcf-5aee17dac3a7-kube-api-access-fbgmp\") pod \"nginx\" (UID: \"d02bf488-3589-4d20-9dcf-5aee17dac3a7\") " pod="default/nginx"
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:16.723291    2782 reconciler_common.go:231] "operationExecutor.MountVolume started for volume \"kube-api-access-fbgmp\" (UniqueName: \"kubernetes.io/projected/d02bf488-3589-4d20-9dcf-5aee17dac3a7-kube-api-access-fbgmp\") pod \"nginx\" (UID: \"d02bf488-3589-4d20-9dcf-5aee17dac3a7\") " pod="default/nginx"
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:16.753225    2782 operation_generator.go:721] "MountVolume.SetUp succeeded for volume \"kube-api-access-fbgmp\" (UniqueName: \"kubernetes.io/projected/d02bf488-3589-4d20-9dcf-5aee17dac3a7-kube-api-access-fbgmp\") pod \"nginx\" (UID: \"d02bf488-3589-4d20-9dcf-5aee17dac3a7\") " pod="default/nginx"
Dec  2 18:32:16 aks-nodepool1-21231904-vmss000001 containerd[2507]: time="2024-12-02T18:32:16.935963657Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:nginx,Uid:d02bf488-3589-4d20-9dcf-5aee17dac3a7,Namespace:default,Attempt:0,}"
Dec  2 18:32:17 aks-nodepool1-21231904-vmss000001 containerd[2507]: time="2024-12-02T18:32:17.157167764Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:nginx,Uid:d02bf488-3589-4d20-9dcf-5aee17dac3a7,Namespace:default,Attempt:0,} returns sandbox id \"d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a\""
Dec  2 18:32:17 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:17.857120    2782 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"d02bf488-3589-4d20-9dcf-5aee17dac3a7","Type":"ContainerStarted","Data":"d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a"}
Dec  2 18:32:23 aks-nodepool1-21231904-vmss000001 kubelet[2782]: I1202 10:32:23.868371    2782 kubelet.go:2465] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"d02bf488-3589-4d20-9dcf-5aee17dac3a7","Type":"ContainerStarted","Data":"fd152651aaa2c4f3c2e2dff6f3e4696bc04252e745d12492d1538cbef724c5ba"}

cat /var/log/azure-vnet-ipam.log # sandbox id \"d3fd815
2024/12/02 18:32:17 [5223] Acquiring process lock
2024/12/02 18:32:17 [5223] Acquired process lock with timeout value of 10s
2024/12/02 18:32:17 [5223] [cni-ipam] Plugin azure-vnet-ipam version v1.4.56.
2024/12/02 18:32:17 [5223] [cni-ipam] Running on Linux version 5.15.0-1074-azure (buildd@lcy02-amd64-025) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #83-Ubuntu SMP Wed Oct 2 18:14:49 UTC 2024
2024/12/02 18:32:17 [5223] [ipam] Restored state, &{Version:v1.4.56 TimeStamp:2024-12-02 10:31:55.393563946 +0000 UTC AddrSpaces:map[local:0xc0000cb1d0] store:0xc00037eb00 source:<nil> netApi:<nil> Mutex:{state:0 sema:0}}
2024/12/02 18:32:17 [5223] [cni-ipam] Plugin started.
2024/12/02 18:32:17 [5223] [cni-ipam] Processing ADD command with args {ContainerID:d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a Netns:/var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896 IfName:eth0 Args:IgnoreUnknown=1;K8S_POD_NAMESPACE=default;K8S_POD_NAME=nginx;K8S_POD_INFRA_CONTAINER_ID=d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a;K8S_POD_UID=d02bf488-3589-4d20-9dcf-5aee17dac3a7 Path:/opt/cni/bin StdinData:{"cniVersion":"0.3.0","name":"azure","type":"azure-vnet","mode":"transparent","ipsToRouteViaHost":["169.254.20.10"],"ipam":{"type":"azure-vnet-ipam","subnet":"10.224.0.0/16"},"dns":{},"runtimeConfig":{"dns":{}},"windowsSettings":{}}}.
2024/12/02 18:32:17 [5223] [cni-ipam] Read network configuration &{CNIVersion:0.3.0 Name:azure Type:azure-vnet Mode:transparent Master: AdapterName: Bridge: LogLevel: LogTarget: InfraVnetAddressSpace: IPV6Mode: ServiceCidrs: VnetCidrs: PodNamespaceForDualNetwork:[] IPsToRouteViaHost:[169.254.20.10] MultiTenancy:false EnableSnatOnHost:false EnableExactMatchForPodName:false DisableHairpinOnHostInterface:false DisableIPTableLock:false CNSUrl: ExecutionMode: IPAM:{Mode: Type:azure-vnet-ipam Environment: AddrSpace: Subnet:10.224.0.0/16 Address: QueryInterval:} DNS:{Nameservers:[] Domain: Search:[] Options:[]} RuntimeConfig:{PortMappings:[] DNS:{Servers:[] Searches:[] Options:[]}} WindowsSettings:{EnableLoopbackDSR:false HnsTimeoutDurationInSeconds:0} AdditionalArgs:[]}.
2024/12/02 18:32:17 [5223] [ipam] Starting source azure.
2024/12/02 18:32:17 [5223] [ipam] Refreshing address source.
2024/12/02 18:32:17 [5223] [Utils] Initializing HTTP client with connection timeout: 10, response header timeout: 10
2024/12/02 18:32:17 [5223] [ipam] Wireserver call http://168.63.129.16/machine/plugins?comp=nmagent&type=getinterfaceinfov1 to retrieve IP List
2024/12/02 18:32:17 [5223] [ipam] xml name received:{ Interfaces} interfaces:1
2024/12/02 18:32:17 [5223] [ipam] processing interface:eth0 IsPrimary:true macAddress:7c1e523fa782 ips:1
2024/12/02 18:32:17 [5223] [ipam] Number of IPAddress found in ipsubnet 10.224.0.0/16: 29
2024/12/02 18:32:17 [5223] [ipam] got 28 addresses from interface eth0, subnet 10.224.0.0/16
2024/12/02 18:32:17 [5223] [ipam] merging address space
2024/12/02 18:32:17 [5223] [ipam] saving ipam state.
2024/12/02 18:32:17 [5223] [ipam] Save succeeded.
2024/12/02 18:32:17 [5223] [ipam] Requesting address with address: options:map[azure.address.id:d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a].
2024/12/02 18:32:17 [5223] [ipam] Address request completed with address:10.224.0.39/16
2024/12/02 18:32:17 [5223] [ipam] saving ipam state.
2024/12/02 18:32:17 [5223] [ipam] Save succeeded.
2024/12/02 18:32:17 [5223] [cni-ipam] Allocated address 10.224.0.39/16.
2024/12/02 18:32:17 [5223] [cni-ipam] ADD command completed with result:&{CNIVersion:1.0.0 Interfaces:[] IPs:[{Interface:<nil> Address:{IP:10.224.0.39 Mask:ffff0000} Gateway:10.224.0.1}] Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} GW:10.224.0.1}] DNS:{Nameservers:[168.63.129.16] Domain: Search:[] Options:[]}} err:<nil>.
2024/12/02 18:32:17 [5223] [cni-ipam] Plugin stopped.
2024/12/02 18:32:17 [5223] Released process lock

cat /var/log/azure-vnet.log
2024/12/02 18:32:16 [5205] CNI_COMMAND environment variable set to ADD
2024/12/02 18:32:16 [5205] Acquiring process lock
2024/12/02 18:32:16 [5205] Acquired process lock with timeout value of 10s
2024/12/02 18:32:16 [5205] Connected to telemetry service
2024/12/02 18:32:16 [5205] [cni-net] Plugin azure-vnet version v1.4.56.
2024/12/02 18:32:16 [5205] [cni-net] Running on Linux version 5.15.0-1074-azure (buildd@lcy02-amd64-025) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #83-Ubuntu SMP Wed Oct 2 18:14:49 UTC 2024
2024/12/02 18:32:16 [5205] [Azure-Utils] iptables --version
2024/12/02 18:32:16 [5205] [cni-net] iptable version:iptables v1.8.7 (nf_tables), err:<nil>
2024/12/02 18:32:16 [5205] [Azure-Utils] ebtables --version
2024/12/02 18:32:16 [5205] [cni-net] ebtable version ebtables 1.8.7 (nf_tables), err:<nil>
2024/12/02 18:32:16 [5205] [net] Network interface: {Index:1 MTU:65536 Name:lo HardwareAddr: Flags:up|loopback|running} with IP: [127.0.0.1/8 ::1/128]
2024/12/02 18:32:16 [5205] [net] Network interface: {Index:2 MTU:1500 Name:eth0 HardwareAddr:7c:1e:52:3f:a7:82 Flags:up|broadcast|multicast|running} with IP: [10.224.0.33/16 fe80::7e1e:52ff:fe3f:a782/64]
2024/12/02 18:32:16 [5205] [net] Network interface: {Index:4 MTU:1500 Name:azvd58fa447f23 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/12/02 18:32:16 [5205] [net] Network interface: {Index:6 MTU:1500 Name:azv7d388aa4446 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/12/02 18:32:16 [5205] [net] Network interface: {Index:8 MTU:1500 Name:azv5ddabf0582a HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/12/02 18:32:16 [5205] [net] Restored state
2024/12/02 18:32:16 [5205] Number of endpoints: 3
2024/12/02 18:32:16 [5205] [cni-net] Plugin started.
2024/12/02 18:32:16 [5205] [cni-net] Processing ADD command with args {ContainerID:d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a Netns:/var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896 IfName:eth0 Args:IgnoreUnknown=1;K8S_POD_NAMESPACE=default;K8S_POD_NAME=nginx;K8S_POD_INFRA_CONTAINER_ID=d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a;K8S_POD_UID=d02bf488-3589-4d20-9dcf-5aee17dac3a7 Path:/opt/cni/bin StdinData:{"cniVersion":"0.3.0","ipam":{"type":"azure-vnet-ipam"},"ipsToRouteViaHost":["169.254.20.10"],"mode":"transparent","name":"azure","type":"azure-vnet"}}.
2024/12/02 18:32:16 [5205] [cni-net] Found network azure with subnet 10.224.0.0/16.
2024/12/02 18:32:16 [5205] [cni] Calling plugin azure-vnet-ipam ADD
2024/12/02 18:32:17 [5205] [cni] Plugin azure-vnet-ipam returned result:&{CNIVersion:1.0.0 Interfaces:[] IPs:[{Interface:<nil> Address:{IP:10.224.0.39 Mask:ffff0000} Gateway:10.224.0.1}] Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} GW:10.224.0.1}] DNS:{Nameservers:[168.63.129.16] Domain: Search:[] Options:[]}}, err:<nil>.
2024/12/02 18:32:17 [5205] [cni-net] Creating endpoint Id:d3fd8158-eth0 ContainerID:d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a NetNsPath:/var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896 IfName:eth0 IfIndex:0 MacAddr: IPAddrs:[{10.224.0.39 ffff0000}] Gateways:[] Data:map[vethname:default.nginx].
2024/12/02 18:32:17 [5205] Generate veth name based on the key provided default.nginx
2024/12/02 18:32:17 [5205] Transparent client
2024/12/02 18:32:17 [5205] [net] Creating veth pair azvc440f455693 azvc440f4556932.
2024/12/02 18:32:17 [5205] [net] Setting link azvc440f455693 state up.
2024/12/02 18:32:17 [5205] [Azure-Utils] sysctl -w net.ipv6.conf.azvc440f455693.accept_ra=0
2024/12/02 18:32:17 [5205] Setting mtu 1500 on veth interface azvc440f455693
2024/12/02 18:32:17 [5205] [net] Adding route for the ip 10.224.0.39/32
2024/12/02 18:32:17 [5205] [net] Adding IP route {Dst:{IP:10.224.0.39 Mask:ffffffff} Src:<nil> Gw:<nil> Protocol:0 DevName: Scope:0 Priority:0 Table:0} to link azvc440f455693.
2024/12/02 18:32:17 [5205] calling setArpProxy for azvc440f455693
2024/12/02 18:32:17 [5205] [Azure-Utils] echo 1 > /proc/sys/net/ipv4/conf/azvc440f455693/proxy_arp
2024/12/02 18:32:17 [5205] [net] Opening netns /var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896.
2024/12/02 18:32:17 [5205] [net] Setting link azvc440f4556932 netns /var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896.
2024/12/02 18:32:17 [5205] [net] Entering netns /var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896.
2024/12/02 18:32:17 [5205] [net] Setting link azvc440f4556932 state down.
2024/12/02 18:32:17 [5205] [net] Setting link azvc440f4556932 name eth0.
2024/12/02 18:32:17 [5205] [Azure-Utils] sysctl -w net.ipv6.conf.eth0.accept_ra=0
2024/12/02 18:32:17 [5205] [net] Setting link eth0 state up.
2024/12/02 18:32:17 [5205] [net] Adding IP address 10.224.0.39/16 to link eth0.
2024/12/02 18:32:17 [5205] [net] Deleting IP route {Dst:{IP:10.224.0.0 Mask:ffff0000} Src:<nil> Gw:<nil> Protocol:2 DevName: Scope:253 Priority:0 Table:0} from link eth0.
2024/12/02 18:32:17 [5205] [net] Adding IP route {Dst:{IP:169.254.1.1 Mask:ffffffff} Src:<nil> Gw:<nil> Protocol:0 DevName: Scope:253 Priority:0 Table:0} to link eth0.
2024/12/02 18:32:17 [5205] [net] Adding IP route {Dst:{IP:0.0.0.0 Mask:00000000} Src:<nil> Gw:169.254.1.1 Protocol:0 DevName: Scope:0 Priority:0 Table:0} to link eth0.
2024/12/02 18:32:17 [5205] [net] Adding static arp for IP address 169.254.1.1/32 and MAC aa:aa:aa:aa:aa:aa in Container namespace
2024/12/02 18:32:17 [5205] [net] Exiting netns /var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896.
2024/12/02 18:32:17 [5205] [net] Created endpoint &{Id:d3fd8158-eth0 HnsId: SandboxKey: IfName:azvc440f4556932 HostIfName:azvc440f455693 MacAddress:fe:86:5d:18:09:89 InfraVnetIP:{IP:<nil> Mask:<nil>} LocalIP: IPAddresses:[{IP:10.224.0.39 Mask:ffff0000}] Gateways:[0.0.0.0] DNS:{Suffix: Servers:[168.63.129.16] Options:[]} Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} Src:<nil> Gw:10.224.0.1 Protocol:0 DevName: Scope:0 Priority:0 Table:0}] VlanID:0 EnableSnatOnHost:false EnableInfraVnet:false EnableMultitenancy:false AllowInboundFromHostToNC:false AllowInboundFromNCToHost:false NetworkContainerID: NetworkNameSpace:/var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896 ContainerID:d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a PODName:nginx PODNameSpace:default InfraVnetAddressSpace: NetNs:}.
2024/12/02 18:32:17 [5205] [net] Save succeeded.
2024/12/02 18:32:17 [5205] [cni-net] ADD command completed for pod nginx with IPs:[{Interface:<nil> Address:{IP:10.224.0.39 Mask:ffff0000} Gateway:10.224.0.1}] err:<nil>.
2024/12/02 18:32:17 [5205] [cni-net] Plugin stopped.
2024/12/02 18:32:17 [5205] Released process lock

cat /etc/cni/net.d/10-azure.conflist

apt update -y && apt install net-tools -y; route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.224.0.1      0.0.0.0         UG    100    0        0 eth0
10.224.0.0      0.0.0.0         255.255.0.0     U     100    0        0 eth0
10.224.0.1      0.0.0.0         255.255.255.255 UH    100    0        0 eth0
10.224.0.39     0.0.0.0         255.255.255.255 UH    0      0        0 azvc440f455693
168.63.129.16   10.224.0.1      255.255.255.255 UGH   100    0        0 eth0
169.254.169.254 10.224.0.1      255.255.255.255 UGH   100    0        0 eth0

cat /var/run/azure-vnet.json | grep 
                                                        "d3fd8158-eth0": {
                                                                "Id": "d3fd8158-eth0",
                                                                "SandboxKey": "",
                                                                "IfName": "azvc440f4556932",
                                                                "HostIfName": "azvc440f455693",
                                                                "MacAddress": "/oZdGAmJ",
                                                                "IPAddresses": [
                                                                        {
                                                                                "IP": "10.224.0.39",
                                                                "NetworkNameSpace": "/var/run/netns/cni-24740290-ae7f-ca68-274b-8f3259a70896",
                                                                "ContainerID": "d3fd815826ae0dfd564d257a17c19ff5c6601f4b0638874393321b0e0c666e1a",
                                                                "PODName": "nginx",
                                                                "PODNameSpace": "default"
                                                        }

ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 7c:1e:52:3f:a7:82 brd ff:ff:ff:ff:ff:ff
    inet 10.224.0.33/16 metric 100 brd 10.224.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::7e1e:52ff:fe3f:a782/64 scope link
       valid_lft forever preferred_lft forever
10: azvc440f455693@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-24740290-ae7f-ca68-274b-8f3259a70896
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever

ip netns
cni-24740290-ae7f-ca68-274b-8f3259a70896 (id: 3)

ip netns pids cni-24740290-ae7f-ca68-274b-8f3259a70896
5280
5344
5379
5380

ps -aux | grep nginx
root        5344  0.0  0.0  11444  7356 ?        Ss   10:32   0:00 nginx: master process nginx -g daemon off;
systemd+    5379  0.0  0.0  11908  2936 ?        S    10:32   0:00 nginx: worker process
systemd+    5380  0.0  0.0  11908  2936 ?        S    10:32   0:00 nginx: worker process

ps -aux | grep 5280
65535       5280  0.0  0.0    972     4 ?        Ss   10:32   0:00 /pause

nsenter -t 5344 -n ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
9: eth0@if10: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fe:86:5d:18:09:89 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.224.0.39/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::fc86:5dff:fe18:989/64 scope link
       valid_lft forever preferred_lft forever
       
crictl pods nginx
POD ID              CREATED             STATE               NAME                                  NAMESPACE  ATTEMPT             RUNTIME
d3fd815826ae0       About an hour ago   Ready               nginx                                 default   0                   (default)

crictl inspectp d3fd815826ae0 | grep pid
    "pid": 5280,
    
cat /var/log/pods/default_nginx_d02bf488-3589-4d20-9dcf-5aee17dac3a7/nginx/0.log
2024-12-02T18:32:23.621151271Z stdout F /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
2024-12-02T18:32:23.621179072Z stdout F /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
2024-12-02T18:32:23.624093283Z stdout F /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
2024-12-02T18:32:23.631610568Z stdout F 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
2024-12-02T18:32:23.636762363Z stdout F 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
2024-12-02T18:32:23.636993472Z stdout F /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
2024-12-02T18:32:23.637120177Z stdout F /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
2024-12-02T18:32:23.639496367Z stdout F /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
2024-12-02T18:32:23.640748714Z stdout F /docker-entrypoint.sh: Configuration complete; ready for start up
2024-12-02T18:32:23.645986013Z stderr F 2024/12/02 10:32:23 [notice] 1#1: using the "epoll" event method
2024-12-02T18:32:23.645993213Z stderr F 2024/12/02 10:32:23 [notice] 1#1: nginx/1.27.3
2024-12-02T18:32:23.645996013Z stderr F 2024/12/02 10:32:23 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2024-12-02T18:32:23.645998913Z stderr F 2024/12/02 10:32:23 [notice] 1#1: OS: Linux 5.15.0-1074-azure
2024-12-02T18:32:23.646002214Z stderr F 2024/12/02 10:32:23 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024-12-02T18:32:23.646066116Z stderr F 2024/12/02 10:32:23 [notice] 1#1: start worker processes
2024-12-02T18:32:23.64618372Z stderr F 2024/12/02 10:32:23 [notice] 1#1: start worker process 29
2024-12-02T18:32:23.646293125Z stderr F 2024/12/02 10:32:23 [notice] 1#1: start worker process 30
```

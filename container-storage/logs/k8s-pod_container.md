## container

```
See th e

kubectl run nginx --image=nginx
kubectl debug -it nginx --image=busybox:1.28 --target=nginx # https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container-example
```

## container.id

```
# See the section on container logs

kubectl run nginx --image=nginx

# kubectl describe po nginx
Containers:
  nginx:
    Container ID:   containerd://578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454

# root@aks-nodepool1-51397738-vmss00000Z:/# cat /var/log/syslog
Aug 14 19:37:06 aks-nodepool1-51397738-vmss00000Z containerd[1588]: time="2023-08-14T19:37:06.986679044Z" level=info msg="CreateContainer within sandbox "a70c7e3fcbe1319c705b5498e72f81f79a14bef3de27c1edaf7b933ba746f724\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454\""
Aug 14 19:37:06 aks-nodepool1-51397738-vmss00000Z containerd[1588]: time="2023-08-14T19:37:06.987296045Z" level=info msg="StartContainer for \"578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454\""
Aug 14 19:37:07 aks-nodepool1-51397738-vmss00000Z systemd[1]: Started libcontainer container 578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454.
Aug 14 19:37:07 aks-nodepool1-51397738-vmss00000Z containerd[1588]: time="2023-08-14T19:37:07.054755596Z" level=info msg="StartContainer for \"578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454\" returns successfully"
Aug 14 19:37:07 aks-nodepool1-51397738-vmss00000Z systemd[1]: run-containerd-runc-k8s.io-578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454-runc.Xr8q12.mount: Deactivated successfully.
Aug 14 19:37:07 aks-nodepool1-51397738-vmss00000Z kubelet[1734]: I0814 19:37:07.384915    1734 kubelet.go:2134] "SyncLoop (PLEG): event for pod" pod="default/nginx" event=&{ID:96d459e4-c1a6-4412-b38d-dbf299dafd19 Type:ContainerStarted Data:578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454}
    
# root@aks-nodepool1-51397738-vmss00000Z:~# crictl ps | grep nginx
CONTAINER           IMAGE               CREATED             STATE               NAME                    ATTEMPT             POD ID              POD
578f72d0d40c1       89da1fb6dcb96       48 minutes ago      Running             nginx                   0        a70c7e3fcbe13       nginx
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

- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/cri-api/pkg/apis/runtime/v1/api.proto: The file contains the ContainerId

## container.state

```
# See the section on pod state PodInitializing
```

- https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/

## container.state.hook

- https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/: FailedPostStartHook, FailedPreStopHook

## container

```
See th e

kubectl run nginx --image=nginx
kubectl debug -it nginx --image=busybox:1.28 --target=nginx # https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container-example
```

## container.id

```
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

- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/cri-api/pkg/apis/runtime/v1/api.proto: The file contains the ContainerId

## container.state

```
# See the section on pod state PodInitializing
```

- https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/

## container.state.hook

- https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/: FailedPostStartHook, FailedPreStopHook

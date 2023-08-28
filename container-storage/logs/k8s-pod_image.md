```
kubectl run nginx --image=nginx

# /var/log/syslog. The second-last line has the image size (bytes) and download duration (seconds).
Aug  8 13:43:41 aks-nodepool1-31040111-vmss000008 kubelet[1662]: I0808 13:43:41.570195    1662 azure_credentials.go:221] image(docker.io/library/nginx) is not from ACR, return empty authentication
Aug  8 13:43:41 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:41.570697918Z" level=info msg="PullImage \"nginx:latest\""
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.308514464Z" level=info msg="ImageCreate event name:\"docker.io/library/nginx:latest\"  labels:{key:\"io.cri-containerd.image\"  value:\"managed\"}"
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.314614653Z" level=info msg="stop pulling image docker.io/library/nginx:latest: active requests=0, bytes read=70609911"
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.327868345Z" level=info msg="ImageUpdate event name:\"docker.io/library/nginx:latest\"  labels:{key:\"io.cri-containerd.image\"  value:\"managed\"}"
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.336461970Z" level=info msg="ImageCreate event name:\"docker.io/library/nginx@sha256:67f9a4f10d147a6e04629340e6493c9703300ca23a2f7f3aa56fe615d75d31ca\"  labels:{key:\"io.cri-containerd.image\"  value:\"managed\"}"
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.337676888Z" level=info msg="Pulled image \"nginx:latest\" with image id \"sha256:89da1fb6dcb964dd35c3f41b7b93ffc35eaf20bc61f2e1335fea710a18424287\", repo tag \"docker.io/library/nginx:latest\", repo digest \"docker.io/library/nginx@sha256:67f9a4f10d147a6e04629340e6493c9703300ca23a2f7f3aa56fe615d75d31ca\", size \"70601125\" in 5.766826368s"
Aug  8 13:43:47 aks-nodepool1-31040111-vmss000008 containerd[1520]: time="2023-08-08T13:43:47.337715689Z" level=info msg="PullImage \"nginx:latest\" returns image reference \"sha256:89da1fb6dcb964dd35c3f41b7b93ffc35eaf20bc61f2e1335fea710a18424287\""

# crictl image | grep nginx
IMAGE                                                                                 TAG   IMAGE ID            SIZE
docker.io/library/nginx                                                               latest   89da1fb6dcb96       70.6MB
```

- https://github.com/containerd/containerd/blob/main/pkg/cri/server/image_pull.go
- https://kubernetes.io/docs/concepts/containers/images/

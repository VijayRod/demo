## crictl

```
crictl image list
crictl inspecti imageshack.azurecr.io/image22gacrtasks:v1

root@aks-nodepool1-74128781-vmss000001:/# crictl rmi nginx
Deleted: docker.io/library/nginx:latest

root@aks-nodepool1-74128781-vmss000001:/# crictl pull nginx
Image is up to date for sha256:3b25b682ea82b2db3cc4fd48db818be788ee3f902ac7378090cf2624ec2442df
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
- https://github.com/containerd/containerd/blob/main/docs/cri/crictl.md
- https://github.com/containerd/containerd/blob/main/pkg/cri/server/image_pull.go
- https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling#pull-crictl

### crictl.install

```
# It's already installed on an AKS containerd worker node.
```

- https://github.com/kubernetes-sigs/cri-tools

## crictl.debug

```
root@aks-nodepool1-74128781-vmss000000:/# which crictl
/usr/local/bin/crictl

root@aks-nodepool1-74128781-vmss000000:/# crictl version
Version:  0.1.0
RuntimeName:  containerd
RuntimeVersion:  1.7.22-1
RuntimeApiVersion:  v1

root@aks-nodepool1-74128781-vmss000000:/# crictl info
{
  "status": {
    "conditions": [
      {
        "type": "RuntimeReady",
        "status": true,
        "reason": "",
        "message": ""
      },
...

crictl --debug --timeout n

root@aks-nodepool1-74128781-vmss000000:/# cat /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
#EOF
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/

## crictl.image

```
crictl images
IMAGE                                                                                 TAG                    IMAGE ID            SIZE
docker.io/library/alpine                                                              latest                    91ef0af61f39e       3.63MB
docker.io/library/nginx                                                               latest                    3b25b682ea82b       73MB
...

crictl images -q # Only show image IDs
sha256:91ef0af61f39ece4d6710e465df5ed6ca12112358344fd51ae6a3b886634148b
sha256:3b25b682ea82b2db3cc4fd48db818be788ee3f902ac7378090cf2624ec2442df
sha256:59ab366372d56772eb54e426183435e6b0642152cb449ec7ab52473af8ca6e3f
...

crictl rmi 91ef0af61f39e 3b25b682ea82b
Deleted: docker.io/library/alpine:latest
Deleted: docker.io/library/nginx:latest
```

## crictl.image.creds 

```
# This can be utilized to retrieve an image from a registry, such as ACR

crictl pull --creds USERNAME[:PASSWORD]
crictl pull --auth=xx.json

# In a public AKS cluster that's attached to a public ACR
crictl pull imageshack.azurecr.io/library/nginx:latest # 401 Unauthorized
crictl pull --auth=/etc/kubernetes/azure.json imageshack.azurecr.io/library/nginx:latest # illegal base64 data at input byte 21
# tbd workaround
az acr update --anonymous-pull-enabled true -n $registry # (BadRequest) Anonymous pull is not supported for SKU Managed_Basic
crictl pull imageshack.azurecr.io/library/nginx:latest

# In a public AKS cluster that's attached to a public ACR
# tbd with az acr token
az acr token create --registry $registry --name MyToken --repository library/nginx content/write content/read --output json
root@aks-nodepool1-74128781-vmss000000:/# crictl pull --creds MyToken:7oredacted imageshack.azurecr.io/library/nginx:latest # 401 Unauthorized
```

- https://stackoverflow.com/questions/73910486/why-does-crictl-pull-from-private-registry-not-need-account-password: crictl is only using your container runtime. In your case, it is using containerd to actually do the pull. That means if you already have the configuration for containerd to authenticate, that will work out of the box with crictl.
- https://github.com/containerd/containerd/blob/main/docs/cri/config.md#registry-configuration
- https://github.com/containerd/containerd/blob/main/docs/cri/registry.md#configure-registry-credentials
- https://github.com/kubernetes-sigs/cri-tools/issues/482: --creds. --auth. /etc/containerd/config.toml

## crictl.pods

```
crictl pods
POD ID              CREATED             STATE               NAMENAMESPACE           ATTEMPT             RUNTIME
e5e0764cfc5ce       6 minutes ago       Ready               nsenter-mjqnsi	default             0                   (default)
16750360f18f6       20 hours ago        Ready               nsenter-euwhta	default             0                   (default)
5eeb8c271960c       23 hours ago        Ready               konnectivity-agent-6c96bfdf86-849fc	kube-system         0                   (default)

crictl pods --name nsenter-jv2jfd # --namespace default
POD ID              CREATED             STATE               NAME                NAMESPACE           ATTEMPT    RUNTIME
5fff0416fb462       29 seconds ago      Ready               nsenter-jv2jfd      default             0    (default)

crictl pods --id 5eeb8c271960c
POD ID              CREATED             STATE               NAME                                  NAMESPACE  ATTEMPT             RUNTIME
5eeb8c271960c       23 hours ago        Ready               konnectivity-agent-6c96bfdf86-849fc   kube-system         0                   (default)

crictl pods --id 5eeb8c271960c -v
# or crictl pods --name konnectivity-agent-6c96bfdf86-849fc --namespace kube-system -v
ID: 5eeb8c271960c1e86cd16a6d245b215136f50bdb60d1ade3937fa38746fb4867
Name: konnectivity-agent-6c96bfdf86-849fc
UID: edd628bb-8230-4fe6-8dbc-436bfc97a728
Namespace: kube-system
Status: Ready
Created: 2024-10-22 18:59:50.931824673 +0000 UTC
Labels:
        app -> konnectivity-agent
        component -> tunnel
        io.kubernetes.pod.name -> konnectivity-agent-6c96bfdf86-849fc
        io.kubernetes.pod.namespace -> kube-system
        io.kubernetes.pod.uid -> edd628bb-8230-4fe6-8dbc-436bfc97a728
        kubernetes.azure.com/managedby -> aks
        pod-template-hash -> 6c96bfdf86
Annotations:
        checksum/client-cert -> 93708f0cddb9420b1f15a4403617e68f5dcabef533c7047a3f856d210a353e08
        checksum/service-account-key -> b94bff7dabf92c52f90683082ceea1504607d271ef267c7b4e6d595c5ae30f10
        kubernetes.io/config.seen -> 2024-10-22T18:59:50.610216793Z
        kubernetes.io/config.source -> api
Runtime: (default)

crictl pods --label app=konnectivity-agent
POD ID              CREATED             STATE               NAME                                  NAMESPACE  ATTEMPT             RUNTIME
5eeb8c271960c       23 hours ago        Ready               konnectivity-agent-6c96bfdf86-849fc   kube-system         0                   (default)
```

## crictl.pods.containers

```
crictl ps -a # all
CONTAINER           IMAGE               CREATED             STATE               NAME                    ATTEMPT             POD ID              POD
91309d77c9e7a       91ef0af61f39e       9 minutes ago       Running             nsenter                 0                   5fff0416fb462       nsenter-jv2jfd
33d273f1d2f81       91ef0af61f39e       22 minutes ago      Running             nsenter                 0                   e5e0764cfc5ce       nsenter-mjqnsi
```

## crictl.pods.containers.inspect

```
crictl inspect bc5f6c2074eae
{
  "status": {
    "id": "bc5f6c2074eae60887bb8af8852e3fe45ed58cd6ca3f5d40d28245d8e55a4adb",
    "metadata": {
      "attempt": 0,
      "name": "konnectivity-agent"
    },
    "state": "CONTAINER_RUNNING",
    "createdAt": "2024-10-22T19:59:51.182235133Z",
    "startedAt": "2024-10-22T19:59:51.243868258Z",
    "finishedAt": "0001-01-01T00:00:00Z",
    "exitCode": 0,
    "image": {
      "annotations": {},
      "image": "mcr.microsoft.com/oss/kubernetes/apiserver-network-proxy/agent:v0.30.3-hotfix.20240819",
      "runtimeHandler": "",
      "userSpecifiedImage": ""
    },
    "imageRef": "sha256:52402add5c819ae82b67c0a3d7774a145cc21b98e59ebaf82e857b9403c016ae",
    "reason": "",
    "message": "",
    "labels": {
      "io.kubernetes.container.name": "konnectivity-agent",
      "io.kubernetes.pod.name": "konnectivity-agent-6c96bfdf86-849fc",
      "io.kubernetes.pod.namespace": "kube-system",
      "io.kubernetes.pod.uid": "edd628bb-8230-4fe6-8dbc-436bfc97a728"
    },
    "annotations": {
      "io.kubernetes.container.hash": "73080a8d",
      "io.kubernetes.container.restartCount": "0",
      "io.kubernetes.container.terminationMessagePath": "/dev/termination-log",
      "io.kubernetes.container.terminationMessagePolicy": "File",
      "io.kubernetes.pod.terminationGracePeriod": "30"
    },
    "mounts": [
      {
        "containerPath": "/certs",
        "gidMappings": [],
...

crictl inspect 5eeb8c271960c # to look up a container id, not a pod id.
E1023 19:17:56.414616 1463700 remote_runtime.go:432] "ContainerStatus from runtime service failed" err="rpc error: code = NotFound desc = an error occurred when try to find container \"5eeb8c271960c\": not found" containerID="5eeb8c271960c"
FATA[0000] getting the status of the container "5eeb8c271960c": rpc error: code = NotFound desc = an error occurred when try to find container "5eeb8c271960c": not found

crictl inspect 91309d77c9e7a bc5f6c2074eae
{
  "status": {
    "id": "91309d77c9e7ae8ff90a3f99e9761c4d599c86d59aa73c510bfe4991829df795",
    "metadata": {
      "attempt": 0,
      "name": "nsenter"
    },
    "state": "CONTAINER_RUNNING",
...
{
  "status": {
    "id": "bc5f6c2074eae60887bb8af8852e3fe45ed58cd6ca3f5d40d28245d8e55a4adb",
    "metadata": {
      "attempt": 0,
      "name": "konnectivity-agent"
    },
    "state": "CONTAINER_RUNNING",
...
```

## crictl.pods.containers.exec

```
crictl exec -i -t 91309d77c9e7a ls # container id
NOTICE.txt  boot  etc   lib    libx32      media  opt   root  sbin  sys  usr
bin         dev   home  lib64  lost+found  mnt    proc  run   srv   tmp  var
```

## crictl.pods.containers.log

```
crictl logs --tail=10 bc5f6c2074eae # container id
# crictl logs bc5f6c2074eae
# crictl logs -f bc5f6c2074eae # follow
I1023 19:09:52.064560       1 client.go:528] "remote connection EOF" connectionID=3390
I1023 19:09:57.145830       1 client.go:528] "remote connection EOF" connectionID=3391
I1023 19:09:58.591138       1 client.go:528] "remote connection EOF" connectionID=2886
I1023 19:10:12.058850       1 client.go:528] "remote connection EOF" connectionID=3393
I1023 19:10:17.138353       1 client.go:528] "remote connection EOF" connectionID=4798
I1023 19:10:30.933195       1 client.go:528] "remote connection EOF" connectionID=4799
I1023 19:10:37.137922       1 client.go:528] "remote connection EOF" connectionID=4800
I1023 19:10:45.131098       1 client.go:528] "remote connection EOF" connectionID=4801
I1023 19:10:50.929612       1 client.go:528] "remote connection EOF" connectionID=3394
I1023 19:10:57.141157       1 client.go:528] "remote connection EOF" connectionID=3395
```

## crictl.pods.containers.stats

```
crictl stats 91309d77c9e7a # container id
CONTAINER           NAME                CPU %               MEM                 DISK                INODES
91309d77c9e7a       nsenter             0.00                2.126MB             24.58kB             7

crictl statsp a2b274ada009f # pod id. 
POD                 POD ID              CPU %               MEM
nsenter-q7dzwy      a2b274ada009f       0.07                10.04MB
```

## crictl.pods.port-forward

```
root@aks-nodepool1-74128781-vmss000000:/# crictl port-forward a2b274ada009f 80
Forwarding from 127.0.0.1:80 -> 80
Forwarding from [::1]:80 -> 80
```

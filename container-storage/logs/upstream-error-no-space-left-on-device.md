## Error: No Space Left on Device

The "kubectl create" command below shows a warning regarding an invalid fractional byte value:

```
~# cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      limits:
        memory: 500m
EOF
```

Pod creation succeeds despite the warnings:

```
Warning: spec.containers[0].resources.limits[memory]: fractional byte value "500m" is invalid, it must be an integer.
Warning: spec.containers[0].resources.requests[memory]: fractional byte value "500m" is invalid, it must be an integer.
pod/nginx created
```

When describing the pod, a mount failure is reported with a message insufficient space on the device:

```
~# kubectl get po

NAME                          READY   STATUS              RESTARTS   AGE
nginx                         0/1     ContainerCreating   0          8m2s

kubectl describe pod nginx
Events:
Type     Reason       Age                 From               Message
----     ------       ----                ----               -------
Normal   Scheduled    8m7s                default-scheduler  Successfully assigned default/nginx to aks-nodepool1-35286517-vmss00000a
Warning  FailedMount  8m8s                kubelet            MountVolume.SetUp failed for volume "kube-api-access-br996" : write /var/lib/kubelet/pods/30d788ce-ee1f-4abe-8b11-363ccd301c3c/volumes/kubernetes.io~projected/kube-api-access-br996/..2023_06_05_15_16_42.2692570505/namespace: no space left on device
```

The <ins>corrected</ins> version with a valid memory value:

```
~# cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: nginx-works
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      limits:
        memory: 500Mi
EOF
```

The pod creation is successful:

```
pod/nginx-works created
```

Verifying the pod:

```
~# kubectl get po
NAME                          READY   STATUS              RESTARTS   AGE
nginx-works                   1/1     Running             0          8s
```

Additionally, the <u>containerd client</u> also indicates that "500m" is an invalid value:

```
ctr image pull docker.io/library/hello-world:latest
ctr run --memory-limit 500m docker.io/library/hello-world:latest hello
ctr: invalid value "500m" for flag -memory-limit: parse error
```

Root Cause Analysis (RCA): When creating a pod, the warning message is shown to the user. However, Kubernetes does not block such pod creations upstream, suggesting that this behavior is by design in Kubernetes. It is the user's responsibility to pay attention to these warnings.

For more information and references:

- Refer to the GitHub issue [#1235](https://github.com/kubernetes/client-go/issues/1235#issuecomment-1466822615) in the client-go repository, which explains that fractional byte values for memory requests/limits are considered invalid.
- The Kubernetes documentation on [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory) provides information on memory resource units. For example, requesting 400m of memory is equivalent to requesting 0.4 bytes.

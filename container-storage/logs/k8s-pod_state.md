## pod.state

- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27/#podstatus-v1-core: PodCondition. ContainerStatus
- https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli: a pod's age will continue to be calculated from its original creation time

## pod.state.PodInitializing (Init:0/1)

```
# See the section on container state
```

- https://stackoverflow.com/questions/50075422/kubernetes-pods-hanging-in-init-state: If the pods status is ´Init:0/1´ means one init container is not finalized; init:N/M means the Pod has M Init Containers, and N have completed so far.
- https://stackoverflow.com/questions/53314770/pods-stuck-in-podinitializing-state-indefinitely
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/#understanding-pod-status
- https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use: Init:0/2. PodInitializing

## pod.state.Terminating

- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination
- https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution: If a PreStop hook hangs during execution, the Pod's phase will be Terminating and remain there until the Pod is killed after its terminationGracePeriodSeconds expires.

## pod.state.Terminating.terminationGracePeriodSeconds

```
kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  terminationGracePeriodSeconds: 86400 # 24h. 
EOF
sleep 10
kubectl get po nginx

kubectl get po -oyaml
apiVersion: v1
items:
- apiVersion: v1
  spec:
    terminationGracePeriodSeconds: 86400
```    

```    
kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
      terminationGracePeriodSeconds: 86400 # 24h. 
EOF
sleep 10
kubectl get deploy nginx
```
    
- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination: Because Pods represent processes running on nodes in the cluster, it is important to allow those processes to gracefully terminate when they are no longer needed (rather than being abruptly stopped with a KILL signal and having no chance to clean up).
  - You use the kubectl tool to manually delete a specific Pod, with the default grace period (30 seconds).
  - The default terminationGracePeriodSeconds setting is 30 seconds.
- https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution
- https://kubernetes.io/docs/tutorials/services/pods-and-endpoint-termination-flow/#example-flow-with-endpoint-termination
  
## pod.state.Terminating.terminationmessage

- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/#writing-and-reading-a-termination-message

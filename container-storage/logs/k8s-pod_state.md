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

## kubectl.debug.node
```
# kubectl node-shell aks-nodepool1-37663765-vmss000000

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=busybox

node=$(kubectl get no -oname | head -n 1)
kubectl debug $node -it --image=busybox

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=ubuntu # apt update && apt install dnsutils -y
# Use chroot /host, to ensure commands like crictl function

# log files
kubectl debug node/{node-name-xxxx} --image=nginx
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/messages /tmp/messages
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/syslog /tmp/syslog
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/kern.log /tmp/kern.log
kubectl delete po node-debugger-{node-name-xxxx} # Once you have gathered the logs, feel free to remove the debug pod
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/kubectl-node-debug/
- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#debug
- https://learn.microsoft.com/en-us/azure/aks/node-access

## kubectl.debug.pod

```
kubectl exec -it mypod -- /bin/bash
kubectl exec -it mypod -- sh

kubectl debug mypod -it --image=busybox
```

- https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/

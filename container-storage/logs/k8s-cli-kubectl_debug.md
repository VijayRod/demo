```
kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=busybox

node=$(kubectl get no -oname | head -n 1)
kubectl debug $node -it --image=busybox

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=ubuntu # apt update && apt install dnsutils -y
# Use chroot /host, to ensure commands like crictl function

# kubectl node-shell aks-nodepool1-37663765-vmss000000
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/kubectl-node-debug/
- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#debug
- https://learn.microsoft.com/en-us/azure/aks/node-access

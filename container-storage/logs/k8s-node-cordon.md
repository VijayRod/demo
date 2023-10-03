```
kubectl create deploy nginx --image=nginx --replicas=10
kubectl get po -owide | grep nginx-
kubectl cordon aks-nodepool1-16524978-vmss000001 # Mark node as unschedulable
# kubectl cordon -l agentpool=nodepool1

kubectl describe no aks-nodepool1-16524978-vmss000001 | grep schedul
Taints:             node.kubernetes.io/unschedulable:NoSchedule
Unschedulable:      true

kubectl drain --ignore-daemonsets aks-nodepool1-16524978-vmss000001 --delete-emptydir-data
# kubectl uncordon aks-nodepool1-16524978-vmss000001
# kubectl uncordon -l agentpool=nodepool1
```

- https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/

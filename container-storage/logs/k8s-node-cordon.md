## k8s-node-cordon

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

## k8s-node-cordon.drain

```
kubectl drain --ignore-daemonsets aks-nodepool1-16524978-vmss000001 --delete-emptydir-data
```

- https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/

## k8s-node-cordon.drain.app.draino

- https://github.com/planetlabs/draino: Draino automatically drains Kubernetes nodes based on labels and node conditions. Draino is intended for use alongside the Kubernetes Node Problem Detector and Cluster Autoscaler.

## k8s-node-cordon.drain.error.PodDrainFailure(terminationGracePeriodSeconds)

```
TBD (error_PodDrainFailure)

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
      terminationGracePeriodSeconds: 2592000 # 720h. 
EOF
sleep 10
kubectl get deploy nginx
kubectl get po -l app=nginx -oyaml | grep termin # terminationGracePeriodSeconds: 2592000

az aks nodepool upgrade -y -g $rg --cluster-name aks -n nodepool1 --kubernetes-version 1.27.1 # TBD (success)
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-poddrainfailure
- https://stackoverflow.com/questions/74376920/how-to-increase-node-drain-timeout-for-aks-node-upgrade-rollout: pod termination grace period 15h0m0s was greater than remaining per node drain timeout

## k8s-node-cordon.uncordon

```
# See the section on k8s-node-cordon
```

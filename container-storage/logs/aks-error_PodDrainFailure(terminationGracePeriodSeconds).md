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

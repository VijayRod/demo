```
# reason: All metrics below target (stabilizationWindowSeconds is 300s by default)

kubectl delete hpa nginx-hpa
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
  replicas: 10
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
        resources:
          requests:
            cpu: 0.2
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  maxReplicas: 10 # define max replica count
  minReplicas: 3  # define min replica count
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  targetCPUUtilizationPercentage: 50 # target CPU utilization
EOF
kubectl get hpa -w
# kubectl describe hpa
```

```
NAME        REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        0          1s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        10         15s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        10         30s
nginx-hpa   Deployment/nginx   0%/50%          3         10        10         75s
nginx-hpa   Deployment/nginx   0%/50%          3         10        10         5m16s
nginx-hpa   Deployment/nginx   0%/50%          3         10        3          5m31s

Name:                                                  nginx-hpa
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       3 current / 3 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type     Reason                        Age                            From                       Message
  ----     ------                        ----                           ----                       -------
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 3; reason: All metrics below target
```

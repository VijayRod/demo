```
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
apiVersion: autoscaling/v2
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
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 90
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
      policies:
      - type: Pods
        value: 1
        periodSeconds: 10 # Reduce 1 pod every 10 seconds
EOF
kubectl get hpa -w
# kubectl describe hpa
```

```
NAME        REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   <unknown>/90%   3         10        0          0s
nginx-hpa   Deployment/nginx   <unknown>/90%   3         10        10         7s
nginx-hpa   Deployment/nginx   <unknown>/90%   3         10        10         37s
nginx-hpa   Deployment/nginx   0%/90%          3         10        10         97s
nginx-hpa   Deployment/nginx   0%/90%          3         10        9          112s
nginx-hpa   Deployment/nginx   0%/90%          3         10        8          2m7s
nginx-hpa   Deployment/nginx   0%/90%          3         10        7          2m22s
nginx-hpa   Deployment/nginx   0%/90%          3         10        6          2m37s
nginx-hpa   Deployment/nginx   0%/90%          3         10        5          2m52s
nginx-hpa   Deployment/nginx   0%/90%          3         10        4          3m7s
nginx-hpa   Deployment/nginx   0%/90%          3         10        3          3m22s

Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (0) / 90%
Min replicas:                                          3
Max replicas:                                          10
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Pods     Value: 4    Period: 15 seconds
      - Type: Percent  Value: 100  Period: 15 seconds
  Scale Down:
    Stabilization Window: 10 seconds
    Select Policy: Max
    Policies:
      - Type: Pods  Value: 1  Period: 10 seconds
Deployment pods:    6 current / 5 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  ScalingLimited  True    ScaleDownLimit    the desired replica count is decreasing faster than the maximum scale rate
Events:
  Type     Reason                        Age                            From                       Message
  ----     ------                        ----                           ----                       -------
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 9; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 8; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 7; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 6; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 5; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 4; reason: All metrics below target
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 3; reason: All metrics below target
```
  
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#scaling-policies

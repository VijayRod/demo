```
# reason: Current number of replicas below Spec.MinReplicas (after hpa create)

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
EOF
sleep 5
kubectl get po,hpa
cat << EOF | kubectl create -f -
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
sleep 15
kubectl get po,hpa
kubectl get hpa -w
# kubectl describe hpa
```

```
NAME        REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        0          15s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        1          15s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        3          30s

kubectl describe hpa
Name:                                                  nginx-hpa
Namespace:                                             default
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 27 Nov 2023 22:06:54 +0000
Reference:                                             Deployment/nginx
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  <unknown> / 50%
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       5 current / 3 desired
Conditions:
  Type           Status  Reason                   Message
  ----           ------  ------                   -------
  AbleToScale    True    SucceededGetScale        the HPA controller was able to get the target's current scale
  ScalingActive  False   FailedGetResourceMetric  the HPA was unable to compute the replica count: failed to get cpu utilization: missing request for cpu in container nginx of Pod nginx-77b4fdf86c-bdzrg
Events:
  Type     Reason                        Age                            From                       Message
  ----     ------                        ----                           ----                       -------
  Normal   SuccessfulRescale             <invalid>                      horizontal-pod-autoscaler  New size: 3; reason: Current number of replicas below Spec.MinReplicas
```

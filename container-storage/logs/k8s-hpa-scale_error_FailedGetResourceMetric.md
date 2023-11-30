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
        resources: {} # No CPU requests specified even though HPA is defined with CPU metrics
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
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        0          0s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        10         19s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        10         54s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        10         115s # <unknown>

Name:                                                  nginx-hpa
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  <unknown> / 50% 		# <unknown> 
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       10 current / 0 desired
Conditions:
  Type           Status  Reason                   Message
  ----           ------  ------                   -------
  AbleToScale    True    SucceededGetScale        the HPA controller was able to get the target's current scale
  ScalingActive  False   FailedGetResourceMetric  the HPA was unable to compute the replica count: failed to get cpu utilization: missing request for cpu in container nginx of Pod nginx-77b4fdf86c-m8cf8 # failed to get cpu utilization: missing request for cpu in container
Events:
  Type     Reason                        Age                            From                       Message
  ----     ------                        ----                           ----                       -------
  Warning  FailedGetResourceMetric       <invalid> (x3 over <invalid>)  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  <invalid> (x3 over <invalid>)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetResourceMetric       <invalid> (x4 over <invalid>)  horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedComputeMetricsReplicas  <invalid> (x4 over <invalid>)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedGetResourceMetric       <invalid>                      horizontal-pod-autoscaler  failed to get cpu utilization: missing request for cpu in container nginx of Pod nginx-77b4fdf86c-rss4z # missing request for cpu in container
```

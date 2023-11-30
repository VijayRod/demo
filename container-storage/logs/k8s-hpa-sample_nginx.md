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
kubectl get hpa nginx-hpa -w
# kubectl describe hpa
# kubectl get po,hpa
```

```
NAME        REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        0          0s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        1          6s
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        3          21s # replicas=3
nginx-hpa   Deployment/nginx   <unknown>/50%   3         10        3          52s
nginx-hpa   Deployment/nginx   0%/50%          3         10        3          112s # targets=n%

Name:                                                  nginx-hpa
Namespace:                                             default
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 27 Nov 2023 22:06:54 +0000
Reference:                                             Deployment/nginx
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  1% (2m) / 50%
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       1 current / 3 desired
Conditions:
  Type         Status  Reason            Message
  ----         ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type    Reason             Age        From                       Message
  ----    ------             ----       ----                       -------
  Normal  SuccessfulRescale  <invalid>  horizontal-pod-autoscaler  New size: 3; reason: Current number of replicas below Spec.MinReplicas
```  

- https://github.com/kubernetes/enhancements/tree/master/keps/sig-autoscaling/853-configurable-hpa-scale-velocity#user-stories
- https://github.com/kubernetes/kubernetes/tree/master/pkg/controller/podautoscaler
- https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/#HorizontalPodAutoscalerSpec
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/: Horizontal pod autoscaling does not apply to objects that can't be scaled
- https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler
- https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale?tabs=azure-cli#autoscale-pods

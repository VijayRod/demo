This is an example of creating a Horizontal Pod Autoscaler. To utilize the autoscaler, all containers and pods for which the HPA is defined must have defined CPU requests and limits.

```
# To run and expose php-apache server
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml

# To create the HorizontalPodAutoscaler
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

```
# To retrieve information about the HorizontalPodAutoscaler.
# The created HorizontalPodAutoscaler resource has the same name as the deployment for which it is enabled and resides in the same namespace.
kubectl get hpa php-apache

# Here is a sample output below.
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   3%/50%    1         10        1          56s
```

```
# To describe the HorizontalPodAutoscaler to see more details.
kubectl describe hpa php-apache

# Here is a sample output below.
Name:                                                  php-apache
Namespace:                                             default
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Tue, 04 Jul 2023 12:06:45 +0000
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       1 current / 1 desired
Conditions:
  Type            Status  Reason               Message
  ----            ------  ------               -------
  AbleToScale     True    ScaleDownStabilized  recent recommendations were higher than current one, applying the highest recent recommendation
  ScalingActive   True    ValidMetricFound     the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange   the desired count is within the acceptable range
Events:
  Type     Reason                        Age                    From                       Message
  ----     ------                        ----                   ----                       -------
```

```
# To retrieve the YAML output of the HorizontalPodAutoscaler for more detailed status timestamps.
kubectl get hpa php-apache -oyaml

# Here is a sample output below.
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: "2023-07-04T12:06:45Z"
  name: php-apache
  namespace: default
  resourceVersion: "3782836"
  uid: 412cb906-8a79-4ab6-b710-20ea972cc0e5
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
status:
  conditions:
  - lastTransitionTime: "2023-07-04T12:07:00Z"
    message: recent recommendations were higher than current one, applying the highest
      recent recommendation
    reason: ScaleDownStabilized
    status: "True"
    type: AbleToScale
  - lastTransitionTime: "2023-07-04T12:08:00Z"
    message: the HPA was able to successfully calculate a replica count from cpu resource
      utilization (percentage of request)
    reason: ValidMetricFound
    status: "True"
    type: ScalingActive
  - lastTransitionTime: "2023-07-04T12:07:15Z"
    message: the desired count is within the acceptable range
    reason: DesiredWithinRange
    status: "False"
    type: ScalingLimited
  currentMetrics:
  - resource:
      current:
        averageUtilization: 0
        averageValue: 1m
      name: cpu
    type: Resource
  currentReplicas: 1
  desiredReplicas: 1
```

```
# TBD
kubectl top po | grep php-apache

# Here is a sample output below.
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-5b56f9df94-gjj2g   1m           9Mi
```

```
# To cleanup.
kubectl delete hpa php-apache
kubectl delete deploy php-apache
kubectl delete svc php-apache
```

Here are some related links:
- [aks/tutorial-kubernetes-scale?tabs=azure-cli#autoscale-pods](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale?tabs=azure-cli#autoscale-pods)
- [azure-kubernetes/identify-high-cpu-consuming-containers-aks](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/identify-high-cpu-consuming-containers-aks?tabs=browser#step-1-identify-nodescontainers-with-high-cpu-usage)
- [kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details)
- [kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

The scale-down behaviour of the HPA resource can be modified using the behaviour section. This takes effect after the stabilization window, which is determined by the --horizontal-pod-autoscaler-downscale-stabilization flag as indicated in the [Kubernetes documentation on configuring scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) and [flapping](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#flapping). By default, the stabilization window is set to 5 minutes, as mentioned in the [algorithm details](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details) section.

```
# To run and expose the php-apache server
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml

# To create the HorizontalPodAutoscaler
cat << EOF | kubectl create -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      policies:
      - type: Percent
        value: 80
        periodSeconds: 30
EOF
```

```
# To view the HPA behavior
kubectl describe hpa php-apache

# Here is a sample output below.
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Pods     Value: 4    Period: 15 seconds
      - Type: Percent  Value: 100  Period: 15 seconds
  Scale Down:
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 80  Period: 30 seconds
```

```
# Sample watch output
kubectl get hpa php-apache --watch

# Here is a sample output below.
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   55%/50%    1         10        5          6m30s
php-apache   Deployment/php-apache   0%/50%     1         10        5          7m
php-apache   Deployment/php-apache   0%/50%     1         10        5          11m
php-apache   Deployment/php-apache   0%/50%     1         10        1          12m
```

```
# To cleanup
kubectl delete hpa php-apache
kubectl delete deploy php-apache
kubectl delete svc php-apache
```

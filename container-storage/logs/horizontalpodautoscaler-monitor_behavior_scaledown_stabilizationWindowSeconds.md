To expedite the scaling-down process, you can specify the `stabilizationWindowSeconds` parameter mentioned in the [Kubernetes documentation on stabilization window](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#stabilization-window).

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
      stabilizationWindowSeconds: 30
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
    Stabilization Window: 30 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
```

```
# Sample watch output
kubectl get hpa php-apache --watch

# Here is a sample output below.
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   55%/50%    1         10        6          6m1s
php-apache   Deployment/php-apache   40%/50%    1         10        6          6m31s
php-apache   Deployment/php-apache   0%/50%     1         10        6          6m46s
php-apache   Deployment/php-apache   0%/50%     1         10        4          7m1s
php-apache   Deployment/php-apache   0%/50%     1         10        1          7m16s
```

```
# To cleanup
kubectl delete hpa php-apache
kubectl delete deploy php-apache
kubectl delete svc php-apache
```

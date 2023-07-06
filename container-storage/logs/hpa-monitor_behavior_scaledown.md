The scale-down behavior of the HPA resource can be modified using the behavior section, as mentioned in the [Kubernetes documentation on scaling policies](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#scaling-policies). This modification takes effect after the `stabilizationWindowSeconds` mentioned in the [Kubernetes documentation on stabilization window](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#stabilization-window). If the `stabilizationWindowSeconds` is not configured, the duration of the stabilization window is determined by the `--horizontal-pod-autoscaler-downscale-stabilization` flag, as indicated in the [Kubernetes documentation on configuring scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior).

By default, the `--horizontal-pod-autoscaler-downscale-stabilization` flag is set to 5 minutes, as mentioned in the [algorithm details](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details) section. This default duration establishes the stabilization window, which is a period of time during which the HPA ensures the number of replicas remains stable before triggering any scale-down actions. The stabilization window helps protect against fluctuations in the number of replicas and ensures a more stable autoscaling experience.

The concept of stabilization window and its significance in preventing undesired scale-down actions is further explained in the [flapping](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#flapping) documentation. Understanding and appropriately configuring the stabilization window can contribute to the effective and reliable autoscaling of your applications.

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

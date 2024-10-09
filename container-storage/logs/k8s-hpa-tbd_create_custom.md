Here are the steps to manually create the HorizontalPodAutoscaler resource instead of running kubectl autoscale. These steps can be used to customize the HPA resource:

```
# To run and expose php-apache server
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
EOF
```

```
# To cleanup
kubectl delete hpa php-apache
kubectl delete deploy php-apache
kubectl delete svc php-apache
```

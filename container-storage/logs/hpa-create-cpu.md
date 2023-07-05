I increased the load until there were five replicas, then stopped the load generation.

```
# To monitor HPA. Type Ctrl+C to end the watch when you're ready.
kubectl get hpa php-apache --watch

# To increase the load, run this in a separate terminal so that the load generation continues and you can carry on with the rest of the steps. Type Ctrl+C to end.
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

# Optionally, to monitor the pods.
kubectl top po -l run=php-apache --sort-by=cpu --containers=true
```

Here's some of the output:

```
# Initial:
# kubectl top po -l run=php-apache --sort-by=cpu --containers=true
POD                           NAME         CPU(cores)   MEMORY(bytes)
php-apache-5b56f9df94-zr7kf   php-apache   1m           11Mi

# After five replicas:
# kubectl top po -l run=php-apache --sort-by=cpu --containers=true
POD                           NAME         CPU(cores)   MEMORY(bytes)
php-apache-5b56f9df94-4ts2r   php-apache   167m         11Mi
php-apache-5b56f9df94-zr7kf   php-apache   162m         11Mi
php-apache-5b56f9df94-76xpr   php-apache   137m         11Mi
php-apache-5b56f9df94-d6rxg   php-apache   137m         11Mi
php-apache-5b56f9df94-j5lnz   php-apache   133m         11Mi

# Initial until the end:
# kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          23m
php-apache   Deployment/php-apache   17%/50%   1         10        1          24m
php-apache   Deployment/php-apache   109%/50%   1         10        1          24m
php-apache   Deployment/php-apache   241%/50%   1         10        3          24m
php-apache   Deployment/php-apache   109%/50%   1         10        5          25m
php-apache   Deployment/php-apache   184%/50%   1         10        5          25m
php-apache   Deployment/php-apache   77%/50%    1         10        5          26m
php-apache   Deployment/php-apache   69%/50%    1         10        5          26m
php-apache   Deployment/php-apache   69%/50%    1         10        6          27m
php-apache   Deployment/php-apache   2%/50%     1         10        6          27m
php-apache   Deployment/php-apache   16%/50%    1         10        6          27m
php-apache   Deployment/php-apache   2%/50%     1         10        6          27m
php-apache   Deployment/php-apache   0%/50%     1         10        6          28m
php-apache   Deployment/php-apache   0%/50%     1         10        6          32m
php-apache   Deployment/php-apache   0%/50%     1         10        2          32m
php-apache   Deployment/php-apache   0%/50%     1         10        2          32m
php-apache   Deployment/php-apache   0%/50%     1         10        1          32m
```

- [azure-kubernetes/identify-high-cpu-consuming-containers-aks](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/identify-high-cpu-consuming-containers-aks?tabs=browser#step-1-identify-nodescontainers-with-high-cpu-usage)

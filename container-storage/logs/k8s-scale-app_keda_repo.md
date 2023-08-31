```
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create ns keda
helm install keda kedacore/keda --namespace keda --version 2.10.1 --set nodeSelector."kubernetes\\.io/os"=linux

# To cleanup
# https://keda.sh/docs/1.4/deploy/#uninstall
kubectl delete ns keda
```

- https://keda.sh/docs/1.4/deploy/

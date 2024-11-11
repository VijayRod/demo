TBDc

```
# To customize the coredns config
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  log.override: | # you may select any name here, but it must end with the .override file extension
        log
EOF
kubectl delete pod --namespace kube-system -l k8s-app=kube-dns
```

https://coredns.io/plugins/log/

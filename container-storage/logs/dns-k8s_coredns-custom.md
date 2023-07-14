TBDc

coredns can be customized in AKS using the coredns-custom configmap.

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

```
# To cleanup
kubectl delete cm -n kube-system coredns-custom ## AKS recreates it in a few seconds.
kubectl delete pod --namespace kube-system -l k8s-app=kube-dns
```

```
# Useful commands
kubectl get po -A -l k8s-app=kube-dns -owide
kubectl describe cm -n kube-system coredns-custom
kubectl logs -n kube-system -l k8s-app=kube-dns --timestamps --follow
```

```
# To capture data for later analysis
- coredns logs with timestamp, and with coredns pod and node name
- Node /var/log/syslog files having events of above time.
```

TBD

- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom
- https://docs.digitalocean.com/products/kubernetes/how-to/customize-coredns/
- https://stackoverflow.com/questions/56675972/kubernetes-how-to-edit-coredns-corefile-configmap
- https://sysdig.com/blog/how-to-monitor-coredns/
- https://coredns.io/plugins/

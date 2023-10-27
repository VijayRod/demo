```
TBD
az aks nodepool add -g $rg --cluster-name aks -n npuser --mode=user -c 1 -s $vmsize
kubectl get no -l kubernetes.azure.com/mode=user,kubernetes.io/os=windows
kubectl apply -f https://raw.githubusercontent.com/ksubmsft/daemonset-repro/main/cifs-debug.ds.yaml
kubectl get po name=cifs-credits-diag
kubectl logs -l name=cifs-credits-diag
```

- TBD https://github.com/ksubmsft/daemonset-repro/blob/main/cifs-debug.ds.yaml: "/tmp/$(hostname)_*.tgz"

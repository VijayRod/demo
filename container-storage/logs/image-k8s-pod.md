```
kubectl delete po --all # -A
sleep 10; kubectl get po # -A

kubectl run nginx --image=nginx
kubectl exec -it nginx -- /bin/bash # curl google.com -I # apt-get update
kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' # https://busybox.net/about.html
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity' # kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- /bin/bash
kubectl run pause --image=registry.k8s.io/pause:3.1 --restart=Never
```

- https://kubernetes.io/docs/concepts/containers/images/
- https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/

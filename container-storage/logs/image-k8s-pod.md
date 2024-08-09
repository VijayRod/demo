```
kubectl delete po --all
sleep 10; kubectl get po

kubectl delete po --all -A
sleep 10; kubectl get po -A
```


```
# all
kubectl run nginx --image=nginx
kubectl exec -it nginx -- /bin/bash # curl google.com -I # apt-get update
kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' # https://busybox.net/about.html
kubectl run -it --rm busybox --image=busybox -- wget -qO- google.com
kubectl run -it --rm aks-ssh --image=debian:stable # apt-get update -y && apt-get install dnsutils -y && apt-get install curl -y
kubectl run pause --image=registry.k8s.io/pause:3.1 --restart=Never
```

- https://kubernetes.io/docs/concepts/containers/images/
- https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/

```
# busybox
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
kubectl run -it --rm --restart=Never busybox --image=busybox sh
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
kubectl run -it --rm nginx --image=nginx -- curl -I https://openai.com
```

- https://stackoverflow.com/questions/62847331/is-it-possible-to-install-curl-into-busybox-in-kubernetes-pod: The short answer, is you cannot.

```
# dnsutils
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity' # kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- /bin/bash

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=ubuntu # or kubectl node-shell <NodeName>
apt update && apt install dnsutils -y
```

- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

```
kubectl create deploy hostnames --image=registry.k8s.io/serve_hostname # From another pod, use curl $hostnamesPodIp:9376
```

```
kubectl describe po -n kube-system -l k8s-app=kube-dns
  coredns:
    Image:         mcr.microsoft.com/oss/kubernetes/coredns:v1.9.4
    Ports:         53/UDP, 53/TCP, 9153/TCP
    
kubectl describe svc -n kube-system -l k8s-app=kube-dns # The port 9153 is not exposed in the kube-dns service

kubectl get po -n kube-system -l k8s-app=kube-dns -owide
NAME                      READY   STATUS    RESTARTS   AGE   IP           NODE                                NOMINATED NODE   READINESS GATES
coredns-789789675-bflhr   1/1     Running   0          9h    10.244.2.5   aks-nodepool1-40004829-vmss000003   <none>           <none>
coredns-789789675-f8xnr   1/1     Running   0          9h    10.244.2.4   aks-nodepool1-40004829-vmss000003   <none>           <none>

kubectl delete po nginx
kubectl run nginx --image=nginx
sleep 5
kubectl exec -it nginx -- /bin/bash

root@nginx:/# curl http://kube-dns.kube-system.svc:53
curl: (52) Empty reply from server
root@nginx:/# curl http://kube-dns.kube-system.svc:53 -I
curl: (52) Empty reply from server
root@nginx:/# curl http://kube-dns.kube-system.svc:9153 -I
^C
root@nginx:/# curl http://10.244.2.5:9153 -I
HTTP/1.1 404 Not Found
```

```
# Workaround to expose kube-dns port 9153
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: CoreDNS
  name: my-kube-dns
  namespace: kube-system
spec:
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
  selector:
    k8s-app: kube-dns
EOF

root@nginx:/# curl http://my-kube-dns.kube-system.svc:9153 -I
HTTP/1.1 404 Not Found
```

- https://github.com/kubernetes/kubernetes/blob/v1.24.9/cluster/addons/dns/coredns/coredns.yaml.base: containerPort: 9153 name: metrics
- https://github.com/Azure/AKS/issues/3511: [Feature Request] kube-dns service not exposing metric port?. not planned

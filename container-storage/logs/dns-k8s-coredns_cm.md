```
kubectl get cm -n kube-system coredns -oyaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        ready
        health {
          lameduck 5s
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
          ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
        import custom/*.override
    }
    import custom/*.server
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"Corefile":".:53 {\n    errors\n    ready\n    health {\n      lameduck 5s\n    }\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n      pods insecure\n      fallthrough in-addr.arpa ip6.arpa\n      ttl 30\n    }\n    prometheus :9153\n    forward . /etc/resolv.conf\n    cache 30\n    loop\n    reload\n    loadbalance\n    import custom/*.override\n}\nimport custom/*.server\n"},"kind":"ConfigMap","metadata":{"annotations":{},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile","k8s-app":"kube-dns","kubernetes.io/cluster-service":"true"},"name":"coredns","namespace":"kube-system"}}
  creationTimestamp: "2023-09-08T20:58:58Z"
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
  name: coredns
  namespace: kube-system
  resourceVersion: "407"
  uid: 401977eb-277d-4182-a232-3cae386f0e51
```

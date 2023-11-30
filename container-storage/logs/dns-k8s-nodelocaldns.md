```
# TBD You can customize the node-local-dns spec to satisfy your needs, such as CPU/memory resource limits, cache TTL, affinity, etc
```

- https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/
- https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml (Remove the Reconcile label)
- https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache
- https://www.tkng.io/dns/: NodeLocal DNSCache
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/1024-nodelocal-cache-dns/README.md
<br>

- TBD https://deckhouse.io/documentation/v1/modules/350-node-local-dns/
- TBD https://www.sobyte.net/post/2021-11/use-nodelocal-dns-cache/
- TBD https://cloud.yandex.com/en/docs/managed-kubernetes/tutorials/node-local-dns
- TBD https://www.tencentcloud.com/document/product/457/34061 (This has a different Corefile config)

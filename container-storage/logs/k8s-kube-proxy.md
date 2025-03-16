```
k get all -n kube-system --show-labels | grep proxy
pod/kube-proxy-8dfx8                      1/1     Running   0          4h41m   component=kube-proxy,controller-revision-hash=6c4876fd78,kubernetes.azure.com/managedby=aks,pod-template-generation=1,tier=node
pod/kube-proxy-nxb8g                      1/1     Running   0          4h42m   component=kube-proxy,controller-revision-hash=6c4876fd78,kubernetes.azure.com/managedby=aks,pod-template-generation=1,tier=node
daemonset.apps/kube-proxy                   2         2         2       2            2           <none>          4h42m   addonmanager.kubernetes.io/mode=Reconcile,component=kube-proxy,kubernetes.azure.com/managedby=aks,tier=node

root@aks-nodepool1-21936671-vmss000000:/# ps -aux | grep proxy
root        4638  0.0  0.7 1284308 63436 ?       Ssl  09:32   0:03 kube-proxy --conntrack-max-per-core=0 --metrics-bind-address=0.0.0.0:10249 --cluster-cidr=10.244.0.0/16 --detect-local-mode=InterfaceNamePrefix --pod-interface-name-prefix=azv --v=3

root@aks-nodepool1-21936671-vmss000000:/# ip address # azv
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0d:3a:fa:80:53 brd ff:ff:ff:ff:ff:ff
    inet 10.224.0.5/16 metric 100 brd 10.224.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20d:3aff:fefa:8053/64 scope link
       valid_lft forever preferred_lft forever
4: azvb2d3df40713@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-f115b631-75d0-63ba-73e0-af0df1386810
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever
6: azvf8ce1dbadfb@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-6e36977a-de57-9019-31b3-0af1fcfec544
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever
```

- https://kubernetes.io/docs/concepts/overview/components/#kube-proxy
- https://github.com/kubernetes/kube-proxy
- *https://kubernetes.io/docs/concepts/architecture/#kube-proxy
- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/: --config-sync-period duration     Default: 15m0s. How often configuration from the apiserver is refreshed. Must be greater than 0.
- https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/#using-kubectl-proxy: kubectl proxy will authenticate to the API and expose it on the localhost interface of the Pod, so that other containers in the Pod can use it directly.
- https://kodekloud.com/blog/kube-proxy/#how-kube-proxy-works: After Kube-proxy is installed, it authenticates with the API server.

```
# kube-proxy.sync
# See the section on tcpdump
# kube-proxy must continuously communicate with the apiserver
k logs -n kube-system kube-proxy-8dfx8
I0219 18:33:49.632601       1 proxier.go:805] "Syncing iptables rules"
I0219 18:33:49.636375       1 proxier.go:1494] "Reloading service iptables data" numServices=4 numEndpoints=7 numFilterChains=6 numFilterRules=4 numNATChains=4 numNATRules=9
I0219 18:33:49.671397       1 proxier.go:799] "SyncProxyRules complete" elapsed="38.805737ms"
I0219 18:33:49.671434       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s
I0219 18:32:26.607611       1 proxier.go:805] "Syncing iptables rules"
I0219 18:32:26.610320       1 proxier.go:1494] "Reloading service iptables data" numServices=0 numEndpoints=0 numFilterChains=5 numFilterRules=3 numNATChains=4 numNATRules=5
I0219 18:32:26.643248       1 proxier.go:799] "SyncProxyRules complete" elapsed="35.641722ms"
I0219 18:32:26.643279       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s
I0219 18:33:49.671856       1 proxier.go:805] "Syncing iptables rules"
I0219 18:33:49.675340       1 proxier.go:1494] "Reloading service iptables data" numServices=4 numEndpoints=7 numFilterChains=6 numFilterRules=4 numNATChains=4 numNATRules=9
I0219 18:33:49.707383       1 proxier.go:799] "SyncProxyRules complete" elapsed="35.53798ms"
I0219 18:33:49.707490       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/iptables/proxier.go: proxier.logger.V(2).Info("Syncing iptables rules", "fullSync", doFullSync)

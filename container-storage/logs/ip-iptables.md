## iptables

```
iptables-save > /tmp/iptables
cat /tmp/iptables
```

- https://wiki.centos.org/HowTos/Network/IPTables
- https://www.man7.org/linux/man-pages/man8/iptables.8.html
- tbd https://www.baeldung.com/linux/iptables-intro

## iptables.core.chain

```
iptables -L | grep Chain
iptables -L INPUT # --line-numbers
iptables -nvL INPUT
iptables -nvL INPUT -t filter
iptables -t filter -nvL # To view all iptable chains
```

- https://thelinuxcode.com/iptables-tutorial/
- tbd https://stackoverflow.com/questions/14955973/iptables-what-is-a-chain
- https://unix.stackexchange.com/questions/506729/what-is-a-chain-in-iptables
- https://www.baeldung.com/linux/iptables-chains-tables-traversal
- https://unix.stackexchange.com/questions/189905/how-iptables-tables-and-chains-are-traversed
- https://stuffphilwrites.com/2014/09/iptables-processing-flowchart/
- https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg
- https://rlworkman.net/howtos/iptables/chunkyhtml/c962.html
- http://linux-ip.net/pages/diagrams.html#netfilter-kernel-packet-traversal
- https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture
- tbd https://cloudzy.com/blog/iptables-show-rules/
- https://thelinuxcode.com/iptables-tutorial/: https://thelinuxcode.com/iptables-tutorial/

## iptables.core.tables

```
iptables -vL -t filter
iptables -vL -t nat
iptables -vL -t mangle
iptables -vL -t raw
iptables -vL -t security
```

- https://unix.stackexchange.com/questions/205867/viewing-all-iptables-rules: iptables controls five different tables: filter, nat, mangle, raw and security. ...
- https://thelinuxcode.com/iptables-tutorial/: These built-in chains belong to various  iptables tables...

## iptables.kube-proxy

```
kubectl run nginx --image=nginx
kubectl logs -n kube-system -l component=kube-proxy
Defaulted container "kube-proxy" out of: kube-proxy, kube-proxy-bootstrap (init)
I0913 18:17:34.400497       1 endpointslicecache.go:348] "Setting endpoints for service port name" portName="default/nginx" endpoints=["10.244.0.14:80"]
I0913 18:17:34.400576       1 proxier.go:798] "Syncing iptables rules"
I0913 18:17:34.403738       1 proxier.go:1508] "Reloading service iptables data" numServices=5 numEndpoints=8 numFilterChains=6 numFilterRules=4 numNATChains=7 numNATRules=18
I0913 18:17:34.422143       1 proxier.go:792] "SyncProxyRules complete" elapsed="21.67114ms"
I0913 18:17:34.422160       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s

kubectl get ds -n kube-system -l component=kube-proxy
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-proxy   1         1         1       1            1           <none>          5d7h

kubectl describe po -n kube-system -l component=kube-proxy
Containers:
  kube-proxy:
    Container ID:  containerd://f569efd14bd10a34f092fada341ddff34c673915c8a525102471f03d62d87d00
    Image:         mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.7
    Image ID:      sha256:822d5c9ec9537805bc26748498d6ac50d02da464690503af84409fa3ec04c909
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-proxy
      --conntrack-max-per-core=0
      --metrics-bind-address=0.0.0.0:10249
      --cluster-cidr=10.251.0.0/16
      --detect-local-mode=InterfaceNamePrefix
      --pod-interface-name-prefix=azv
      --v=3
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/
- https://kubernetes.io/docs/concepts/overview/components/#node-components: kube-proxy (optional). Maintains network rules on nodes to implement Services.

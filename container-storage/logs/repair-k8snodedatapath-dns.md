> ## dns.coredns

```
kubectl get po -n kube-system -l k8s-app=kube-dns
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler
kubectl -n kube-system top pod | grep coredns
```

- https://kubernetes.io/docs/tasks/access-application-cluster/configure-dns-cluster/: CoreDNS is recommended and is installed by default with kubeadm
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
- https://www.tkng.io/dns/
- https://github.com/kubernetes/dns: repository for Kubernetes DNS(kube-dns and nodelocaldns)
- https://github.com/kubernetes/kubernetes/blob/v1.24.9/cluster/addons/dns/coredns/coredns.yaml.base
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time

> ## dns.coredns.plugin
- https://coredns.io/plugins/
- https://github.com/coredns/coredns/blob/master/plugin/cache/README.md: README for each plugin
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#plugin-support

> ## dns.coredns.configmap.custom

```
kubectl describe cm -n kube-system coredns-autoscaler # in a default cluster
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler#control-patterns-and-configmap-formats

> ## dns.coredns.configmap.custom.ladder

```
# 8 replicas
k get po -n kube-system -l k8s-app=kube-dns
cat << EOF | kubectl apply -f -
apiVersion: v1
data:
  ladder: '{"coresToReplicas":[[1,8]],"nodesToReplicas":[[1,8]]}'
kind: ConfigMap
metadata:
  name: coredns-autoscaler
  namespace: kube-system
EOF
k get po -n kube-system -l k8s-app=kube-dns -w
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler?tab=readme-ov-file#ladder-mode

> ## dns.coredns.pod.autoscaler

```
# See coredns config map
```
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling

> ## dns.coredns.pod.autoscaler.OOMKilled

```
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler

kubectl describe cm -n kube-system coredns-autoscaler
Name:         coredns-autoscaler
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>
Data
====
ladder:
----
{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}
BinaryData
====
Events:  <none>

kubectl get configmap coredns-autoscaler -n kube-system -o yaml
apiVersion: v1
data:
  ladder: '{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}'
kind: ConfigMap
metadata:
  creationTimestamp: "2023-09-08T20:59:36Z"
  name: coredns-autoscaler
  namespace: kube-system
  resourceVersion: "1069"
  uid: 96464cfe-6b07-46c6-b140-336f70f95ea4
```

- https://github.com/coredns/coredns/issues/3388: The coredns pods always restart because of OOMKilled. In kubernetes, CoreDNS memory usage primarily correlates to the number of services/endpoints in the cluster...
- https://coredns.io/2018/11/15/scaling-coredns-in-kubernetes-clusters/: CoreDNS’s memory usage is predominantly affected by the number of Pods and Services in the cluster
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling: Sudden spikes in DNS traffic... Out of memory issues
- TBD https://creators-note.chatwork.com/entry/stabilize-kubernetes-dns: Deploy dns-autoscaler

> ## dns.coredns.plugin..custom-domain
```
# These steps are similar to those for a private cluster with a private DNS zone
clustername=akscustomdomain
az aks create -g $rgname -n $clustername --enable-managed-identity --assign-identity $identityUri --vnet-subnet-id $subnetId
fqdn=$(az aks show -g $rgname -n $clustername --query fqdn -otsv); nslookup $fqdn

# To add an A record
az network private-dns record-set a add-record -g $rgname -z $privatezone -n db -a 20.91.129.141 # IP of the cluster FQDN

# To test in a cluster node with ping, ensure that the private DNS zone record returns the IP of the cluster FQDN
az aks get-credentials -g $rgname -n $clustername
root@aks-nodepool1-38956877-vmss000000:/# ping db.private.contoso.com
PING db.private.contoso.com (20.91.129.141) 56(84) bytes of data.

# To configure the CoreDNS config map
azureVip="168.63.129.16"
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  puglife.server: | # you may select any name here, but it must end with the .server file extension
    db.$privatezone:53 {
        errors
        cache 30
        forward . $azureVip  # this is my test/dev DNS server
    }
EOF
kubectl get cm -n kube-system coredns-custom -oyaml
kubectl -n kube-system rollout restart deployment coredns
kubectl get po -n kube-system -l k8s-app=kube-dns
```

```
# To test ping of the A record from a pod. Returns the IP of the cluster FQDN, i.e., 20.91.129.141.
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- nslookup db.private.contoso.com
```

- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#use-custom-domains

> ## dns.coredns.plugin.header
- https://coredns.io/plugins/header/
- https://qasim-sarfraz.medium.com/dns-caching-gone-wrong-a329dc00452e

> ## dns.coredns.plugin.forward
- https://coredns.io/plugins/forward/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#custom-forward-server

> ## dns.coredns.plugin.hosts
- https://coredns.io/plugins/hosts/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#hosts-plugin

> ## dns.coredns.plugin.log
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
- https://coredns.io/plugins/log/

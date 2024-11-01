## k8s-cni-calico

```
akscal
aks-nodepool1-36628055-vmss000000:/# ps -aux | grep calico
10001       7074  0.0  0.0   1156     4 ?        Ss   04:14   0:00 /sbin/tini -- calico-typha
10001       7087  0.0  0.6 1789200 55200 ?       Sl   04:14   0:01 calico-typha
root        7646  0.0  0.6 1689020 55160 ?       Sl   04:14   0:00 calico-node -status-reporter
root        7647  0.0  0.7 1762752 59420 ?       Sl   04:14   0:00 calico-node -allocate-tunnel-addrs
root        7649  0.6  0.8 2131924 65100 ?       Sl   04:14   0:10 calico-node -felix
root        7672  0.0  0.0   4476   860 ?        S    04:14   0:00 svlogd -ttt /var/log/calico/allocate-tunnel-addrs
root        7674  0.0  0.0   4476   940 ?        S    04:14   0:00 svlogd -ttt /var/log/calico/felix
root        7677  0.0  0.0   4476   856 ?        S    04:14   0:00 svlogd -ttt /var/log/calico/node-status-reporter

akskubecal - /var/log/calico/cni
aks-nodepool1-64104225-vmss000000:/# ps -aux | grep calico
root        6199  0.0  0.6 1762752 54804 ?       Sl   04:17   0:00 calico-node -monitor-token
root        6204  0.0  0.6 1689020 52252 ?       Sl   04:17   0:00 calico-node -allocate-tunnel-addrs
root        6223  0.0  0.0   4476   864 ?        S    04:17   0:00 svlogd -ttt /var/log/calico/allocate-tunnel-addrs
root        6225  0.0  0.0   4476   852 ?        S    04:17   0:00 svlogd -ttt /var/log/calico/felix
root        6237  0.0  0.0   4476   940 ?        S    04:17   0:00 svlogd -ttt /var/log/calico/cni
root        6238  0.0  0.0   4476   840 ?        S    04:17   0:00 svlogd -ttt /var/log/calico/node-status-reporter
10001       6339  0.0  0.0   1156     4 ?        Ss   04:17   0:00 /sbin/tini -- calico-typha
10001       6352  0.0  0.7 1862932 58872 ?       Sl   04:17   0:01 calico-typha
root        6363  0.0  0.6 1836484 53916 ?       Sl   04:17   0:00 calico-node -status-reporter
root        6396  0.7  0.7 2205400 64148 ?       Sl   04:17   0:10 calico-node -felix
```

```
kubectl get installation default -o go-template --template {{.spec.cni.ipam.type}} # HostLocal
# kubectl get installations.operator.tigera.io default -o yaml

kubectl api-resources | grep install
installations                                           operator.tigera.io/v1                  false        Installation

kubectl describe installation default
Name:         default
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
Annotations:  <none>
API Version:  operator.tigera.io/v1
Kind:         Installation
Metadata:
  Creation Timestamp:  2024-09-11T18:15:03Z
  Finalizers:
    tigera.io/operator-cleanup
  Generation:        1226
  Resource Version:  96457
  UID:               c09eaf5f-f317-4ceb-ae3a-ee3b77a9eb5f
Spec:
  Calico Network:
    Bgp:                      Disabled
    Container IP Forwarding:  Enabled
    Host Ports:               Enabled
    Ip Pools:
      Block Size:          26
      Cidr:                10.244.0.0/16
      Disable BGP Export:  false
      Encapsulation:       None
      Nat Outgoing:        Enabled
      Node Selector:       all()
    Linux Dataplane:       Iptables
    Multi Interface Mode:  None
    nodeAddressAutodetectionV4:
      First Found:  true
  Calico Node Daemon Set:
    Spec:
      Template:
        Spec:
          Affinity:
            Node Affinity:
              Required During Scheduling Ignored During Execution:
                Node Selector Terms:
                  Match Expressions:
                    Key:       kubernetes.azure.com/ebpf-dataplane
                    Operator:  NotIn
                    Values:
                      cilium
                    Key:       kubernetes.azure.com/network-policy
                    Operator:  NotIn
                    Values:
                      none
                    Key:       kubernetes.azure.com/cluster
                    Operator:  Exists
                    Key:       type
                    Operator:  NotIn
                    Values:
                      virtual-kubelet
                    Key:       kubernetes.io/os
                    Operator:  In
                    Values:
                      linux
  Cni:
    Ipam:
      Type:                HostLocal
    Type:                  Calico
  Control Plane Replicas:  2
  Control Plane Tolerations:
    Key:                       CriticalAddonsOnly
    Operator:                  Exists
  Flex Volume Path:            /etc/kubernetes/volumeplugins/
  Image Path:                  oss/calico
  Kubelet Volume Plugin Path:  None
  Kubernetes Provider:         AKS
  Logging:
    Cni:
      Log File Max Age Days:  30
      Log File Max Count:     10
      Log File Max Size:      100Mi
      Log Severity:           Info
  Node Update Strategy:
    Rolling Update:
      Max Unavailable:  1
    Type:               RollingUpdate
  Non Privileged:       Disabled
  Registry:             mcr.microsoft.com/
  Typha Affinity:
    Node Affinity:
      Preferred During Scheduling Ignored During Execution:
        Preference:
          Match Expressions:
            Key:       kubernetes.azure.com/mode
            Operator:  In
            Values:
              system
        Weight:  100
  Variant:       Calico
Status:
  Calico Version:  v3.26.3
  Computed:
    Calico Network:
      Bgp:                      Disabled
      Container IP Forwarding:  Enabled
      Host Ports:               Enabled
      Ip Pools:
        Block Size:          26
        Cidr:                10.244.0.0/16
        Disable BGP Export:  false
        Encapsulation:       None
        Nat Outgoing:        Enabled
        Node Selector:       all()
      Linux Dataplane:       Iptables
      Multi Interface Mode:  None
      nodeAddressAutodetectionV4:
        First Found:  true
    Calico Node Daemon Set:
      Spec:
        Template:
          Spec:
            Affinity:
              Node Affinity:
                Required During Scheduling Ignored During Execution:
                  Node Selector Terms:
                    Match Expressions:
                      Key:       kubernetes.azure.com/ebpf-dataplane
                      Operator:  NotIn
                      Values:
                        cilium
                      Key:       kubernetes.azure.com/network-policy
                      Operator:  NotIn
                      Values:
                        none
                      Key:       kubernetes.azure.com/cluster
                      Operator:  Exists
                      Key:       type
                      Operator:  NotIn
                      Values:
                        virtual-kubelet
                      Key:       kubernetes.io/os
                      Operator:  In
                      Values:
                        linux
    Cni:
      Ipam:
        Type:                HostLocal
      Type:                  Calico
    Control Plane Replicas:  2
    Control Plane Tolerations:
      Key:                       CriticalAddonsOnly
      Operator:                  Exists
    Flex Volume Path:            /etc/kubernetes/volumeplugins/
    Image Path:                  oss/calico
    Kubelet Volume Plugin Path:  None
    Kubernetes Provider:         AKS
    Logging:
      Cni:
        Log File Max Age Days:  30
        Log File Max Count:     10
        Log File Max Size:      100Mi
        Log Severity:           Info
    Node Update Strategy:
      Rolling Update:
        Max Unavailable:  1
      Type:               RollingUpdate
    Non Privileged:       Disabled
    Registry:             mcr.microsoft.com/
    Typha Affinity:
      Node Affinity:
        Preferred During Scheduling Ignored During Execution:
          Preference:
            Match Expressions:
              Key:       kubernetes.azure.com/mode
              Operator:  In
              Values:
                system
          Weight:  100
    Variant:       Calico
  Conditions:
    Last Transition Time:  2024-09-11T18:31:13Z
    Message:               All Objects Available
    Observed Generation:   1226
    Reason:                AllObjectsAvailable
    Status:                False
    Type:                  Degraded
    Last Transition Time:  2024-09-11T18:31:13Z
    Message:               All objects available
    Observed Generation:   1226
    Reason:                AllObjectsAvailable
    Status:                True
    Type:                  Ready
    Last Transition Time:  2024-09-11T18:31:13Z
    Message:               All Objects Available
    Observed Generation:   1226
    Reason:                AllObjectsAvailable
    Status:                False
    Type:                  Progressing
  Image Set:               calico-v3.26.3
  Mtu:                     1500
  Variant:                 Calico
Events:                    <none>
```

```
akscal
kubectl get po -A | grep cal
calico-system     calico-kube-controllers-6c6485578f-9gzpz   1/1     Running   0             46m
calico-system     calico-node-7vn5m                          1/1     Running   0             46m
calico-system     calico-typha-74c7b5bdf6-xj4vc              1/1     Running   0             46m

akskubecal
kubectl get po -A | grep cal
calico-system     calico-kube-controllers-86845c4bdd-bt2zx   1/1     Running   0          44m
calico-system     calico-node-x4ljj                          1/1     Running   0          44m
calico-system     calico-typha-78fc59998c-8flzt              1/1     Running   0          44m
```

- https://www.tigera.io/blog/byocni-introducing-calico-cni-for-azure-aks/

## k8s-cni-calico.spec.ippool

```
k api-resources
ippools                                                 crd.projectcalico.org/v1               false        IPPool
k get installation default -oyaml
spec:
  calicoNetwork:
    bgp: Disabled
    ipPools: []
k get ippool
No resources found

cat << EOF | kubectl create -f -
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: myippool
spec:
  cidr: 10.1.0.0/16
  ipipMode: CrossSubnet
  natOutgoing: true
  disabled: false
  nodeSelector: all()
  allowedUses:
    - Workload
    - Tunnel
EOF
k get installation default -oyaml
spec:
  calicoNetwork:
    bgp: Disabled
    ipPools: []
k get ippool
NAME       AGE
myippool   55s
```
    
- https://docs.tigera.io/calico/latest/reference/resources/ippool
- https://docs.tigera.io/calico-enterprise/latest/networking/ipam/initial-ippool
- https://docs.tigera.io/calico/latest/getting-started/kubernetes/hardway/configure-ip-pools

## k8s-cni-calico.spec.other.opensource

```
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
```

- https://docs.projectcalico.org/v3.14/manifests/calico.yaml

## ipmasq

```

akscal
aks-nodepool1-36628055-vmss000000:/# ps -aux | grep masq
root        4233  0.0  0.1 718992 15820 ?        Ssl  04:13   0:00 /ip-masq-agent-v2 --v=2 --resync-interval=60

akskubecal
aks-nodepool1-64104225-vmss000000:/# ps -aux | grep masq
No rows

akskube
aks-nodepool1-10522532-vmss000000:/# ps -aux | grep masq
root        4541  0.0  0.2 719888 17992 ?        Ssl  10:19   0:00 /ip-masq-agent-v2 --v=2 --resync-interval=60
```

- https://www.tkng.io/ingress/egress/
- https://kubernetes.io/docs/tasks/administer-cluster/ip-masq-agent/
- https://github.com/Azure/ip-masq-agent-v2
- https://cloud.google.com/kubernetes-engine/docs/concepts/ip-masquerade-agent
- https://github.com/kubernetes-sigs/ip-masq-agent
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay: azure-ip-masq-agent
- https://stevegriffith.nyc/posts/aks-cni-calico-ipmasq/

## ipmasq|nat

- https://serverfault.com/questions/119365/what-is-the-difference-between-a-source-nat-destination-nat-and-masquerading: ...Masquerading is a special form of Source NAT where the source address is unknown at the time the rule is added to the tables in the kernel. ...
- https://unix.stackexchange.com/questions/21967/difference-between-snat-and-masquerade: MASQUERADE does NOT require --to-source as it was made to work with dynamically assigned IPs. SNAT works ONLY with static IPs...
- tbd https://serverfault.com/questions/1083523/why-does-everybody-use-masquerade-snat-instead-of-napt-pat

## ipmasq.akscal

```
aks-nodepool1-36628055-vmss000000:/# iptables-save | grep masq
-A POSTROUTING -m comment --comment "\"ip-masq-agent: ensure nat POSTROUTING directs all non-LOCAL destination traffic to our custom IP-MASQ-AGENT chain\"" -m addrtype ! --dst-type LOCAL -j IP-MASQ-AGENT
-A IP-MASQ-AGENT -d 10.224.0.0/16 -m comment --comment "ip-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A IP-MASQ-AGENT -d 10.0.0.0/16 -m comment --comment "ip-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A IP-MASQ-AGENT -d 10.224.0.0/12 -m comment --comment "ip-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A IP-MASQ-AGENT -m comment --comment "ip-masq-agent: outbound traffic is subject to MASQUERADE (must be last in chain)" -j MASQUERADE

kubectl get po -n kube-system --show-labels| grep masq # single node cluster
azure-ip-masq-agent-xpvjn             1/1     Running   0          17h   controller-revision-hash=694d4d7dcd,k8s-app=azure-ip-masq-agent,kubernetes.azure.com/managedby=aks,pod-template-generation=1,tier=node

kubectl describe cm -n kube-system azure-ip-masq-agent-config-reconciled
Name:         azure-ip-masq-agent-config-reconciled
Namespace:    kube-system
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              component=ip-masq-agent
              kubernetes.io/cluster-service=true
Annotations:  <none>

Data
====
ip-masq-agent-reconciled:
----
nonMasqueradeCIDRs:
  - 10.224.0.0/16
  - 10.0.0.0/16
  - 10.224.0.0/12
masqLinkLocal: true

BinaryData
====

Events:  <none>

az aks show -g $rg -n akscal --query networkProfile
  "podCidr": null,
  "podCidrs": null,
  "serviceCidr": "10.0.0.0/16",
  "serviceCidrs": [
    "10.0.0.0/16"
  ],
  
az network vnet show -g MC_rg_akscal_swedencentral -n aks-vnet-39458073 --query addressSpace.addressPrefixes -otsv # 10.224.0.0/12

az network vnet subnet show -g MC_rg_akscal_swedencentral --vnet-name aks-vnet-39458073 -n aks-subnet --query addressPrefix -otsv # 10.224.0.0/16
```

## ipmasq.akskube

```
aks-nodepool1-10522532-vmss000000:/# iptables-save | grep masq
-A POSTROUTING -m comment --comment "\"ip-masq-agent: ensure nat POSTROUTING directs all non-LOCAL destination traffic to our custom IP-MASQ-AGENT chain\"" -m addrtype ! --dst-type LOCAL -j IP-MASQ-AGENT
-A IP-MASQ-AGENT -d 10.244.0.0/16 -m comment --comment "ip-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A IP-MASQ-AGENT -m comment --comment "ip-masq-agent: outbound traffic is subject to MASQUERADE (must be last in chain)" -j MASQUERADE

kubectl get po -n kube-system | grep masq # three node cluster
kube-system   azure-ip-masq-agent-hm4n2             1/1     Running   0          11h
kube-system   azure-ip-masq-agent-ht2tj             1/1     Running   0          11h
kube-system   azure-ip-masq-agent-rtc8z             1/1     Running   0          11h

kubectl describe cm -n kube-system azure-ip-masq-agent-config-reconciled
Name:         azure-ip-masq-agent-config-reconciled
Namespace:    kube-system
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              component=ip-masq-agent
              kubernetes.io/cluster-service=true
Annotations:  <none>

Data
====
ip-masq-agent-reconciled:
----
nonMasqueradeCIDRs:
  - 10.244.0.0/16
masqLinkLocal: true

BinaryData
====

Events:  <none>

az aks show -g $rg -n akskube --query networkProfile
  "podCidr": "10.244.0.0/16",
  "podCidrs": [
    "10.244.0.0/16"
  ],
  "serviceCidr": "10.0.0.0/16",
  "serviceCidrs": [
    "10.0.0.0/16"
  ],
  
az network vnet subnet show -g MC_rg_akskube_swedencentral --vnet-name aks-vnet-12544801 -n aks-subnet --query addressPrefix -otsv # 10.224.0.0/16
```

## ipmasq.nonMasqueradeCIDRs

```

```

- https://tldp.org/HOWTO/IP-Masquerade-HOWTO/index.html
- https://wiki.debian.org/IP%20Masquerade%20%28also%20known%20as%20Internet%20Connection%20Sharing%29

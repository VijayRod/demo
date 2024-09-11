```
az aks get-credentials -g $rg -n akskubecal --overwrite-existing
kubectl get installation default -o go-template --template {{.spec.cni.ipam.type}} # HostLocal

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

- https://www.tigera.io/blog/byocni-introducing-calico-cni-for-azure-aks/

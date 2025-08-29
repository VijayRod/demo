- https://github.com/Azure/AKS/issues/3715#issuecomment-1610339833
- https://github.com/google/cadvisor
- https://github.com/google/cadvisor/blob/master/docs/storage/README.md
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/: container runtime does not publish usage statistics, then the kubelet can look up those statistics directly (using code from cAdvisor)
- https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/: kubelet also exposes metrics in /metrics/cadvisor (endpoint)
- https://prometheus.io/docs/guides/cadvisor/: cAdvisor (short for container Advisor) analyzes and exposes resource usage and performance data from running containers. cAdvisor exposes Prometheus metrics out of the box. 
- https://github.com/google/cadvisor/blob/master/README.md

```
# k8s.metrics.cadvisor
# cadvisor is embedded in the kubelet and collects container resource usage metrics

kubectl get no
node=aks-nodepool1-14237402-vmss000000

kubectl get --raw /api/v1/nodes/$node/proxy/metrics/cadvisor | grep counter # list all unique metric names exposed by cadvisor

kubectl get --raw /api/v1/nodes/$node/proxy/metrics/cadvisor # display all metric values exposed by cadvisor

kubectl get --raw "/api/v1/nodes/$node/proxy/metrics/cadvisor" | grep container_network_transmit_bytes_total # display the value of a specific metric
container_network_transmit_bytes_total{container="",id="/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod06a0b8ac_1ec4_4058_982d_3a175e1f0458.slice/cri-containerd-9f168f96353bec90282cbbf7f1daadfd119e1bc389c40b9ee256c45870894f0d.scope",image="mcr.microsoft.com/oss/kubernetes/pause:3.6",interface="azvff12be2e516",name="9f168f96353bec90282cbbf7f1daadfd119e1bc389c40b9ee256c45870894f0d",namespace="kube-system",pod="csi-azuredisk-node-zq544"} 686901 1756297910854

kubectl get --raw "/api/v1/nodes/$node/proxy/metrics/cadvisor" | head
# HELP cadvisor_version_info A metric with a constant '1' value labeled by kernel version, OS version, docker version, cadvisor version & cadvisor revision.
# TYPE cadvisor_version_info gauge
cadvisor_version_info{cadvisorRevision="",cadvisorVersion="",dockerVersion="",kernelVersion="5.15.0-1092-azure",osVersion="Ubuntu 22.04.5 LTS"} 1
# HELP container_blkio_device_usage_total Blkio Device bytes usage
# TYPE container_blkio_device_usage_total counter
container_blkio_device_usage_total{container="",device="",id="/",image="",major="11",minor="0",name="",namespace="",operation="Read",pod=""} 286720 1756299529852

root@aks-nodepool1-14237402-vmss000000:/# curl http://localhost:8080
curl: (7) Failed to connect to localhost port 8080 after 0 ms: Connection refused
```

- https://deepwiki.com/google/cadvisor/4-metrics-collection-and-exposition: cAdvisor collects metrics from containers using container runtime-specific handlers

```
# k8s.metrics.kubelet
# kubelet exposes cadvisor metrics via the /metrics and /metrics/cadvisor endpoints
```

```
# k8s.metrics.metrics-server
# metrics-server is included by default in AKS clusters
# metrics-server accesses the kubelet API to collect resource usage metrics and exposes them via the kubernetes metrics API
# these metrics are used by kubectl top, HPA and VPA

k describe po -n kube-system -l k8s-app=metrics-server | grep Image:
    Image:         mcr.microsoft.com/oss/v2/kubernetes/autoscaler/addon-resizer:v1.8.23-4
    Image:         mcr.microsoft.com/oss/v2/kubernetes/metrics-server:v0.7.2-7
```

```
# k8s.metrics.prometheus
# prometheus metrics are not available by default in a newly created AKS cluster

az aks update -g $rg -n aks --enable-azure-monitor-metrics
az aks show -g $rg -n aks --query azureMonitorProfile
The behavior of this command has been altered by the following extension: aks-preview
{
  "appMonitoring": null,
  "containerInsights": null,
  "metrics": {
    "enabled": true,
    "kubeStateMetrics": {
      "metricAnnotationsAllowList": "",
      "metricLabelsAllowlist": ""
    }
  }
}

k get po -A --show-labels | grep ama
kube-system   ama-metrics-dfd7bcd6-blw66                           2/2     Running   0             17m     kubernetes.azure.com/managedby=aks,pod-template-hash=dfd7bcd6,rsName=ama-metrics
kube-system   ama-metrics-dfd7bcd6-v5hft                           2/2     Running   0             17m     kubernetes.azure.com/managedby=aks,pod-template-hash=dfd7bcd6,rsName=ama-metrics
kube-system   ama-metrics-ksm-bcfdd7489-kl56h                      1/1     Running   0             17m     app.kubernetes.io/component=ama-metrics,app.kubernetes.io/name=ama-metrics-ksm,app.kubernetes.io/part-of=ama-metrics-ksm,app.kubernetes.io/version=2.15.0-4,helm.sh/chart=azure-monitor-metrics-addon-0.1.0,kubernetes.azure.com/managedby=aks,pod-template-hash=bcfdd7489
kube-system   ama-metrics-node-2r9hw                               2/2     Running   0             17m     controller-revision-hash=667cdc5fcb,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
kube-system   ama-metrics-node-db72g                               2/2     Running   0             17m     controller-revision-hash=667cdc5fcb,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
kube-system   ama-metrics-node-qgmhv                               2/2     Running   0             17m     controller-revision-hash=667cdc5fcb,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
kube-system   ama-metrics-operator-targets-6dcb9df5df-kfsb5        2/2     Running   2 (17m ago)   17m     kubernetes.azure.com/managedby=aks,pod-template-hash=6dcb9df5df,rsName=ama-metrics-operator-targets

k get all -A | grep ama
kube-system   pod/ama-metrics-dfd7bcd6-blw66                           2/2     Running   0             18m
kube-system   pod/ama-metrics-dfd7bcd6-v5hft                           2/2     Running   0             18m
kube-system   pod/ama-metrics-ksm-bcfdd7489-kl56h                      1/1     Running   0             18m
kube-system   pod/ama-metrics-node-2r9hw                               2/2     Running   0             18m
kube-system   pod/ama-metrics-node-db72g                               2/2     Running   0             18m
kube-system   pod/ama-metrics-node-qgmhv                               2/2     Running   0             18m
kube-system   pod/ama-metrics-operator-targets-6dcb9df5df-kfsb5        2/2     Running   2 (18m ago)   18m
kube-system   service/ama-metrics-ksm                ClusterIP   10.0.11.244    <none>        8080/TCP         18m
kube-system   service/ama-metrics-operator-targets   ClusterIP   10.0.43.242    <none>        80/TCP,443/TCP   18m
kube-system   daemonset.apps/ama-metrics-node                  3         3         3       3            3           <none>                     18m
kube-system   daemonset.apps/ama-metrics-win-node              0         0         0       0            0           <none>                     18m
kube-system   deployment.apps/ama-metrics                         2/2     2            2           18m
kube-system   deployment.apps/ama-metrics-ksm                     1/1     1            1           18m
kube-system   deployment.apps/ama-metrics-operator-targets        1/1     1            1           18m
kube-system   replicaset.apps/ama-metrics-dfd7bcd6                           2         2         2       18m
kube-system   replicaset.apps/ama-metrics-ksm-bcfdd7489                      1         1         1       18m
kube-system   replicaset.apps/ama-metrics-operator-targets-6dcb9df5df        1         1         1       18m
kube-system   horizontalpodautoscaler.autoscaling/ama-metrics-hpa   Deployment/ama-metrics   memory: 234563584/5Gi   2         24        2          18m

kubectl port-forward -n kube-system $(kubectl get pod -n kube-system -l rsName=ama-metrics -o name) 9090:9090

kubectl get pod -l rsName=ama-metrics -n kube-system -o yaml | grep containerPort
kubectl port-forward svc/prometheus-server 9090:9090 -n kube-system # not exposed by default; may be available with the community edition of prometheus
kubectl port-forward svc/ama-metrics-ksm 8080:8080 -n kube-system
http://localhost:8080/
http://localhost:8080/metrics
```

- https://deepwiki.com/google/cadvisor/4.1-prometheus-integration: cAdvisor exposes a Prometheus endpoint that can be scraped by Prometheus servers. 
- https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md: (shows the metrics that are available)

```
# metrics.user.network

# container_network_transmit_bytes_total: high byte count in the node's network namespace (this includes pods using the host network)
# you can use commands like ss and netstat (no installation needed) on the node to identify network bandwidth consumers
# ss has Recv-Q, and Send-Q, and the associated process
# netstat has Recv-Q and Send-Q, and the associated process (ss is the preferred tool)

ip -s link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX:  bytes packets errors dropped  missed   mcast
      17721561  218212      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
      17721561  218212      0       0       0       0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 60:45:bd:aa:53:29 brd ff:ff:ff:ff:ff:ff
    RX:  bytes packets errors dropped  missed   mcast
    1529920766 1245677      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
     262542206  337942      0       0       0       0
4: azvd793d6ee674@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-8eb4fa79-d22a-1d90-e722-aa543b92a3d0
    RX:  bytes packets errors dropped  missed   mcast
       1444021   16398      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
       7358143   15321      0       0       0       0

ethtool -S azvd793d6ee674
NIC statistics:
     peer_ifindex: 3
     rx_queue_0_xdp_packets: 0
     rx_queue_0_xdp_bytes: 0
     rx_queue_0_drops: 0
     rx_queue_0_xdp_redirect: 0
     rx_queue_0_xdp_drops: 0
     rx_queue_0_xdp_tx: 0
     rx_queue_0_xdp_tx_errors: 0
     tx_queue_0_xdp_xmit: 0
     tx_queue_0_xdp_xmit_errors: 0

ls -l /proc/*/ns/net | grep azvd793d6ee674
lrwxrwxrwx 1 root            root            0 Aug 27 08:59 /proc/1/ns/net -> 'net:[4026531840]'

nsenter --net=/var/run/netns/cni-8eb4fa79-d22a-1d90-e722-aa543b92a3d0 ps aux

ps -fp 1
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 08:06 ?        00:00:14 /sbin/init

ss -tunap
Netid     State         Recv-Q     Send-Q               Local Address:Port                   Peer Address:Port      Process
udp       UNCONN        0          0                    127.0.0.53%lo:53                          0.0.0.0:*          users:(("systemd-resolve",pid=601,fd=13))

ss -tunap | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | sort | uniq -c | sort -nr

netstat -tunp # cannot sort this output automatically. ss is preferred
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 10.224.0.5:53064        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:52964        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:58436        10.224.0.5:10092        TIME_WAIT   -
tcp        0      0 10.224.0.5:52406        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:52986        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:58624        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:58792        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:58570        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:52996        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.5:52402        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 127.0.0.1:37287         127.0.0.1:47960         ESTABLISHED 2938/containerd

netstat -aonp | head
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name     Timer
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      601/systemd-resolve  off (0.00/0/0)
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      3940/kubelet         off (0.00/0/0)
tcp        0      0 10.224.0.5:19100        0.0.0.0:*               LISTEN      21667/node-exporter  off (0.00/0/0)

apt install nethogs -y && nethogs eth0
apt install iftop -y && iftop -i eth0
...

## tcpdump.app.k8s.dumpy

```
kubectl krew install dumpy

kubectl dumpy get
kubectl dumpy capture pod nginx
# kubectl dumpy capture deploy keda-operator -n kube-system
# kubectl dumpy capture node worker-node
# kubectl dumpy capture node all

# kubectl dumpy get dumpy-43945520
kubectl dumpy export dumpy-43945520 /tmp/tcpdump
# kubectl dumpy stop dumpy-43945520
kubectl dumpy delete dumpy-43945520 # Or k delete po --all # pod "sniffer-dumpy-59308185-2320" deleted
ls /tmp/tcpdump/dumpy*


kubectl dumpy capture pod nginx
Getting target resource info..
Dumpy init
Capture name: dumpy-43945520
  PodName: nginx
  ContainerName: nginx
  ContainerID: 9345aa4378e597e1140ab219fb3e9c353d2b143e66db0d5f5da66ea338f2537b
  NodeName: aks-nodepool1-12914153-vmss000000
sniffer-dumpy-43945520-6041 started sniffing
All dumpy sniffers are Ready.

kubectl dumpy get
NAME            NAMESPACE  TARGET     TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------  ------     ---------------  --------------  --------
dumpy-43945520  default    pod/nginx  default          -i any          1/1

kubectl dumpy get dumpy-43945520
Getting capture details..
name: dumpy-43945520
namespace: default
tcpdumpfilters: -i any
image: larrytheslap/dumpy:0.2.0
targetSpec:
    name: nginx
    namespace: default
    type: pod
    container: nginx
    items:
        nginx  <-----  sniffer-dumpy-43945520-6041 [Running]
pvc:
pullsecret:

kubectl dumpy export dumpy-43945520 /tmp/tcpdump
Downloading capture dumps from sniffers:
  nginx ---> path /tmp/tcpdump/dumpy-43945520-nginx.pcap
  
kubectl dumpy stop dumpy-43945520
Stopping capture dumpy-43945520..
sniffer-dumpy-43945520-6041 stopped
dumpy-43945520 sniffers have been successfully stopped

kubectl dumpy delete -n kube-system dumpy-43945520
deleting sniffer-dumpy-43945520-6041
dumpy capture dumpy-43945520 successfully deleted


ls /tmp/tcpdump/dumpy*
/tmp/tcpdump/dumpy-43945520-nginx.pcap

kubectl get po -A | grep snif
default       sniffer-dumpy-43945520-6041          0/1     Completed   0          7m3s # Else this indicates it's in a Running state if it is still capturing

kubectl dumpy get
NAME            NAMESPACE  TARGET     TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------  ------     ---------------  --------------  --------
dumpy-43945520  default    pod/nginx  default          -i any          0/1


kubectl dumpy capture deploy keda-operator -n kube-system
Getting target resource info..
Dumpy init
Capture name: dumpy-09671733
  PodName: keda-operator-5c76fdd585-94pmg
  ContainerName: keda-operator
  ContainerID: 0c86a8bfd850b92aed8ca4990f5b70a8e348c7e0a2d077da7d7562abb716f801
  NodeName: aks-nodepool1-10714812-vmss000000
  PodName: keda-operator-5c76fdd585-6tmzs
  ContainerName: keda-operator
  ContainerID: 0e5c11efcd5e8d270ff3090fe99217c253663d6e4e0f64a41aedd739d3b8bb67
  NodeName: aks-nodepool1-10714812-vmss000000
sniffer-dumpy-09671733-1817 started sniffing
sniffer-dumpy-09671733-1302 started sniffing
All dumpy sniffers are Ready.

kubectl dumpy get -n kube-system
NAME            NAMESPACE    TARGET                    TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------    ------                    ---------------  --------------  --------
dumpy-09671733  kube-system  deployment/keda-operator  kube-system      -i any          2/2

kubectl dumpy get -n kube-system dumpy-09671733
Getting capture details..
name: dumpy-09671733
namespace: kube-system
tcpdumpfilters: -i any
image: larrytheslap/dumpy:0.2.0
targetSpec:
    name: keda-operator
    namespace: kube-system
    type: deployment
    container: keda-operator
    items:
        keda-operator-5c76fdd585-94pmg  <-----  sniffer-dumpy-09671733-1302 [Running]
        keda-operator-5c76fdd585-6tmzs  <-----  sniffer-dumpy-09671733-1817 [Running]
pvc:
pullsecret:

kubectl dumpy export -n kube-system dumpy-09671733 /tmp/tcpdump
Downloading capture dumps from sniffers:
  keda-operator-5c76fdd585-94pmg ---> path /tmp/tcpdump/dumpy-09671733-keda-operator-5c76fdd585-94pmg.pcap
  keda-operator-5c76fdd585-6tmzs ---> path /tmp/tcpdump/dumpy-09671733-keda-operator-5c76fdd585-6tmzs.pcap

kubectl dumpy stop -n kube-system dumpy-09671733
Stopping capture dumpy-09671733..
sniffer-dumpy-09671733-1302 stopped
sniffer-dumpy-09671733-1817 stopped
dumpy-09671733 sniffers have been successfully stopped

kubectl dumpy delete -n kube-system dumpy-09671733
deleting sniffer-dumpy-09671733-1302
deleting sniffer-dumpy-09671733-1817
dumpy capture dumpy-09671733 successfully deleted
```

- https://github.com/larryTheSlap/dumpy

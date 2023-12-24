```
root@aks-nodepool1-26220731-vmss000000:/# ig version
```

```
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace tcp -F dst.addr:93.184.216.34
RUNTIME.CONTAINERNAME    T PID        COMM          IP SRC                            DST
busybox                  C 326118     wget          4  10.244.0.21:44580              93.184.216.34:443
```

```
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace dns -F runtime.containerName:busybox
RUNTIME.CONTAINERNA… PID         TID         COMM       QR TYPE      QTYPE      NAME                RCODE      NUMA…
busybox              333551      333551      wget       Q  OUTGOING  A          www.example.com.de…            0
busybox              333551      333551      wget       R  HOST      A          www.example.com.de… NXDomain   0
busybox              333551      333551      wget       R  HOST      A          www.example.com.de… NXDomain   0
busybox              333551      333551      wget       Q  OUTGOING  AAAA       www.example.com.de…            0
busybox              333551      333551      wget       R  HOST      AAAA       www.example.com.de… NXDomain   0
busybox              333551      333551      wget       R  HOST      AAAA       www.example.com.de… NXDomain   0

busybox: wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace tcpconnect --latency
RUNTIME.CONTAINERNAME PID         COMM        IP SRC                          DST                            LATENCY
busybox               346738      wget        4  10.244.0.29:52455            93.184.216.34:443           100.62682…
```

- https://www.inspektor-gadget.io/docs/latest/core-concepts/architecture/
- https://www.inspektor-gadget.io/docs/latest/ig/: It uses eBPF as its underlying core technology
- https://github.com/inspektor-gadget/inspektor-gadget

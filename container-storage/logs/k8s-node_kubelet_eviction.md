```
root@aks-nodepool1-42220213-vmss000000:/# ps -aux | grep /bin/kubelet
root        2594  1.9  1.5 1795616 129144 ?      Ssl  19:01   0:12 /usr/local/bin/kubelet ... --eviction-hard=memory.available<750Mi,nodefs.available<10%,nodefs.inodesFree<5%,pid.available<2000
```

- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/: Node-pressure eviction is the process by which the kubelet proactively terminates pods to reclaim resources on nodes.
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#eviction-thresholds

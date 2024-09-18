## mariner
```
az aks nodepool add -g $rg --cluster-name aks -n mariner --os-sku AzureLinux -s $vmsize -c 2 # Earlier --os-sku CBLMariner / Mariner
kubectl get no

az aks nodepool delete -g $rg --cluster-name aks -n mariner
```

## mariner|Ubuntu

```
ls -l /var/log/syslog # File size is 0 KB, which is different from Ubuntu
-rw-r----- 1 root root 0 Aug 27 16:36 /var/log/syslog

cat /var/log/messages | grep iptable # iptable-restor entries aren't present in Ubuntu
2024-09-17T18:17:29.014419+00:00 aks-mariner-16141660-vmss000000 kernel: audit: type=1325 audit(1726575449.009:1078): table=nat family=2 entries=90 op=xt_replace pid=7226 subj=cri-containerd.apparmor.d (enforce) comm="iptables-restor"
2024-09-17T18:17:29.014446+00:00 aks-mariner-16141660-vmss000000 kernel: audit: type=1300 audit(1726575449.009:1078): arch=c000003e syscall=54 success=yes exit=0 a0=4 a1=0 a2=40 a3=5699e8c84f50 items=0 ppid=3641 pid=7226 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="iptables-restor" exe="/usr/sbin/xtables-legacy-multi" subj=cri-containerd.apparmor.d (enforce) key=(null)
```

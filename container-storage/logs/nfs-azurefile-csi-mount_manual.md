```
kubectl get pv | grep nfs
kubectl describe pv pvc-ce3663aa-2c80-41cf-b800-e8a4173915b4 | grep VolumeHan
    VolumeHandle:      mc_rg_aks_swedencentral#ff963893fcbef48bc939258#pvcn-ce3663aa-2c80-41cf-b800-e8a4173915b4###default

mkdir /tmp/test
# mount -v -t nfs -o vers=4,minorversion=1,sec=sys accountname.file.core.windows.net:/accountname/filesharename /tmp/test
mount -v -t nfs -o vers=4,minorversion=1,sec=sys ff963893fcbef48bc939258.file.core.windows.net:/ff963893fcbef48bc939258/pvcn-ce3663aa-2c80-41cf-b800-e8a4173915b4 /tmp/test
mount | grep nfs
ls /tmp/test
umount /tmp/test
```

```
# mount -v -t nfs -o...
mount.nfs: timeout set for Tue Sep  5 19:03:37 2023
mount.nfs: trying text-based options 'vers=4,sec=sys,vers=4.1,addr=20.60.79.8,clientaddr=10.224.0.5'

nslookup ff963893fcbef48bc939258.file.core.windows.net
Address: 20.60.79.8

root@aks-nodepool1-37919900-vmss000002:/# telnet 20.60.79.8 2049
Trying 20.60.79.8...
Connected to 20.60.79.8.
Escape character is '^]'.

root@aks-nodepool1-37919900-vmss000002:/# telnet 20.60.79.8 111
Trying 20.60.79.8...
^C

root@aks-nodepool1-37919900-vmss000000:/# tcpdump host 20.60.79.8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
20:48:21.174734 IP aks-nodepool1-37919900-vmss000000.internal.cloudapp.net.950 > 20.60.79.8.nfs: Flags [S], seq 4258721634, win 64240, options [mss 1460,sackOK,TS val 1091040520 ecr 0,nop,wscale 7], length 0
20:48:21.175207 IP 20.60.79.8.nfs > aks-nodepool1-37919900-vmss000000.internal.cloudapp.net.950: Flags [S.], seq 1731740365, ack 4258721635, win 65535, options [mss 1440,nop,wscale 8,sackOK,TS val 2847102204 ecr 1091040520], length 0
20:48:21.175232 IP aks-nodepool1-37919900-vmss000000.internal.cloudapp.net.950 > 20.60.79.8.nfs: Flags [.], ack 1, win 502, options [nop,nop,TS val 1091040520 ecr 2847102204], length 0
20:48:21.176182 IP aks-nodepool1-37919900-vmss000000.internal.cloudapp.net.950 > 20.60.79.8.nfs: Flags [P.], seq 1:45, ack 1, win 502, options [nop,nop,TS val 1091040521 ecr 2847102204], length 44: NFS request xid 2700744278 40 null
20:48:21.176832 IP 20.60.79.8.nfs > aks-nodepool1-37919900-vmss000000.internal.cloudapp.net.950: Flags [P.], seq 1:29, ack 45, win 16384, options [nop,nop,TS val 2847102206 ecr 1091040521], length 28: NFS reply xid 2700744278 reply ok 24 null
...

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md#smb: NFS
- https://www.systutorials.com/how-to-set-up-and-configure-nfs-server-and-clients/: NFS debugging tips

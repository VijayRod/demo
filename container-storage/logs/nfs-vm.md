```
rg=rg5
az group create -n $rg
az network vnet create -g $rg -n vnet --address-prefix 10.2.0.0/16 --subnet-name vmsubnet --subnet-prefixes 10.2.0.0/24
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n vmsubnet --query id -otsv)
az vm create -g $rg -n vm1 --image debian --subnet $subnetId --admin-username azureuser --public-ip-sku Standard
az vm create -g $rg -n vm2 --image debian --subnet $subnetId --admin-username azureuser --public-ip-sku Standard
az vm create -g $rg -n vm3 --image debian --subnet $subnetId --admin-username azureuser --public-ip-sku Standard
ip1=$(az vm show --show-details -g $rg -n vm1 --query publicIps --output tsv)
ip2=$(az vm show --show-details -g $rg -n vm2 --query publicIps --output tsv)
ip3=$(az vm show --show-details -g $rg -n vm3 --query publicIps --output tsv)
ip1priv=$(az vm show --show-details -g $rg -n vm1 --query privateIps --output tsv)
ip2priv=$(az vm show --show-details -g $rg -n vm2 --query privateIps --output tsv)
ip3priv=$(az vm show --show-details -g $rg -n vm3 --query privateIps --output tsv)
echo ip1=$ip1 ip2=$ip2 ip3=$ip3 ip1priv=$ip1priv ip2priv=$ip2priv ip3priv=$ip3priv
```

```
# NFS server
ssh azureuser@$ip1
sudo apt update -y && sudo apt install nfs-kernel-server -y
sudo mkdir /nfsshare
sudo touch /nfsshare/test.out; ls
sudo chown nobody:nogroup /nfsshare
sudo chmod 755 /nfsshare
ls /nfsshare
sudo nano /etc/exports

## Add the ip2priv and ip3priv client IPs 
/nfsshare 10.2.0.5(rw,sync,no_subtree_check)
/nfsshare 10.2.0.6(rw,sync,no_subtree_check)

sudo systemctl restart nfs-server
systemctl status nfs-server
```

```
# NFS client
ssh azureuser@$ip2
sudo apt-get install nfs-common -y
## Mount with the ip1priv server IP
sudo mount 10.2.0.4:/nfsshare /mnt
ls -l /mnt

-rw-r--r-- 1 root root 0 Aug 28 14:30 test.out
```

```
# NFS client diagnostics

df -h

Filesystem          Size  Used Avail Use% Mounted on
10.2.0.4:/nfsshare   30G  763M   27G   3% /mnt
```

```
# NFS client diagnostics for server
ssh azureuser@$ip2
ipnfs=10.2.0.4 ## the ip1priv server IP

sudo showmount -e $ipnfs

Export list for 10.2.0.4:
/nfsshare 10.2.0.6,10.2.0.5

rpcinfo -p $ipnfs
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    3   tcp   2049  nfs
    100003    3   udp   2049  nfs
...

sudo apt install telnet -y
telnet $ipnfs 2049
telnet $ipnfs 111
```

```
# tcpdump for ls -l /mnt on client

azureuser@vm1:~$ sudo tcpdump host 10.2.0.5
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
19:52:03.185708 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 3762012257:3762012469, ack 972394663, win 501, options [nop,nop,TS val 1356419917 ecr 1980487264], length 212: NFS request xid 185619776 208 getattr fh 0,2/53
19:52:03.185789 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 1:253, ack 212, win 501, options [nop,nop,TS val 1980511863 ecr 1356419917], length 252: NFS reply xid 185619776 reply ok 248 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.186789 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [.], ack 253, win 501, options [nop,nop,TS val 1356419918 ecr 1980511863], length 0
19:52:03.186881 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 212:424, ack 253, win 501, options [nop,nop,TS val 1356419919 ecr 1980511863], length 212: NFS request xid 202396992 208 getattr fh 0,2/53
19:52:03.186905 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 253:505, ack 424, win 501, options [nop,nop,TS val 1980511865 ecr 1356419919], length 252: NFS reply xid 202396992 reply ok 248 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.187654 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 424:644, ack 505, win 501, options [nop,nop,TS val 1356419919 ecr 1980511865], length 220: NFS request xid 219174208 216 getattr fh 0,2/53
19:52:03.187674 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 505:749, ack 644, win 501, options [nop,nop,TS val 1980511865 ecr 1356419919], length 244: NFS reply xid 219174208 reply ok 240 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.233753 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [.], ack 1533, win 501, options [nop,nop,TS val 1356419965 ecr 1980511867], length 0
19:52:08.415304 ARP, Request who-has vm2.internal.cloudapp.net tell vm1.internal.cloudapp.net, length 28
19:52:08.415965 ARP, Reply vm2.internal.cloudapp.net is-at 12:34:56:78:9a:bc (oui Unknown), length 46

azureuser@vm2:~$ sudo tcpdump host 10.2.0.4
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
19:51:38.585722 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [.], ack 972394663, win 501, options [nop,nop,TS val 1356395317 ecr 1980456544], length 0
19:51:38.586952 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [.], ack 1, win 501, options [nop,nop,TS val 1980487264 ecr 1356364599], length 0
19:52:03.185592 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 1:213, ack 1, win 501, options [nop,nop,TS val 1356419917 ecr 1980487264], length 212: NFS request xid 185619776 208 getattr fh 0,2/53
19:52:03.186786 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 1:253, ack 213, win 501, options [nop,nop,TS val 1980511863 ecr 1356419917], length 252: NFS reply xid 185619776 reply ok 248 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.186796 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [.], ack 253, win 501, options [nop,nop,TS val 1356419918 ecr 1980511863], length 0
19:52:03.187021 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 213:425, ack 253, win 501, options [nop,nop,TS val 1356419919 ecr 1980511863], length 212: NFS request xid 202396992 208 getattr fh 0,2/53
19:52:03.187751 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 253:505, ack 425, win 501, options [nop,nop,TS val 1980511865 ecr 1356419919], length 252: NFS reply xid 202396992 reply ok 248 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.187790 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [P.], seq 425:645, ack 505, win 501, options [nop,nop,TS val 1356419919 ecr 1980511865], length 220: NFS request xid 219174208 216 getattr fh 0,2/53
19:52:03.188542 IP vm1.internal.cloudapp.net.nfs > vm2.internal.cloudapp.net.687: Flags [P.], seq 505:749, ack 645, win 501, options [nop,nop,TS val 1980511865 ecr 1356419919], length 244: NFS reply xid 219174208 reply ok 240 getattr NON 3 ids 0/-1128338332 sz -645894854
19:52:03.233691 IP vm2.internal.cloudapp.net.687 > vm1.internal.cloudapp.net.nfs: Flags [.], ack 1533, win 501, options [nop,nop,TS val 1356419965 ecr 1980511867], length 0
19:52:08.281722 ARP, Request who-has vm1.internal.cloudapp.net tell vm2.internal.cloudapp.net, length 28
19:52:08.282480 ARP, Reply vm1.internal.cloudapp.net is-at 12:34:56:78:9a:bc (oui Unknown), length 46
```

- https://www.kali.org/tools/nfs-utils/

```
dpkg -l |grep irqbalance
ii  irqbalance                            1.8.0-1build1                           amd64        Daemon to balance interrupts for SMP systems

root@aks-nodepool1-24398294-vmss000000:/# systemctl status irqbalance.service
● irqbalance.service - irqbalance daemon
     Loaded: loaded (/lib/systemd/system/irqbalance.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-10-27 19:58:00 UTC; 7s ago
       Docs: man:irqbalance(1)
             https://github.com/Irqbalance/irqbalance
   Main PID: 11116 (irqbalance)
      Tasks: 2 (limit: 9516)
     Memory: 556.0K
        CPU: 32ms
     CGroup: /system.slice/irqbalance.service
             └─11116 /usr/sbin/irqbalance --foreground
Oct 27 19:58:00 aks-nodepool1-24398294-vmss000000 systemd[1]: Started irqbalance daemon.

systemctl restart irqbalance.service
```

- https://gist.github.com/juan-lee/cf53e166f7bb0a134b249ac0c434d495#file-patch-irqbalance-yaml
- https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202310.09.0.txt: irqbalance
- https://github.com/Irqbalance/irqbalance/
- https://zmalik.dev/posts/packet-drop

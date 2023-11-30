```
root@aks-npd4s-27693763-vmss00000A:/# sysctl -a | grep keep
net.ipv4.tcp_keepalive_time = 7200
```

- https://stackoverflow.com/questions/61354759/keepalive-for-kubectl-exec: default keep alive time is 7200s
- https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/overview.html
- https://stackoverflow.com/questions/45631351/what-is-the-typical-usage-of-tcp-keepalive

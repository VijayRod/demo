- https://support.google.com/faqs/answer/174717?hl=en: What is 1e100.net?

```
aks-nodepool1-38494683-vmss000000:/# cat /etc/resolv.conf
nameserver 168.63.129.16
search ib5kedtkaf2udoxrc5h1huub5a.gvxx.internal.cloudapp.net

aks-nodepool1-38494683-vmss000000:/# ip route
default via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
10.224.0.0/16 dev eth0 proto kernel scope link src 10.224.0.4 metric 100
10.224.0.1 dev eth0 proto dhcp scope link src 10.224.0.4 metric 100
10.244.0.0/24 dev cbr0 proto kernel scope link src 10.244.0.1
168.63.129.16 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
169.254.169.254 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
```

```
aks-nodepool1-38494683-vmss000000:/# curl -I google.com # HTTP/1.1 301 Moved Permanently

aks-nodepool1-38494683-vmss000000:/# tcpdump
17:16:01.297056 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.50181 > 168.63.129.16.domain: 34717+ A? google.com. (28)
17:16:01.297065 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.50181 > 168.63.129.16.domain: 31123+ AAAA? google.com. (28)
17:16:01.311162 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.50181: 34717 1/0/0 A 142.250.74.174 (44)
17:16:01.325057 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.50181: 31123 1/0/0 AAAA 2a00:1450:400f:802::200e (56)
17:16:01.386053 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.36697 > 168.63.129.16.domain: 43596+ PTR? 174.74.250.142.in-addr.arpa. (45)
17:16:01.428001 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.36697: 43596 1/0/0 PTR arn11s12-in-f14.1e100.net. (84)
```

```
root@aks-nodepool1-38494683-vmss000000:/# ping aks-nodepool1-38494683-vmss00003
ping: aks-nodepool1-38494683-vmss00003: Name or service not known
root@aks-nodepool1-38494683-vmss000000:/# ping aks-nodepool1-38494683-vmss000003.internal.cloudapp.net
PING aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6) 56(84) bytes of data.
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=1 ttl=64 time=2.13 ms
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=2 ttl=64 time=4.38 ms
^C
root@aks-nodepool1-38494683-vmss000000:/# ping aks-nodepool1-38494683-vmss000003
PING aks-nodepool1-38494683-vmss000003.ib5kedtkaf2udoxrc5h1huub5a.gvxx.internal.cloudapp.net (10.224.0.6) 56(84) bytes of data.
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=1 ttl=64 time=8.75 ms
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=2 ttl=64 time=1.16 ms
^C
```

```
aks-nodepool1-38494683-vmss000000:/# ping aks-nodepool1-38494683-vmss000003.internal.cloudapp.net
PING aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6) 56(84) bytes of data.
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=1 ttl=64 time=4.27 ms
64 bytes from aks-nodepool1-38494683-vmss000003.internal.cloudapp.net (10.224.0.6): icmp_seq=2 ttl=64 time=4.38 ms
^C
--- aks-nodepool1-38494683-vmss000003.internal.cloudapp.net ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 2.125/3.251/4.377/1.126 ms

root@aks-nodepool1-38494683-vmss000000:/# tcpdump
17:39:54.183239 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.54328 > 168.63.129.16.domain: 9349+ A? aks-nodepool1-38494683-vmss000003.internal.cloudapp.net. (73)
17:39:54.183245 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.54328 > 168.63.129.16.domain: 27526+ AAAA? aks-nodepool1-38494683-vmss000003.internal.cloudapp.net. (73)
17:39:54.189880 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.54328: 9349 1/0/0 A 10.224.0.6 (89)
17:39:54.190559 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.54328: 27526 0/1/0 (159)
17:39:54.190799 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net > aks-nodepool1-38494683-vmss000003.internal.cloudapp.net: ICMP echo request, id 2, seq 1, length 64
17:39:54.192884 IP aks-nodepool1-38494683-vmss000003.internal.cloudapp.net > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net: ICMP echo reply, id 2, seq 1, length 64
17:39:54.193078 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.56409 > 168.63.129.16.domain: 2216+ PTR? 6.0.224.10.in-addr.arpa. (41)
17:39:54.195086 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.56409: 2216 1/0/0 PTR aks-nodepool1-38494683-vmss000003.internal.cloudapp.net. (110)
17:39:55.192233 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net > aks-nodepool1-38494683-vmss000003.internal.cloudapp.net: ICMP echo request, id 2, seq 2, length 64
17:39:55.196593 IP aks-nodepool1-38494683-vmss000003.internal.cloudapp.net > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net: ICMP echo reply, id 2, seq 2, length 64
17:39:55.196689 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.45729 > 168.63.129.16.domain: 41267+ PTR? 6.0.224.10.in-addr.arpa. (41)
17:39:55.199568 IP 168.63.129.16.domain > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net.45729: 41267 1/0/0 PTR aks-nodepool1-38494683-vmss000003.internal.cloudapp.net. (110)

root@aks-nodepool1-38494683-vmss000003:/# tcpdump
17:39:54.190872 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net > aks-nodepool1-38494683-vmss000003.internal.cloudapp.net: ICMP echo request, id 2, seq 1, length 64
17:39:54.190933 IP aks-nodepool1-38494683-vmss000003.internal.cloudapp.net > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net: ICMP echo reply, id 2, seq 1, length 64
17:39:55.195614 IP aks-nodepool1-38494683-vmss000000.internal.cloudapp.net > aks-nodepool1-38494683-vmss000003.internal.cloudapp.net: ICMP echo request, id 2, seq 2, length 64
17:39:55.195654 IP aks-nodepool1-38494683-vmss000003.internal.cloudapp.net > aks-nodepool1-38494683-vmss000000.internal.cloudapp.net: ICMP echo reply, id 2, seq 2, length 64
```

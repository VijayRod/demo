

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

- https://support.google.com/faqs/answer/174717?hl=en: What is 1e100.net?
- https://www.cloudflare.com/learning/dns/dns-records/dns-aaaa-record/: The DNS AAAA record matches a domain name with an IPv6 address — similar to A records, which do the same for IPv4 addresses.

## dns.vm.dnscache.systemd.systemd-resolved

```
root@aks-nodepool1-75204569-vmss000000:/# systemctl is-active systemd-resolved
active

root@aks-nodepool1-75204569-vmss000000:/# resolvectl statistics
DNSSEC supported by current servers: no
Transactions
Current Transactions: 0
  Total Transactions: 112
Cache
  Current Cache Size: 3
          Cache Hits: 33
        Cache Misses: 83
DNSSEC Verdicts
              Secure: 0
            Insecure: 0
               Bogus: 0
       Indeterminate: 0
root@aks-nodepool1-75204569-vmss000000:/# resolvectl flush-caches # Current Cache Size is now 0
root@aks-nodepool1-75204569-vmss000000:/# resolvectl statistics
DNSSEC supported by current servers: no
Transactions
Current Transactions: 0
  Total Transactions: 112
Cache
  Current Cache Size: 0
          Cache Hits: 33
        Cache Misses: 83
DNSSEC Verdicts
              Secure: 0
            Insecure: 0
               Bogus: 0
       Indeterminate: 0

root@aks-nodepool1-75204569-vmss000000:/# resolvectl flush-caches; curl -I google.com
HTTP/1.1 301 Moved Permanently
```

```
tbd
curl -I google.com
killall -USR1 systemd-resolved && journalctl -u systemd-resolved && grep -A 100 "CACHE:"

systemctl is-active systemd-resolved # active
resolvectl statistics # Current Cache Size: 15
killall -USR1 systemd-resolved && journalctl -u systemd-resolved > /tmp/dns.txt && cat /tmp/dns.txt
# killall -USR1 systemd-resolved && journalctl -u systemd-resolved && grep -A 100 "CACHE:"
# resolvectl flush-caches
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]: CACHE:
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         umsaccbq0tfrcfl3kfbm.blob.core.windows.net IN CNAME blob.gvx01prdstrz04a.store.core.windows.net
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         umsab4sv24kfrmf40vxd.blob.core.windows.net IN CNAME blob.gvx01prdstrz04a.store.core.windows.net
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         mcr-0001.mcr-msedge.net IN A 150.171.69.10

killall -USR1 systemd-resolved
journalctl -u systemd-resolved > /tmp/dns.txt && cat /tmp/dns.txt | head -n 10
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd[1]: Starting Network Name Resolution...
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd-resolved[539]: Positive Trust Anchors:
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd-resolved[539]: . IN DS 20326 8 2 e06d44b80b8f1d39a95c0b0d7c65d08458e880409bbc683457104237c7f8ec8d
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd-resolved[539]: Negative trust anchors: home.arpa 10.in-addr.arpa 16.172.in-addr.arpa 17.172.in-addr.arpa 18.172.in-addr.arpa 19.172.in-addr.arpa 20.172.in-addr.arpa 21.172.in-addr.arpa 22.172.in-addr.arpa 23.172.in-addr.arpa 24.172.in-addr.arpa 25.172.in-addr.arpa 26.172.in-addr.arpa 27.172.in-addr.arpa 28.172.in-addr.arpa 29.172.in-addr.arpa 30.172.in-addr.arpa 31.172.in-addr.arpa 168.192.in-addr.arpa d.f.ip6.arpa corp home internal intranet lan local private test
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd-resolved[539]: Using system hostname 'aks-nodepool1-75204569-vmss000000'.
Dec 05 09:14:00 aks-nodepool1-75204569-vmss000000 systemd[1]: Started Network Name Resolution.
...
```

- https://www.baeldung.com/linux/dns-cache-local-flushing
- https://askubuntu.com/questions/1409726/systemd-resolve-command-not-found-in-ubuntu-22-04-desktop: Use resolvectl status instead. In systemd 239 systemd-resolve has been renamed to resolvectl
- https://www.howtogeek.com/844964/how-to-flush-dns-in-linux/: Reviewing Your DNS Cache

## dns.vm.resolv_conf

```
cp /etc/resolv.conf /tmp/resolv.conf
ls /tmp/resolv.*
cat /etc/resolv.conf

rm /etc/resolv.conf
cp /tmp/resolv.conf /etc/resolv.conf
cat /etc/resolv.conf
```

```
# symlink (shortcut) on my laptop
ls -l /etc/resolv.conf
lrwxrwxrwx 1 root root 20 Dec  5 18:17 /etc/resolv.conf -> /mnt/wsl/resolv.conf

# isn't a symlink on an AKS node
root@aks-nodepool1-75204569-vmss000000:/# ls -l /etc/resolv.conf # not a 
-rw-r----- 1 root root 855 Dec  5 18:18 /etc/resolv.conf

root@aks-nodepool1-75204569-vmss000000:/# cat /etc/resolv.conf
# This is /run/systemd/resolve/resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 168.63.129.16
search qibf5jn4e15enib2o0kmnxxmhd.gvxx.internal.cloudapp.net
```

## dns.vm.resolv_conf.use-vc (DNS over TCP)

```
# regular DNS over UDP
root@aks-nodepool1-75204569-vmss000000:/# resolvectl flush-caches; curl -I google.com 
wireshark: dns.qry.name == "google.com"; udp.stream eq 84
5541	2024-12-05 21:16:11.763456	10.224.0.4	168.63.129.16	DNS	UDP	76	0x3a74 (14964)	Standard query 0x03a4 A google.com
5542	2024-12-05 21:16:11.763466	10.224.0.4	168.63.129.16	DNS	UDP	76	0x3a75 (14965)	Standard query 0x95a2 AAAA google.com
5543	2024-12-05 21:16:11.765478	168.63.129.16	10.224.0.4	DNS	UDP	92	0x346b (13419)	Standard query response 0x03a4 A google.com A 142.250.74.46
5544	2024-12-05 21:16:11.779927	168.63.129.16	10.224.0.4	DNS	UDP	104	0x346c (13420)	Standard query response 0x95a2 AAAA google.com AAAA 2a00:1450:400f:801::200e
# both column names are "Protocol" - one for the transport layer "Protocol" (TCP) and one for the application layer "Protocol" (DNS)
Frame 5541: 76 bytes on wire (608 bits), 76 bytes captured (608 bits)
Internet Protocol Version 4, Src: 10.224.0.4, Dst: 168.63.129.16
  Protocol: UDP (17)
User Datagram Protocol, Src Port: 42322, Dst Port: 53
Domain Name System (query)

# DNS over TCP with use-vc
root@aks-nodepool1-75204569-vmss000000:/# resolvectl flush-caches; curl -I google.com # echo "options use-vc" >> /etc/resolv.conf; cat /etc/resolv.conf
wireshark: dns.qry.name == "google.com"; tcp.stream eq 109
2345	2024-12-05 21:03:56.031776	10.224.0.4	168.63.129.16	TCP	TCP	80	0xd00c (53260)	36966 ? 53 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4195208162 TSecr=0 WS=128
2346	2024-12-05 21:03:56.032679	168.63.129.16	10.224.0.4	TCP	TCP	80	0x227c (8828)	53 ? 36966 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=256 SACK_PERM TSval=1152802924 TSecr=4195208162
2347	2024-12-05 21:03:56.032742	10.224.0.4	168.63.129.16	TCP	TCP	72	0xd00d (53261)	36966 ? 53 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4195208163 TSecr=1152802924
2348	2024-12-05 21:03:56.032790	10.224.0.4	168.63.129.16	DNS	TCP	132	0xd00e (53262)	Standard query 0xec0f A google.com, Standard query 0xd20d AAAA google.com
2349	2024-12-05 21:03:56.044678	168.63.129.16	10.224.0.4	TCP	TCP	72	0x227d (8829)	53 ? 36966 [ACK] Seq=1 Ack=61 Win=4195328 Len=0 TSval=1152802936 TSecr=4195208163
2370	2024-12-05 21:03:56.344823	168.63.129.16	10.224.0.4	DNS	TCP	118	0x2284 (8836)	Standard query response 0xec0f A google.com A 142.250.74.142
2371	2024-12-05 21:03:56.344874	10.224.0.4	168.63.129.16	TCP	TCP	72	0xd00f (53263)	36966 ? 53 [ACK] Seq=61 Ack=47 Win=64256 Len=0 TSval=4195208475 TSecr=1152803236
2372	2024-12-05 21:03:56.345096	168.63.129.16	10.224.0.4	DNS	TCP	130	0x2285 (8837)	Standard query response 0xd20d AAAA google.com AAAA 2a00:1450:400f:804::200e
2373	2024-12-05 21:03:56.345104	10.224.0.4	168.63.129.16	TCP	TCP	72	0xd010 (53264)	36966 ? 53 [ACK] Seq=61 Ack=105 Win=64256 Len=0 TSval=4195208476 TSecr=1152803236
2374	2024-12-05 21:03:56.345136	10.224.0.4	168.63.129.16	TCP	TCP	72	0xd011 (53265)	36966 ? 53 [FIN, ACK] Seq=61 Ack=105 Win=64256 Len=0 TSval=4195208476 TSecr=1152803236
2376	2024-12-05 21:03:56.345779	168.63.129.16	10.224.0.4	TCP	TCP	72	0x2286 (8838)	53 ? 36966 [ACK] Seq=105 Ack=62 Win=4195328 Len=0 TSval=1152803237 TSecr=4195208476
2391	2024-12-05 21:03:56.448769	168.63.129.16	10.224.0.4	TCP	TCP	72	0x2287 (8839)	53 ? 36966 [FIN, ACK] Seq=105 Ack=62 Win=4195328 Len=0 TSval=1152803340 TSecr=4195208476
2392	2024-12-05 21:03:56.448799	10.224.0.4	168.63.129.16	TCP	TCP	72	0x0000 (0)	36966 ? 53 [ACK] Seq=62 Ack=106 Win=64256 Len=0 TSval=4195208579 TSecr=1152803340
# both column names are "Protocol" - one for the transport layer "Protocol" (TCP) and one for the application layer "Protocol" (DNS)
Frame 2348: 132 bytes on wire (1056 bits), 132 bytes captured (1056 bits)
Internet Protocol Version 4, Src: 10.224.0.4, Dst: 168.63.129.16
  Protocol: TCP (6)
Transmission Control Protocol, Src Port: 36966, Dst Port: 53, Seq: 1, Ack: 1, Len: 60  
Domain Name System (query)
```

- https://man7.org/linux/man-pages/man5/resolv.conf.5.html: use-vc. Sets RES_USEVC in _res.options. This option forces the use of TCP for DNS resolutions.

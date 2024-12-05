## dns

- https://wizardzines.com/zines/dns/
- https://www.cloudflare.com/learning/dns/what-is-dns/
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances

## dns.debug

```
# See the note below on https://www.digwebinterface.com/

# dig google.com

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31728
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             50      IN      A       172.217.21.174

;; Query time: 2 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Wed Aug 22 22:12:34 UTC 2023
;; MSG SIZE  rcvd: 55

# dig google.com ns +trace +nodnssec

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com ns +trace +nodnssec
;; global options: +cmd
;; Received 28 bytes from 127.0.0.53#53(127.0.0.53) in 0 ms
```

```
# nslookup google.com

Server:         172.30.48.1
Address:        172.30.48.1#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.200.142
Name:   google.com
Address: 2a00:1450:4003:80f::200e

# nslookup google.com 8.8.8.8

Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.184.14
Name:   google.com
Address: 2a00:1450:4003:80e::200e

# azureuser@myvm:~$ nslookup google.com 168.63.129.16

Server:         168.63.129.16
Address:        168.63.129.16#53

Non-authoritative answer:
Name:   google.com
Address: 172.217.21.174
Name:   google.com
Address: 2a00:1450:400f:80c::200e
```

- https://www.digwebinterface.com/: type the fqdn, and press Dig. It will display the IP if the full fqdn can be resolved publicly, even if its linked to a private IP, like those used in AKS private clusters. If not, , it will show the part of the fqdn that can be resolved by the dns server.

## dns.server.relay

- https://support.huawei.com/enterprise/en/knowledge/EKB1000075807: FAQ-In What Scenarios Should I Use the DNS Relay Function. The DNS proxy or relay function enables a DNS client on a LAN to connect to an external DNS server. After the external DNS server translates the domain name of the DNS client to an IP address, the DNS client can access the Internet.
  After receiving DNS query packets from the DNS client, the device with DNS proxy enabled searches the local cache. The device with DNS relay enabled directly forwards the DNS query packets to the external DNS server, and does not search the local cache.
  If the DNS client needs to obtain resource records on the DNS server in real time, enable the DNS relay function on the device.
- https://help.dnsfilter.com/hc/en-us/sections/1500001413361-DNS-Relay
    
## dns.server.relay.windows

- https://my.f5.com/manage/s/article/K9694: Archived - K9694: Overview of the Windows DNS Relay Proxy service. the DNS Relay Proxy service directs client DNS requests to the DNS servers that are configured for the Network Access connection when the domain name matches a domain name in the DNS address space field. All other client DNS requests are directed to the DNS servers configured on the client system.

## dns.spec.record

- https://learn.microsoft.com/en-us/azure/dns/dns-zones-records#dns-records

## network.tcp

- https://www.codecademy.com/resources/blog/what-is-tcp/
- https://warwick.ac.uk/fac/sci/dcs/teaching/modules/cs241/#description: Outline syllabus
- https://www.ietf.org/rfc/rfc9293.html: Transmission Control Protocol (TCP)
- https://www.rfc-editor.org/rfc/rfc793: TRANSMISSION CONTROL PROTOCOL
- https://bhowl.github.io/portfolio/tcp.html
- https://cis.temple.edu/~tug29203/22spring-4319/lectures/ch3a-1.pdf: Chapter 3 Transport Layer

## network.tcp.5-tuple

- https://networkengineering.stackexchange.com/questions/54344/why-is-a-tcp-socket-identified-by-a-4-tuple
- https://blog.packet-foo.com/2015/03/tcp-analysis-and-the-five-tuple/
- https://amazingalgorithms.com/definitions/5-tuple/
- https://stackoverflow.com/questions/29296472/why-does-tcp-need-a-destination-ip-address-to-perform-demultiplexing
- https://upskilld.com/learn/network-sockets-and-ports/
- https://www.firewall.cx/networking/network-protocols/tcp-udp-protocol/tcp-source-destination-ports.html

## network.tcp.keepalive

```
root@aks-npd4s-27693763-vmss00000A:/# sysctl -a | grep keep
net.ipv4.tcp_keepalive_time = 7200
```

- https://stackoverflow.com/questions/61354759/keepalive-for-kubectl-exec: default keep alive time is 7200s
- https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/overview.html
- https://stackoverflow.com/questions/45631351/what-is-the-typical-usage-of-tcp-keepalive

## network.tcp.handshake

- https://notes.networklessons.com/tcp-three-way-handshake
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/three-way-handshake-via-tcpip

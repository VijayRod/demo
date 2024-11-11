# nmap

```
apt update -y && apt install nmap -y

# nmap
# https://nmap.org/book/man-briefoptions.html
nmap -V # Nmap version 7.80 ( https://nmap.org )

# nmap.target
nmap -A # No targets were specified, so 0 hosts scanned.
nmap -A scanme.nmap.org # 22/tcp    open     ssh        OpenSSH 6.6.1p1 Ubuntu 2ubuntu2.13. 35.88 seconds
nmap -A -T4 scanme.nmap.org # scanned in 200.66 seconds

# nmap.host

# nmap.service/version detection
nmap -sV 10.224.0.4 # 22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu. 0.41 seconds
```
- https://nmap.org/: Discover your network
- https://nmap.org/book/man.html
- https://nmap.org/book/man-briefoptions.html: target, host, etc.
- https://npcap.com/: Npcap is the Nmap Project's packet capture (and sending) library for Microsoft Windows. It implements the open Pcap API using a custom Windows kernel driver alongside our Windows build of the excellent libpcap library.

# nmap.example

- https://www.wiz.io/blog/unveiling-ebpf-harnessing-its-power-to-solve-real-world-issues

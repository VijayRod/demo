```
tcpdump -w - # to write binary data to stdout
tcpdump – version
man tcpdump

curl ifconfig.me # ip a
```

- https://www.tcpdump.org/manpages/tcpdump.1.html
- https://www.tcpdump.org/
- https://danielmiessler.com/p/tcpdump
- https://wiki.archlinux.org/title/Network_Debugging: Tcpdump
- https://wizardzines.com/zines/tcpdump/
- https://superuser.com/questions/925286/does-tcpdump-bypass-iptables: tcpdump is the first software found after the wire (and the NIC, if you will) on the way IN, and the last one on the way OUT....
- https://man.archlinux.org/man/tcpdump.1
<br>

- Frequently Asked Questions
  - tbd https://linuxconfig.org/how-to-use-tcpdump-command-on-linux
  - https://superuser.com/questions/1455476/what-does-tcp-packet-p-flag-means-in-tcpdumps-output
  - https://stackoverflow.com/questions/25603831/how-can-i-have-tcpdump-write-to-file-and-standard-output-the-appropriate-data
  - https://superuser.com/questions/273489/how-do-i-make-tcpdump-to-write-to-file-for-each-packet-it-captures
  - https://stackoverflow.com/questions/19808483/tcpdump-resolve-ip-and-skip-resolving-ports
<br>

- capture filters

```
tcpdump host 1.1.1.1 # Source or destination
tcpdump port 443

# Use tcpdump to exclude traffic from specific IP addresses
tcpdump 'not net 168.63.129.16' # Alternatively, you can use tcpdump 'not net 168.63.129.16/32' or tcpdump '! net 168.63.129.16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254'
tcpdump 'host 10.224.0.69 and not net 168.63.129.16 and not net 10.255.0.0/16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254 and not port 10250 and not net 13.87.229.75' # aks fqdn
```

- https://wiki.wireshark.org/CaptureFilters
- https://www.tcpdump.org/manpages/pcap-filter.7.html
- https://blog.wains.be/2007/2007-10-01-tcpdump-advanced-filters/
<br>

- http

```
tcpdump tcp port http # tcpdump port 80 # tcpdump port http
tcpdump tcp port https
```

- https://security.stackexchange.com/questions/121011/wireshark-tcp-filter-tcptcp121-0xf0-24
<br>

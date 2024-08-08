```
tcpdump
tcpdump -w - # to write binary data to stdout
tcpdump --list-interfaces # ip a # tcpdump -i eth0
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
tcpdump tcp dst port 80 # tcpdump 'tcp dst port 80'
tcpdump tcp dst port 80 -A # Displays the HTTP request/response in ASCII format.
```

```
curl google.com
tcpdump 'tcp dst port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420' # Here 0x47455420 depicts the ASCII value of  characters  'G' 'E' 'T' ' '
# tcpdump -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'
# tcpdump -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 and not net 168.63.129.16 and not net 169.254.169.254 and not port 10250'
23:02:09.004064 IP 1.2.3.4.49878 > mad07s25-in-f14.1e100.net.http: Flags [P.], seq 3472752388:3472752462, ack 1346174452, win 502, options [nop,nop,TS val 89192113 ecr 1101230501], length 74: HTTP: GET / HTTP/1.1

curl google.com
tcpdump 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450' # 0x48545450 represents the ASCII value of 'H' 'T' 'T' 'P' this is to capture the HTTP response
23:00:21.662418 IP mad41s11-in-f14.1e100.net.http > 1.2.3.4.42180: Flags [P.], seq 1942071783:1942072556, ack 3228441095, win 256, options [nop,nop,TS val 1187180250 ecr 1887773435], length 773: HTTP: HTTP/1.1 301 Moved Permanently

curl google.com
tcpdump 'tcp dst port 80 or tcp dst port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450'
23:09:02.975303 IP 1.2.3.4.36630 > mad41s13-in-f14.1e100.net.http: Flags [P.], seq 2710103797:2710103871, ack 980434831, win 502, options [nop,nop,TS val 574057378 ecr 3641890559], length 74: HTTP: GET / HTTP/1.1
23:09:03.018202 IP mad41s13-in-f14.1e100.net.http > 1.2.3.4.36630: Flags [P.], seq 1:774, ack 74, win 256, options [nop,nop,TS val 3641890603 ecr 574057378], length 773: HTTP: HTTP/1.1 301 Moved Permanently

curl google.com -I
tcpdump 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48454144' # HEAD
23:44:18.889621 IP 1.2.3.4.45238 > mad07s23-in-f14.1e100.net.http: Flags [P.], seq 3735714866:3735714941, ack 774239603, win 502, options [nop,nop,TS val 214544517 ecr 1619348354], length 75: HTTP: HEAD / HTTP/1.1
```

- https://security.stackexchange.com/questions/121011/wireshark-tcp-filter-tcptcp121-0xf0-24
- https://onlinetools.com/hex/convert-hex-to-ascii?input=0x47455420 # GET 
- https://onlinetools.com/hex/convert-ascii-to-hex?input=GET  # 47455420. Remember to deselect 'Add 0x Hex Prefix' and 'Add Extra Spacing'. Also, don't forget to manually add a space after typing GET to match the 4 bytes requirement.
- tbd https://www.rapidtables.com/code/text/ascii-table.html
- tbd https://www.middlewareinventory.com/blog/tcpdump-capture-http-get-post-requests-apache-weblogic-websphere/
<br>

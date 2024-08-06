```
tcpdump host 1.1.1.1 # Source or destination
tcpdump port 443
tcpdump -w - # to write binary data to stdout
man tcpdump

# Use tcpdump to exclude traffic from specific IP addresses
tcpdump -f "not net 168.63.129.16/32" # Alternatively, you can use tcpdump -f "! net 168.63.129.16/32"
tcpdump -f "host 10.224.0.69 and not net 168.63.129.16/32 and not net 169.254.169.254/32"
```

- https://danielmiessler.com/p/tcpdump
- https://wiki.archlinux.org/title/Network_Debugging: Tcpdump
- https://wizardzines.com/zines/tcpdump/
- https://superuser.com/questions/925286/does-tcpdump-bypass-iptables: tcpdump is the first software found after the wire (and the NIC, if you will) on the way IN, and the last one on the way OUT....
- https://man.archlinux.org/man/tcpdump.1
<br>

Frequently Asked Questions
- tbd https://linuxconfig.org/how-to-use-tcpdump-command-on-linux
- https://superuser.com/questions/1455476/what-does-tcp-packet-p-flag-means-in-tcpdumps-output
- https://stackoverflow.com/questions/25603831/how-can-i-have-tcpdump-write-to-file-and-standard-output-the-appropriate-data
- https://superuser.com/questions/273489/how-do-i-make-tcpdump-to-write-to-file-for-each-packet-it-captures
- https://stackoverflow.com/questions/19808483/tcpdump-resolve-ip-and-skip-resolving-ports

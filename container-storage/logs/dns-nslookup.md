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

```
nslookup aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io
Address: 51.12.129.redacted

telnet aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io 443
Trying 51.12.129.redacted...
Connected to aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443.
Escape character is '^]'.

curl aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443 -I
HTTP/1.0 400 Bad Request
```

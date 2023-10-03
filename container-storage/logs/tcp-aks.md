```
nslookup aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io
Address: 51.12.129.redacted

nc aks-rg-111111-hptzgw9m.hcp.swedencentral.azmk8s.io 443 -z -v
Connection to aks-rg-111111-hptzgw9m.hcp.swedencentral.azmk8s.io 443 port [tcp/https] succeeded!

telnet aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io 443
Trying 51.12.129.redacted...
Connected to aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443.
Escape character is '^]'.

curl aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443 -I
HTTP/1.0 400 Bad Request
```

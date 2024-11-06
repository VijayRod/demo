## ip

```
CURRENT_IP=$(dig +short "myip.opendns.com" "@resolver1.opendns.com")

ip addr show # apt update -y && apt install iproute2 -y # ip link # ifconfig -a
```

## ip.debug

```
# See the section on dns.
```

## ip.spec.type.bogon

- https://ipinfo.io/bogon
- https://manrs.org/2021/01/routing-security-terms-bogons-vogons-and-martians/: Bogons = Martians + Unallocated (IANA + RIRs) address space

## ip.spec.type.private

- https://www.rfc-editor.org/rfc/rfc1918#section-3: Private Address Space. 10/8 prefix, 172.16/12 prefix, 192.168/16 prefix

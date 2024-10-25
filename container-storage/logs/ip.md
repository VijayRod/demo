## ip

```
CURRENT_IP=$(dig +short "myip.opendns.com" "@resolver1.opendns.com")
```

## ip.spec.type.bogon

- https://ipinfo.io/bogon
- https://manrs.org/2021/01/routing-security-terms-bogons-vogons-and-martians/: Bogons = Martians + Unallocated (IANA + RIRs) address space

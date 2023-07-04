The following commands are for a Linux node.

```
# To drop packets sent to a destination port.
iptables -A OUTPUT -p tcp --dport 445 -j DROP

# To confirm the added destination port rule.
# Output of the command: -A OUTPUT -p tcp -m tcp --dport 445 -j DROP
iptables-save | grep dport | grep 445
```

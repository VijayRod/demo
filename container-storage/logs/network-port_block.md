The following commands are for a Linux node:

```
# To drop packets sent to a destination port.
iptables -A OUTPUT -p tcp --dport 445 -j DROP

# To confirm the added destination port rule.
# Output of the command: -A OUTPUT -p tcp -m tcp --dport 445 -j DROP
iptables-save | grep dport | grep 445

# To delete the rule.
iptables -D OUTPUT -p tcp --dport 445 -j DROP
```

The following commands are for a Windows node in a PowerShell prompt:

```
# To create a new firewall rule.
New-NetFirewallRule -DisplayName "Block SMB port" -Direction Outbound -LocalPort 445 -Protocol TCP -Action Block

# To display the firewall rule.
Get-NetFirewallRule -DisplayName "Block SMB port"

# To remove the firewall rule.
Remove-NetFirewallRule -DisplayName "Block SMB port"

# TBD for outbound port.
Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 445
```

TBD Or block with Network Security Group (NSG) or Firewall.

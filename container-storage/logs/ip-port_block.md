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

```
# TBD for randomly dropping 10% of incoming packets
iptables -s 123.456.78.90/32 -A INPUT -m statistic --mode random --probability 0.1 -j DROP
OR iptables -s 123.456.78.90/32 -p tcp -m tcp -A INPUT -m statistic --mode random --probability 0.1 -j DROP
```

- https://www.linode.com/docs/guides/control-network-traffic-with-iptables/#block-traffic-by-port

```
# tbd with firewalld
apt install firewalld
firewall-cmd --add-port=10250/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all  # you should see that port `10250` is updated
https://stackoverflow.com/questions/58268197/kubernetes-dial-tcp-myip10250-connect-no-route-to-host
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

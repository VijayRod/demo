## tcp-firewall.ufw

```
sudo ufw allow 80/tcp
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/tunnel-connectivity-issues#cause-2-the-uncomplicated-firewall-ufw-tool-is-blocking-port-10250
- https://manpages.ubuntu.com/manpages/lunar/en/man8/ufw.8.html
- https://wiki.ubuntu.com/UncomplicatedFirewall

## tcp-firewall.azure.sslinspection

```
# Whitelist FQDNs in the firewall to bypass SSL inspection.
```

- https://learn.microsoft.com/en-us/azure/firewall/premium-features#tls-inspection

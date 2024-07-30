```
systemctl is-active systemd-resolved # active
resolvectl statistics # Current Cache Size: 15
killall -USR1 systemd-resolved && journalctl -u systemd-resolved > /tmp/dns.txt && cat /tmp/dns.txt
# killall -USR1 systemd-resolved && journalctl -u systemd-resolved && grep -A 100 "CACHE:"
# resolvectl flush-caches

Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]: CACHE:
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         umsaccbq0tfrcfl3kfbm.blob.core.windows.net IN CNAME blob.gvx01prdstrz04a.store.core.windows.net
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         umsab4sv24kfrmf40vxd.blob.core.windows.net IN CNAME blob.gvx01prdstrz04a.store.core.windows.net
Jul 30 18:36:44 aks-nodepool1-14036957-vmss000000 systemd-resolved[537]:         mcr-0001.mcr-msedge.net IN A 150.171.69.10
```

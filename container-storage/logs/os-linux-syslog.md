```
cd /tmp
filel=$(hostname)-varlog-$(date -u +%Y%m%d%H%M%S)Z
echo "Target file: /tmp/$filel.tar.gz"
tar -czvf $filel.tar.gz /var/log 
ls -l /tmp/*varlog*
# /tmp/aks-nodepool1-17884086-vmss000000-varlog-20231006191746Z.tar.gz
```

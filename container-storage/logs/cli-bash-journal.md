## journal.journalctl

```
journalctl -D . --utc > /tmp/journal.log
journalctl -D . --utc --since=2020-11-24 --until=2020-11-28 > /tmp/journal.log
journalctl -u kubelet -o cat > /tmp/kubeletlogs
journalctl -u kubelet > /tmp/kubelet.log && journal -u containerd > /tmp/containerd.log
cat /tmp/journal.log | select-string -Pattern kubectl | Out-File -File /tmp/kubectl_0.log
```

## journal.journalctl.debug

```
SYSTEMD_LOG_LEVEL=debug journalctl --file=./system.journal
```

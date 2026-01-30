# Ubuntu 24.04 - Containerd soft/hard file descriptor limits

Kubernetes DaemonSet to configure `LimitNOFILE` and `LimitNOFILESoft` for containerd on Ubuntu 24.04 AKS nodes.

```
kubectl delete ds set-nofile-soft-ubuntu2404
kubectl apply -f /tmp/set-nofile-soft-ubuntu2404.yaml
kubectl get ds
kubectl get po -owide

kubectl logs -f set-nofile-soft-ubuntu2404-xxxxx # This includes LimitNOFILESoft=1048576

+ HARD_DESIRED=1048576
+ SOFT_DESIRED=1048576
+ DROPIN_DIR=/host/etc/systemd/system/containerd.service.d
+ DROPIN_FILE=/host/etc/systemd/system/containerd.service.d/99-nofile.conf
++ h 'systemctl show containerd -p LimitNOFILESoft --value'
++ nsenter -t 1 -m -u -i -n -- /bin/bash -lc 'systemctl show containerd -p LimitNOFILESoft --value'
+ SOFT_BEFORE=1048576
++ h 'systemctl show containerd -p LimitNOFILE --value'
++ nsenter -t 1 -m -u -i -n -- /bin/bash -lc 'systemctl show containerd -p LimitNOFILE --value'
+ HARD_CURRENT=1048576
+ echo '[INFO] before: soft=1048576 hard=1048576'
[INFO] before: soft=1048576 hard=1048576
[NOCHANGE] already at desired values
+ '[' 1048576 -ne 1048576 ']'
+ '[' 1048576 -ne 1048576 ']'
+ echo '[NOCHANGE] already at desired values'
[AFTER] systemd values:
+ echo '[AFTER] systemd values:'
+ h 'systemctl show containerd -p LimitNOFILE -p LimitNOFILESoft'
+ nsenter -t 1 -m -u -i -n -- /bin/bash -lc 'systemctl show containerd -p LimitNOFILE -p LimitNOFILESoft'
LimitNOFILE=1048576
LimitNOFILESoft=1048576
+ echo '[DONE] Configuration complete. Pod will sleep indefinitely.'
+ sleep infinity
[DONE] Configuration complete. Pod will sleep indefinitely.
```

```
# Verification: Soft limit increased from default 1024 → 1048576
# Ensures pods inherit correct ulimit from containerd daemon
# (matches Ubuntu 22.04+ behavior)

kubectl run -it --rm --restart=Never busybox2 --image=busybox
If you don't see a command prompt, try pressing enter.
/ # ulimit -a
core file size (blocks)         (-c) unlimited
data seg size (kb)              (-d) unlimited
scheduling priority             (-e) 0
file size (blocks)              (-f) unlimited
pending signals                 (-i) 128341
max locked memory (kb)          (-l) 8192
max memory size (kb)            (-m) unlimited
open files                      (-n) 1048576
POSIX message queues (bytes)    (-q) 819200
real-time priority              (-r) 0
stack size (kb)                 (-s) 8192
cpu time (seconds)              (-t) unlimited
max user processes              (-u) unlimited
virtual memory (kb)             (-v) unlimited
file locks                      (-x) unlimited
```

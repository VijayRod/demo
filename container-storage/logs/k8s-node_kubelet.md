```
journalctl -u kubelet -o cat > /tmp/kubeletlogs
journalctl -u kubelet > /tmp/kubelet.log && journal -u containerd > /tmp/containerd.log
journalctl -xeu kubelet
```

- https://kubernetes.io/docs/concepts/overview/components/#kubelet
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/

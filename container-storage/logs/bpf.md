## bpf

- https://lwn.net/Kernel/Index/#BPF

## bpf.bpftool

```
# debian: apt update -y && apt install -y linux-tools-common linux-tools-$(uname -r)
bpftool prog
```
- https://betterstack.com/community/guides/observability/ebpf-observability/
  
```
kubectl run bpftool --rm -i -t \
  --privileged \
  --overrides='{"spec":{"hostPID":true}}' \
  --image=ubuntu:22.04 \
  -- bash
  
apt update -y && apt install -y linux-tools-common linux-tools-$(uname -r) && bpftool prog
```

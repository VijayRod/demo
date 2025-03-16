## node

```
root@aks-nodepool1-24567707-vmss00000C:/# date -u
Fri Feb 21 19:49:34 UTC 2025
```

## node..cpu

```
root@aks-nodepool1-24567707-vmss00000C:/# lscpu
Architecture:             x86_64
  CPU op-mode(s):         32-bit, 64-bit
  Address sizes:          46 bits physical, 48 bits virtual
  Byte Order:             Little Endian
CPU(s):                   2
  On-line CPU(s) list:    0,1
Vendor ID:                GenuineIntel
  Model name:             Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz
    CPU family:           6
    Model:                106
    Thread(s) per core:   1
    Core(s) per socket:   2
    Socket(s):            1
    Stepping:             6
    BogoMIPS:             5586.87
    Flags:                fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr s
                          se sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid tsc_
                          known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c
                           rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 sme
                          p bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap clflushopt avx512cd avx512bw avx5
                          12vl xsaveopt xsavec xsaves md_clear
Virtualization features:
  Hypervisor vendor:      Microsoft
  Virtualization type:    full
Caches (sum of all):
  L1d:                    96 KiB (2 instances)
  L1i:                    64 KiB (2 instances)
  L2:                     2.5 MiB (2 instances)
  L3:                     48 MiB (1 instance)
NUMA:
  NUMA node(s):           1
  NUMA node0 CPU(s):      0,1
Vulnerabilities:
  Gather data sampling:   Unknown: Dependent on hypervisor status
  Itlb multihit:          KVM: Mitigation: VMX unsupported
  L1tf:                   Mitigation; PTE Inversion
  Mds:                    Mitigation; Clear CPU buffers; SMT Host state unknown
  Meltdown:               Mitigation; PTI
  Mmio stale data:        Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
  Reg file data sampling: Not affected
  Retbleed:               Not affected
  Spec rstack overflow:   Not affected
  Spec store bypass:      Vulnerable
  Spectre v1:             Mitigation; usercopy/swapgs barriers and __user pointer sanitization
  Spectre v2:             Mitigation; Retpolines; STIBP disabled; RSB filling; PBRSB-eIBRS Not affected; BHI Retpoli
                          ne
  Srbds:                  Not affected
  Tsx async abort:        Mitigation; Clear CPU buffers; SMT Host state unknown
```

## node.config

```
# The configuration options may differ by VM size

root@aks-nodepool1-24567707-vmss00000A:/# cat /etc/sysctl.d/999-sysctl-aks.conf
# This is a partial workaround to this upstream Kubernetes issue:
# https://github.com/kubernetes/kubernetes/issues/41916#issuecomment-312428731
net.ipv4.tcp_retries2=8
net.core.message_burst=80
net.core.message_cost=40
net.core.somaxconn=16384
net.ipv4.tcp_max_syn_backlog=16384
net.ipv4.neigh.default.gc_thresh1=4096
net.ipv4.neigh.default.gc_thresh2=8192
net.ipv4.neigh.default.gc_thresh3=16384
```

## node.log

This uses `kubectl get --raw` from https://learn.microsoft.com/en-us/azure/aks/kubelet-logs to retrieve kubelet logs.

```
# List available logs with the corresponding node name. This command is compatible with both Linux and Windows nodes.
kubectl get --raw "/api/v1/nodes/aksnp2019000006/proxy/logs"

# Sample commands for a Linux node.
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/syslog"|grep kubelet
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/syslog.1"|grep kubelet
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/azure/custom-script/handler.log"
```

- https://learn.microsoft.com/en-us/azure/aks/kubelet-logs
- https://kubernetes.io/docs/concepts/cluster-administration/system-logs/

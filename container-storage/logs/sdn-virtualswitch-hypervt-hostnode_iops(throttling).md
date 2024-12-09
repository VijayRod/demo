## os-linux-perf.iops

- https://azure.microsoft.com/en-us/blog/per-disk-metrics-managed-disks/
- https://dba.stackexchange.com/questions/279640/azure-virtual-machine-local-temp-storage-d-drive-how-much-iops-it-can-han
- https://github.com/Azure/AKS/issues/1373: AKS Latency and performance/availability issues due to IO saturation and throttling under load 
- https://learn.microsoft.com/en-us/azure/aks/developer-best-practices-resource-management#define-pod-resource-requests-and-limits
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-performance
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/troubleshoot-performance-bottlenecks-linux#disk
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/ddsv6-series: Disk throughput is measured in input/output operations per second (IOPS) and MBps where MBps = 10^6 bytes/sec.
- https://learn.microsoft.com/en-us/azure/virtual-machines/premium-storage-performance#iops

## os-linux-perf.iops.debug

Throttling
- IOPS and Mbps - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/memory-optimized/easv5-series: Disk throughput is measured in input/output operations per second (IOPS) and MBps where MBps = 10^6 bytes/sec
<br>

VM level throttling
- VM size limits at https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
- More: https://github.com/Azure/AKS/issues/1373: tbd each device would have a maximum IOPS. host throttling
<br>

- **tbd additional note ... for OS disk (tbd also for VM limit and data disk) - https://blogs.technet.microsoft.com/xiangwu/2017/05/14/azure-vm-storage-performance-and-throttling-demystify/
<br>

Disk level throttling (OS and data disks)
- Disk limits - https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types: Disk type comparison. Standard HDDs, Standard SSDs (E10 IOPS etc.), etc. For similar information, you can also visit https://learn.microsoft.com/en-us/azure/virtual-machines/disks-scalability-targets
- More - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/memory-optimized/easv5-series: Data disks can operate in cached or uncached modes. For cached data disk operation, the host cache mode is set to ReadOnly or ReadWrite. For uncached data disk operation, the host cache mode is set to None.
- More - https://learn.microsoft.com/en-us/azure/virtual-machines/disks-deploy-premium-v2: designed for IO-intense enterprise workloads that require sub-millisecond disk latencies and high IOPS and throughput at a low cost
- More - https://github.com/Azure/AKS/issues/1373: We recommend customers move to Ephemeral OS disks for production workloads. https://learn.microsoft.com/en-us/azure/aks/concepts-storage#ephemeral-os-disk: By default, Azure automatically replicates the operating system disk. lower read/write latency
- More tbd - https://learn.microsoft.com/en-in/archive/blogs/igorpag/azure-storage-secrets-and-linux-io-optimizations
<br>

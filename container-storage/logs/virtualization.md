## virtualization

- https://lwn.net/Kernel/Index/#Virtualization

## virtualization.hyperv.virtualswitch.hvnetvsc

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux-hyperv-issue: When a Hyper-V child partition is started and the guest operating system is running, the virtualization stack starts the Network Virtual Service Client (NetVSC).
- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-how-it-works: When a virtual machine (VM) is created in Azure, a synthetic network interface is created for each virtual NIC in its configuration. The synthetic interface is a VMbus device and uses the netvsc driver. Network packets that use this synthetic interface flow through the virtual switch in the Azure host and onto the datacenter's physical network.
- https://www.kernel.org/doc/html/latest/networking/device_drivers/ethernet/microsoft/netvsc.html
- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux-hyperv-issue

## virtualization.hyperv.virtualswitch.srvio

- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview: Accelerated Networking enables single root I/O virtualization (SR-IOV) on supported virtual machine (VM) types, greatly improving networking performance. This high-performance data path bypasses the host
- https://azure.microsoft.com/en-us/blog/maximize-your-vm-s-performance-with-accelerated-networking-now-generally-available-for-both-windows-and-linux/: much of Azure's software-defined networking stack off the CPUs and into FPGA-based SmartNICs
- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-mana-overview: In instances where the operating system doesn't or can't support MANA, network connectivity is provided through the hypervisor’s virtual switch.
- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-single-root-i-o-virtualization--sr-iov-

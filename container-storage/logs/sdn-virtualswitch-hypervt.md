## hyperv

```
root@aks-nodepool1-26613092-vmss000000:/# cat /dev/vmbus/hv_kvp
cat: /dev/vmbus/hv_kvp: Device or resource busy
```

- https://msrc.microsoft.com/blog/2019/01/fuzzing-para-virtualized-devices-in-hyper-v/
- https://www.kernel.org/doc/html/latest/virt/hyperv/index.html
- https://www.red-gate.com/simple-talk/devops/containers-and-virtualization/microsoft-hyper-v-networking-and-configuration-part-1/: the basics of Hyper-V networking
- https://www.red-gate.com/simple-talk/devops/containers-and-virtualization/microsoft-hyper-v-networking-and-configuration-part-2/: The networking configuration or scenarios explained in this 2nd part can be used on Hyper-V running on Windows Server 2008, Windows Server 2008 R2 and Windows Server 2012.
- https://www.red-gate.com/simple-talk/devops/containers-and-virtualization/microsoft-hyper-v-networking-and-configuration-part-iii/: best-practices for Hyper-V Networking and gave a few Hyper-V Networking examples.
- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/hyper-v-architecture
- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/hyper-v-architecture#glossary
- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-hyper-v
- https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc753637(v=ws.10)

## hyperv.VMBus

- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/hyper-v-architecture: The VMBus is a logical inter-partition communication channel. The parent partition hosts Virtualization Service Providers (VSPs) which communicate over the VMBus to handle device access requests from child partitions...
- https://www.kernel.org/doc/html/latest/virt/hyperv/vmbus.html: VMBus is a software construct provided by Hyper-V to guest VMs. 
- https://github.com/torvalds/linux/blob/master/Documentation/virt/hyperv/vmbus.rst


## hyperv.VMBus.child-partition[].IntegrationServices (VMware Tools)

```
# See the section on VSP
```

## hyperv.VMBus.child-partition[].IntegrationServices.VSC

```
# See the section on VSP
# See the section on accelnet
```

- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/hyper-v-architecture: Integration components, which include virtual server client (VSC) drivers, are also available for other client operating systems.

## hyperv.VMBus.child-partition[].IntegrationServices.VSC.hvnetvsc

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux-hyperv-issue: When a Hyper-V child partition is started and the guest operating system is running, the virtualization stack starts the Network Virtual Service Client (NetVSC).
- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-how-it-works: When a virtual machine (VM) is created in Azure, a synthetic network interface is created for each virtual NIC in its configuration. The synthetic interface is a VMbus device and uses the netvsc driver. Network packets that use this synthetic interface flow through the virtual switch in the Azure host and onto the datacenter's physical network.
- https://www.kernel.org/doc/html/latest/networking/device_drivers/ethernet/microsoft/netvsc.html
- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux-hyperv-issue

## hyperv.VMBus.child-partition[].IntegrationServices.VSC.hvnetvsc.VirtualSwitch

- https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon#overview: extended networking stack now includes components like the Virtual Switch that handle packet processing and switching.

## hyperv.VMBus.child-partition[].IntegrationServices.VSC.storvsc

- https://github.com/torvalds/linux/blob/master/drivers/scsi/storvsc_drv.c
- https://stackoverflow.com/questions/27830812/when-installing-ubuntu-on-hyper-v-disk-becomes-read-only: storvsc driver with ext4 file systems, with SCSI WRITE_SAME command

# hyperv.VMBus.child-partition[].kvp

- * https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/integration-services#hyper-v-data-exchange-service-kvp: Windows Service Name: vmickvpexchange. Linux Daemon Name: hv_kvp_daemon

## hyperv.VMBus.parent-partition.IntelVT (AMD-V)

- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/hyper-v-architecture: Hyper-V requires a processor that includes hardware assisted virtualization, such as is provided with Intel VT or AMD Virtualization (AMD-V) technology.

## hyperv.VMBus.parent-partition.VPort

- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-virtual-machine-multiple-queues: A VPort represents an internal port on the NIC switch of a network adapter that supports single root I/O virtualization (SR-IOV).
- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/virtual-ports--vports-: A virtual port (VPort) is a data object that represents an internal port on the NIC switch of a network adapter that supports single root I/O virtualization (SR-IOV).

## hyperv.VMBus.parent-partition.VPort.srvio

- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview: Accelerated Networking enables single root I/O virtualization (SR-IOV) on supported virtual machine (VM) types, greatly improving networking performance. This high-performance data path bypasses the host
- https://azure.microsoft.com/en-us/blog/maximize-your-vm-s-performance-with-accelerated-networking-now-generally-available-for-both-windows-and-linux/: much of Azure's software-defined networking stack off the CPUs and into FPGA-based SmartNICs
- https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-mana-overview: In instances where the operating system doesn't or can't support MANA, network connectivity is provided through the hypervisor’s virtual switch.
- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-single-root-i-o-virtualization--sr-iov-
- https://techcommunity.microsoft.com/blog/azurenetworkingblog/secure-high-performance-networking-for-data-intensive-kubernetes-workloads/4271478: Azure CNI supports SR-IOV (Single Root I/O Virtualization) technologies, which allows for dedicated network interfaces for pods, further enhancing performance by reducing the CPU overhead associated with networking.

## hyperv.VMBus.parent-partition.VPort.VMMQ

- https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-virtual-machine-multiple-queues: Virtual Machine Multiple Queues (VMMQ) is a NIC offload technology that extends Native RSS (RSSv1) to a Hyper-V virtual environment. 
  - VMMQ provides scalable network traffic processing for virtual ports (VPorts) in the parent partition of a virtualized node.
    
## hyperv.VMBus.parent-partition.VSP

- https://www.serverwatch.com/guides/understanding-hyper-v-vsp-vsc-and-vmbus-design/: Hyper-V implements Server-Side and Client-Side components called VSP and VSC, respectively. VSP stands for Virtualization Service Provider and VSC stands for Virtualization Service Clients
  - In a virtual environment, operating system components send hardware access requests using native drivers, but the requests are received by the virtual layer. Such requests are intercepted by the virtual layer before the request for accessing the hardware devices is honored. This interception is sometimes referred to as device emulation.
  - To avoid the extra layer of communication (device emulation), Microsoft provides a set of components called “Integration Services” for virtual machines running on Hyper-V. VMware provides “VMware Tools” for virtual machines running on ESX Server.
  - These two components (VSP and VSC) help facilitate the smooth and reliable communication between Child Partitions (Virtual Machines) and the Parent Partition (Hyper-V Server). VSPs always run in Parent Partition and VSCs run in Child Partitions.
  - ** There are four VSPs (Network, Video, Storage and HID) available in Hyper-V as well as four VSCs running in multiple child partitions
  - Both VSPs and corresponding VSCs communicate with each other using a communication channel called VMBUS. VMBUS is a special protocol designed to pass communication from a VSC to VSP running in the Parent Partition.
  - There can only be four VSPs running on a Hyper-V Server in the Parent Partition, but there could be multiple VSCs running on the same Hyper-V Server as part of the child partitions (four in each child partition).
  - VSPs are multithreading components that are running as part of the VMMS.exe and can serve multiple VSCs requests simultaneously.
- https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/hyper-v-integration-services-where-are-we-today/259554: Services running in the Guest/Host

## hyperv.VMBus.parent-partition.VSP.StorVSP

- https://sensepost.com/blog/2020/let-me-store-that-for-you/: Hyper-V STORVSP stands for ‘Storage Virtual Service Provider’...

## cpu

```
# bash

top # %Cpu(s) - id (CPU idle), load average, Tasks - zombie
```

- https://lwn.net/Kernel/Index/#cpufreq
- https://lwn.net/Kernel/Index/#CPUhog
- https://lwn.net/Kernel/Index/#Cpusets
- https://tldp.org/LDP/tlk/processors/processors.html
- https://www.itprotoday.com/it-infrastructure/inside-the-windows-nt-scheduler-part-1
  - The basic scheduling unit in NT is a thread.
  - Processes consist of a virtual address spacethat includes executable instructions, a set of resources such as file handles,and one or more threads that execute within its address space.
  - Typicalapplications consist of only one process, so program and processare often used synonymously
  - single-threaded,which means they run as one process with one thread. However, multithreadedprograms
  - scheduler examines the priorities of all thethreads ready to run at a given instant
  - NT assigns each thread a priority number from 1 to 31, where higher numberssignal higher priorities. (NT uses priority 0 for the system idle thread, whichexecutes when no other thread is able to.) NT reserves priorities 16 through 31(realtime priorities)
  - priority classes: realtime,high, normal, and idle.
- https://www.itprotoday.com/networking-security/how-windows-nt-dispatches-processes-and-threads
  - process is an instance of an application or system program that runs on a system
  - Affinity is the tendency for a thread to run on a particular processor or set of system processors
  - soft affinity by default, running a thread on the same processor it ran on previously. NT also supports hard affinity to let you specify which processors a process or thread uses
  - processor's cache memory stores the most commonly used instructions
- https://students.cs.byu.edu/~cs345ta/reference/NT%20Scheduling.doc
  - SMP systems contain more than one processor
  - Starvation Prevention
- https://www.baeldung.com/cs/async-vs-multi-threading
- https://learn.microsoft.com/en-in/windows/win32/procthread/scheduling
- https://learn.microsoft.com/en-in/archive/blogs/microsoft_press/new-book-windows-internals-seventh-edition-part-1
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/informationals/intro-fundamentals-of-operating-systems-course (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/introduction-to-operating-systems/cheatsheet
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-processes-and-threads (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-processes-and-threads/cheatsheet
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-process-scheduling (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-process-scheduling/cheatsheet
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-synchronization (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-synchronization/cheatsheet
- https://www.geeksforgeeks.org/computer-network-concepts-a-software-engineer-should-learn/#computer-network-concepts-should-a-software-engineer-learn

## cpu.architecture.arm

- https://lwn.net/Kernel/Index/#Architectures-Arm
- https://en.wikipedia.org/wiki/ARM_architecture_family: ARM (stylised in lowercase as arm, formerly an acronym for Advanced RISC Machines and originally Acorn RISC Machine) is a family of RISC instruction set architectures (ISAs) for computer processors

## cpu.architecture.arm.app.azurevm

- https://azure.microsoft.com/en-us/blog/now-in-preview-azure-virtual-machines-with-ampere-altra-armbased-processors/: Arm-based processor
    
## cpu.architecture.arm64

- https://learn.microsoft.com/en-us/azure/aks/create-node-pools#arm64-node-pools
- https://learn.microsoft.com/en-us/azure/aks/best-practices-cost: Arm64 VMs are power-efficient and cost effective but don't compromise on performance. With Arm64 node pool support in AKS, you can create Arm64 Ubuntu agent nodes...
- https://techcommunity.microsoft.com/blog/azurecompute/announcing-the-support-of-arm-based-vm-solutions-on-azure-marketplace/3968235: Azure Arm-based Virtual Machines (VMs) deliver improved price-performance and power efficiency.
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dpsv5-series?tabs=sizebasic: Specs. Ampere Altra [Arm64]
- https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/: Arm-based processor
- https://github.com/Azure/AgentBaker/tree/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2204arm64containerd

## cpu.architecture.gpu

```
# See the section on gpu
```
  
## cpu.architecture.x86_64.md

- https://lwn.net/Kernel/Index/#Architectures-x86
- https://www.kernel.org/doc/html/latest/arch/x86/x86_64/index.html

## cpu.interrupt

- https://tldp.org/LDP/tlk/dd/interrupts.html
- https://lwn.net/Kernel/Index/: interrupt
  
## cpu.interrupt.rqbalance(UnbalancedIRQs)

```
dpkg -l |grep irqbalance
ii  irqbalance                            1.8.0-1build1                           amd64        Daemon to balance interrupts for SMP systems

root@aks-nodepool1-24398294-vmss000000:/# systemctl status irqbalance.service
● irqbalance.service - irqbalance daemon
     Loaded: loaded (/lib/systemd/system/irqbalance.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-10-27 19:58:00 UTC; 7s ago
       Docs: man:irqbalance(1)
             https://github.com/Irqbalance/irqbalance
   Main PID: 11116 (irqbalance)
      Tasks: 2 (limit: 9516)
     Memory: 556.0K
        CPU: 32ms
     CGroup: /system.slice/irqbalance.service
             └─11116 /usr/sbin/irqbalance --foreground
Oct 27 19:58:00 aks-nodepool1-24398294-vmss000000 systemd[1]: Started irqbalance daemon.

systemctl restart irqbalance.service
```

- https://gist.github.com/juan-lee/cf53e166f7bb0a134b249ac0c434d495#file-patch-irqbalance-yaml
- https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202310.09.0.txt: irqbalance
- https://github.com/Irqbalance/irqbalance/
- https://linux.die.net/man/1/irqbalance
- https://zmalik.dev/posts/packet-drop
  
## cpu.k8s

```
# Units (cores/millicores)
1 core (virtual/physical) = 1000m (millicores/millicpu)
```

- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes: 0.1 is equivalent to the expression 100m, which can be read as "one hundred millicpu"
- https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/#cpu-units: suffix m to mean milli. CPU is always requested as an absolute quantity, never as a relative quantity; 0.1 is the same amount of CPU on a single-core, dual-core, or 48-core machine.

```
# CPU Capacity (VM CPU)
kubectl describe no
Capacity:
  cpu:                2
```

```
# Allocatable (usable capacity)
kubectl describe no
Allocatable:
  cpu:                1900m
```

- https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/#node-allocatable: The scheduler treats 'Allocatable' as the available capacity for pods.
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/: allocatable
- https://learn.microsoft.com/en-us/azure/aks/node-resource-reservations#cpu-reservations
- https://learn.microsoft.com/en-us/azure/aks/core-aks-concepts#resource-reservations
- https://learnk8s.io/allocatable-resources

```
## event.FailedScheduling.Insufficient cpu
# error in scheduler

kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      requests:
        cpu: 100
EOF
kubectl describe no # FailedScheduling. 2 Insufficient cpu    
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/framework/plugins/noderesources/fit.go: Reason:       "Insufficient cpu",

```
## event.OutOfcpu
# error in kubelet i.e. after scheduling to a node
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/lifecycle/predicate.go: OutOfcpu. InsufficientResourceError. "Node didn't have enough resource: %s, requested: %d, used: %d, capacity: %d". For example, "Node didn't have enough resource: cpu,".
- https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/kubelet.go: lifecycle.OutOfCPU
- https://github.com/kubernetes/kubernetes/blob/master/pkg/apis/core/types.go: type ResourceName string. // CPU, in cores. (500m = .5 cores). ResourceCPU ResourceName = "cpu"
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename: If the named node does not have the resources to accommodate the Pod, the Pod will fail and its reason will indicate why, for example OutOfmemory or OutOfcpu.
- https://github.com/kubernetes/kubernetes/issues/106884#issuecomment-1005074672: a Kubelet must consider the resources of terminating pods
- https://github.com/kubernetes/kubernetes/issues/106884#issuecomment-1005891654: Create a large number of pods that run for a known short amount of time that consume 1 or more pod resources (1-5s)

## cpu.OS (operating system)

- https://jameskle.com/writes/operating-systems
- https://www.geeksforgeeks.org/prepare-cs-core-subjects-for-placements/
- https://www.educative.io/blog/operating-systems-crashcourse

## cpu.storage.cache

- https://robots.net/tech/where-does-cpu-store-its-computations/: each level having a different size and proximity to the CPU. The first level cache, known as L1 cache, is the fastest and smallest cache, located directly on the CPU chip. It is divided into separate instruction cache (L1i cache) and data cache (L1d cache), allowing for parallel access to instructions and data.
  - If the data or instructions are not found in the L1 cache, the CPU checks the next level of cache, called the L2 cache. The L2 cache is larger but slightly slower than the L1 cache. Depending on the system, there may be additional levels of cache, such as L3 cache, which further increase the capacity but introduce additional latency.
  - The cache management algorithms determine how data is stored and replaced in the cache. Popular caching strategies include least recently used (LRU) and least frequently used (LFU)
- https://www.howtogeek.com/891526/l1-vs-l2-vs-l3-cache/

## cpu.storage.register

- https://robots.net/tech/where-does-cpu-store-its-computations/: Registers are incredibly fast compared to other forms of memory. They can perform operations within a single clock cycle, making them essential for efficient execution of instructions. When the CPU receives an instruction, it fetches the necessary data from memory and stores it in registers, ready for processing.
  - One important type is the program counter (PC) register, which keeps track of the address of the next instruction to be fetched from memory.
  - Another critical type of register is the accumulator, which stores intermediate results during mathematical and logical operations.

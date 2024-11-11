## cpu

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

## cpu.irqbalance(UnbalancedIRQs)

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
- https://zmalik.dev/posts/packet-drop

## cpu.OS (operating system)

- https://jameskle.com/writes/operating-systems
- https://www.geeksforgeeks.org/prepare-cs-core-subjects-for-placements/
- https://www.educative.io/blog/operating-systems-crashcourse

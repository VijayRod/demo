

- https://github.com/Azure/AKS/blob/2023-09-10/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202309.06.0.txt: bpftrace. bcc-tools
- https://ebpf.io/labs/
- https://www.lizrice.com/
- https://www.youtube.com/watch?v=TJgxjVTZtfw: Tutorial: Getting Started with eBPF - Liz Rice, Isovalent
- https://www.brendangregg.com/BPF/bpftrace-cheat-sheet.html
- https://manpages.debian.org/testing/bpfcc-tools/index.html
- https://github.com/Azure-Samples/azure-files-samples/tree/master/SMBDiagnostics: trace-cifsbpf (eBPF script)
- https://www.brendangregg.com/ebpf.html
- https://github.com/cloudflare/ebpf_exporter?tab=readme-ov-file#reading-material

```
# bpftrace
# tip: bpftrace and bpftool come pre-installed on an aks node
bpftrace # display help info
bpftrace -V

# bpftrace.map
sudo bpftool map show

# bpftrace.prog
bpftool prog show # lists ebpf programs currently running in the system

# bpftrace.prog.type
# e.g. kprobe, tracepoint, xdp, cgroup etc. seen in the output of bpftool prog show

# bpftrace.prog.type.cgroup
find /sys/fs/cgroup/ -type d # find active cgroups
sudo bpftool cgroup show /sys/fs/cgroup/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod56ff41ec_02dd_45eb_8871_6fdef3ca7a24.slice/cri-containerd-e6a8a39d36db49c525dc009c5f0d7313575ed420640528c19604441db5c0773f.scope # view if any ebpf program is attached to this cgroup

# bpftrace.prog.type.kprobe (kernel probe)
cat /host/sys/kernel/debug/kprobes/list # displays the list of kprobes registered with the linux kernel

# bpftrace.prog.type.net (tc, xdp)
sudo bpftool net # ebpf programs attached to the network interface
```

```
# bpftrace.example.bash
# traces syscalls; press Ctrl+C to stop
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_execve { printf("%s\n", str(args->filename)); }'

# options to stop in another window
ps aux | grep bpftrace
sudo kill <pid>
sudo kill -9 <pid> # force kill
```

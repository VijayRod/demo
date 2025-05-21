```
kubectl describe po
kubectl describe po | grep A5 State
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/apis/core/types.go: type ContainerStateTerminated struct {	ExitCode int32
- https://cloud.google.com/kubernetes-engine/docs/troubleshooting#check_exit_code_of_the_crashed_container
- https://docs.docker.com/engine/reference/run/#exit-status
- https://github.com/kodekloudhub/throw-dice/blob/master/throw-dice.sh
- https://github.com/kubernetes/kubernetes/issues/82519: The Exit Code is obtained from docker's ExitCode. Normally it will be the exit status of the process
- https://komodor.com/learn/exit-codes-in-containers-and-kubernetes-the-complete-guide/: SIGKILL, SIGSEGV, SIGTERM
  - https://komodor.com/learn/what-is-sigkill-signal-9-fast-termination-of-linux-containers/
  - https://komodor.com/learn/sigsegv-segmentation-faults-signal-11-exit-code-139/
  - https://komodor.com/learn/sigterm-signal-15-exit-code-143-linux-graceful-termination/
  - bash: kill -l // 9) SIGKILL, 11) SIGSEGV, 15) SIGTERM
  - bash: kill -n 9 <pid> // SIGKILL
- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
- https://stackoverflow.com/questions/31297616/what-is-the-authoritative-list-of-docker-run-exit-codes
- https://tldp.org/LDP/abs/html/exitcodes.html: Exit Codes With Special Meanings
- https://www.datree.io/resources/kubernetes-error-codes-crashloopbackoff: An exit code ranging from 1 to 128 would show an exit stemming from internal (app) signals.
- https://www.man7.org/linux/man-pages/man7/signal.7.html: Signal numbering for standard signals
- https://www.tencentcloud.com/document/product/457/35758: value of the exit code is the value of the interrupt signal plus 128

```
root@aks-nodepool1-29985679-vmss00000A:/# kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

> ## exitCode=0

- https://www.datree.io/resources/kubernetes-error-codes-crashloopbackoff: an exit status of “0” means that the container exited normally
- https://stackoverflow.com/questions/61836061/pod-terminated-with-reason-error-and-exit-code-1: exit code 0 means completed
  
```
# sample.test
# kill 15 (128+15=143) (tbd) with "exitCode=0"

k run nginx --image=nginx
k get po -owide -w

root@aks-nodepool1-29985679-vmss00000A:/# ps -aux | grep nginx
root      219567  0.0  0.0  11464  7368 ?        Ss   11:58   0:00 nginx: master process nginx -g daemon off;
systemd+  219603  0.0  0.0  11928  2764 ?        S    11:58   0:00 nginx: worker process
systemd+  219604  0.0  0.0  11928  2764 ?        S    11:58   0:00 nginx: worker process
root@aks-nodepool1-29985679-vmss00000A:/# kill -n 15 219567

k get po
NAME             READY   STATUS    RESTARTS      AGE
nginx            1/1     Running   1 (11s ago)   2m30s

# Exit Code:    0
k describe po nginx
Containers:
  nginx:
    Container ID:   containerd://68309eece1d6bf91d3f5c8730012cb2ca0e393059f4062da4d2d1598d040a267
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:c15da6c91de8d2f436196f3a768483ad32c258ed4e1beb3d367a27ed67253e66
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 16 May 2025 18:00:45 +0000
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 16 May 2025 18:00:30 +0000
      Finished:     Fri, 16 May 2025 18:00:43 +0000
    Ready:          True
    Restart Count:  1
    
# ContainerDied, exitCode=0
root@aks-nodepool1-29985679-vmss00000A:/# cat /var/log/syslog | grep "May 16 18:02:"
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A systemd[1]: cri-containerd-f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c.scope: Deactivated successfully.
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.754610904Z" level=info msg="received exit event container_id:\"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c\"  id:\"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c\"  pid:219567  exited_at:{seconds:1747396843  nanos:754293507}"
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A systemd[1]: run-containerd-io.containerd.runtime.v2.task-k8s.io-f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c-rootfs.mount: Deactivated successfully.
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772912023Z" level=info msg="shim disconnected" id=f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c namespace=k8s.io
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772957423Z" level=warning msg="cleaning up after shim disconnected" id=f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c namespace=k8s.io
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772965922Z" level=info msg="cleaning up dead shim" namespace=k8s.io
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655347    4052 kubelet.go:2439] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"7ed0f963-37b7-4383-9d94-77e3a5afb787","Type":"ContainerDied","Data":"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c"}
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655636    4052 scope.go:117] "RemoveContainer" containerID="f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c"
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655940    4052 generic.go:334] "Generic (PLEG): container finished" podID="7ed0f963-37b7-4383-9d94-77e3a5afb787" containerID="f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c" exitCode=0
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:44.656458081Z" level=info msg="PullImage \"nginx:latest\""
..May 16 18:02:45 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:45.506941536Z" level=info msg="CreateContainer within sandbox \"0a1d10b0bff7e6307119369f84142b36e59131b3ff97ffd022bf5d99f7564e97\" for container &ContainerMetadata{Name:nginx,Attempt:1,}"
```

> ## exitCode=137

```
kubectl describe po
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
```

- https://komodor.com/learn/how-to-fix-oomkilled-exit-code-137/
- https://komodor.com/learn/exit-codes-in-containers-and-kubernetes-the-complete-guide/: Exit Code 137	Immediate termination (SIGKILL)	Container was immediately terminated by the operating system via SIGKILL signal
- https://stackoverflow.com/questions/59729917/kubernetes-pods-terminated-exit-code-137: Exit Code 137 does not necessarily mean OOMKilled. It indicates failure as container received SIGKILL (some interrupt or ‘oom-killer’ [OUT-OF-MEMORY]). If pod got OOMKilled, you will see below line when you describe the pod
      State:        Terminated
      Reason:       OOMKilled
- 137 mean that k8s kill container for some reason (may be it didn't pass liveness probe). Cod 137 is 128 + 9(SIGKILL) process was killed by external signal

```
# exitcode.137.sample

kubectl delete po nginx
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      limits:
        memory: 100Mi # This has a limit
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
sleep 10
kubectl get po nginx
kubectl exec -it nginx -- bash

# root@nginx:/#
apt update
apt install stress-ng -y
swapoff -a
for ((i = 0 ; i < 100 ; i++)); do
  stress-ng --vm 1 --vm-bytes 5% -t 1h &> /dev/null &
  sleep 1
done
# command terminated with exit code 137
```

```
kubectl get po nginx
NAME    READY   STATUS    RESTARTS      AGE
nginx   1/1     Running   1 (20s ago)   113s

kubectl describe po nginx
Containers:
  nginx:
    State:          Running
      Started:      Thu, 12 Oct 2023 19:00:49 +0000
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Thu, 12 Oct 2023 18:59:16 +0000
      Finished:     Thu, 12 Oct 2023 19:00:48 +0000

cat /var/log/syslog
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347168] stress-ng-vm invoked oom-killer: gfp_mask=0x1100cca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=1000
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347175] CPU: 1 PID: 183960 Comm: stress-ng-vm Not tainted 5.15.0-1041-azure #48-Ubuntu
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347178] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS Hyper-V UEFI Release v4.1 05/09/2022
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347179] Call Trace:
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347181]  <TASK>
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347184]  show_stack+0x52/0x5c
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347189]  dump_stack_lvl+0x38/0x4d
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347193]  dump_stack+0x10/0x16
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347194]  dump_header+0x53/0x228
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347198]  oom_kill_process.cold+0xb/0x10
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347201]  out_of_memory+0x106/0x2e0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347205]  mem_cgroup_out_of_memory+0x13f/0x160
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347210]  try_charge_memcg+0x6cd/0x790
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347212]  ? kernel_init_free_pages.part.0+0x4a/0x70
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347216]  ? get_page_from_freelist+0x353/0x540
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347217]  ? kernel_init_free_pages.part.0+0x4a/0x70
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347220]  charge_memcg+0x45/0xa0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347221]  __mem_cgroup_charge+0x2d/0x90
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347223]  __add_to_page_cache_locked+0x2db/0x350
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347226]  ? scan_shadow_nodes+0x40/0x40
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347230]  add_to_page_cache_lru+0x4d/0xd0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347232]  pagecache_get_page+0x192/0x590
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347234]  ? page_cache_ra_unbounded+0x166/0x210
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347236]  filemap_fault+0x441/0xa00
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347238]  ? filemap_map_pages+0x2e2/0x3f0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347240]  __do_fault+0x3c/0x170
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347243]  do_read_fault+0xeb/0x190
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347245]  do_fault+0xa0/0x380
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347247]  handle_pte_fault+0x1ec/0x260
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347248]  __handle_mm_fault+0x409/0x760
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347251]  handle_mm_fault+0xc8/0x2a0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347254]  do_user_addr_fault+0x1bc/0x660
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347257]  exc_page_fault+0x71/0x160
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347260]  asm_exc_page_fault+0x27/0x30
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347264] RIP: 0033:0x560f8a11464d
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347270] Code: Unable to access opcode bytes at RIP 0x560f8a114623.
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347270] RSP: 002b:00007ffee6141240 EFLAGS: 00010206
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347273] RAX: 00007f43d80a3000 RBX: 0000560f8a477f20 RCX: 0000000000167b81
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347274] RDX: 00007f43d26b5000 RSI: 00007f43def6d000 RDI: 0000000000167b80
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347275] RBP: 00007ffee6141430 R08: 0000000000000000 R09: 0000000000000040
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347276] R10: 00007f43d26b5000 R11: 000000000c8b8000 R12: 0000000000000000
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347278] R13: 0000000000000000 R14: 00007ffee6141370 R15: 0000560f8a0f4930
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347281]  </TASK>
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347282] memory: usage 102400kB, limit 102400kB, failcnt 6402
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347284] swap: usage 0kB, limit 9007199254740988kB, failcnt 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347285] Memory cgroup stats for /kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod5931aa75_4603_4e65_b552_7c71cf55cfb5.slice:
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] anon 98742272
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] file 2469888
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] kernel_stack 131072
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] pagetables 851968
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] percpu 11752
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] sock 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] shmem 2297856
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] file_mapped 2310144
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] file_dirty 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] file_writeback 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] swapcached 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] anon_thp 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] file_thp 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] shmem_thp 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] inactive_anon 101011456
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] active_anon 28672
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] inactive_file 86016
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] active_file 73728
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] unevictable 12288
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] slab_reclaimable 2009104
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] slab_unreclaimable 443144
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] slab 2452248
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] workingset_refault_anon 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] workingset_refault_file 1190
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] workingset_activate_anon 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] workingset_activate_file 75
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347299] workingset_restore_anon 0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347301] Tasks state (memory values in pages):
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347302] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347304] [ 181505] 65535 181505      243        1    28672        0          -998 pause
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347307] [ 181537]     0 181537     2847     1835    57344        0           988 nginx
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347310] [ 181574]   101 181574     2963      718    53248        0           988 nginx
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347312] [ 181575]   101 181575     2963      718    53248        0           988 nginx
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347314] [ 183424]     0 183424     1047      883    53248        0           988 bash
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347316] [ 183957]     0 183957    23413     1804    86016        0           988 stress-ng
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347317] [ 183958]     0 183958      621      229    45056        0           988 sleep
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347319] [ 183959]     0 183959    23414      283    81920        0           988 stress-ng-vm
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347321] [ 183960]     0 183960    74798    23376   487424        0          1000 stress-ng-vm
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347322] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=cri-containerd-25a38b5b8d556d7983d975577f5ac75ebbcfb4b269e6deaa0a0440c1ffc969ca.scope,mems_allowed=0,oom_memcg=/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod5931aa75_4603_4e65_b552_7c71cf55cfb5.slice,task_memcg=/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod5931aa75_4603_4e65_b552_7c71cf55cfb5.slice/cri-containerd-25a38b5b8d556d7983d975577f5ac75ebbcfb4b269e6deaa0a0440c1ffc969ca.scope,task=stress-ng-vm,pid=183960,uid=0
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.347333] Memory cgroup out of memory: Killed process 183960 (stress-ng-vm) total-vm:299192kB, anon-rss:93176kB, file-rss:316kB, shmem-rss:12kB, UID:0 pgtables:476kB oom_score_adj:1000
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 systemd[1]: cri-containerd-25a38b5b8d556d7983d975577f5ac75ebbcfb4b269e6deaa0a0440c1ffc969ca.scope: A process of this unit has been killed by the OOM killer.
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 containerd[2388]: time="2023-10-12T19:00:20.879932879Z" level=info msg="TaskOOM event container_id:\"25a38b5b8d556d7983d975577f5ac75ebbcfb4b269e6deaa0a0440c1ffc969ca\""
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 node-problem-detector-startup.sh[3240]: I1012 19:00:20.884452    3240 log_monitor.go:160] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2023-10-12 19:00:20.43504385 +0000 UTC m=+8477.413334661 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 183960 (stress-ng-vm) total-vm:299192kB, anon-rss:93176kB, file-rss:316kB, shmem-rss:12kB, UID:0 pgtables:476kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2023-10-12 19:39:03.087916354 +0000 UTC m=+0.066207065 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2023-10-12 19:39:03.087916454 +0000 UTC m=+0.066207165 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
Oct 12 19:00:20 aks-nodepool1-24207654-vmss000001 kernel: [ 8523.444701] stress-ng-vm invoked oom-killer: gfp_mask=0x1100cca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=1000
```

```
# exitcode.137.sample2

kubectl delete po nginx
kubectl run nginx --image=nginx # No resource limits
sleep 10
kubectl get po nginx
kubectl exec -it nginx -- bash

# root@nginx:/#
apt update
apt install stress-ng -y
swapoff -a
for ((i = 0 ; i < 100 ; i++)); do
  stress-ng --vm 1 --vm-bytes 5% -t 1h &> /dev/null &
  sleep 1
done
# command terminated with exit code 137
```

```
kubectl describe po nginx
Status:           Failed
Reason:           Evicted
Message:          The node was low on resource: memory. Threshold quantity: 750Mi, available: 225800Ki. Container nginx was using 4395616Ki, request is 0, has larger consumption of memory.
IP:               10.244.1.3
IPs:
  IP:  10.244.1.3
Containers:
  nginx:
    Container ID:
    Image:          nginx
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was terminated
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
    Ready:          False
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tv6m9 (ro)
Conditions:
  Type               Status
  DisruptionTarget   True
  Initialized        True
  Ready              False
  ContainersReady    False
  PodScheduled       True
Events:
  Type     Reason     Age    From               Message
  ----     ------     ----   ----               -------
  Warning  Evicted    7m24s  kubelet            The node was low on resource: memory. Threshold quantity: 750Mi, available: 225800Ki. Container nginx was using 4395616Ki, request is 0, has larger consumption of memory.
  Normal   Killing    7m24s  kubelet            Stopping container nginx
  
cat /var/log/syslog
Oct 12 19:34:44 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:44.999261    2480 eviction_manager.go:374] "Eviction manager: pods ranked for eviction" pods="[default/nginx kube-system/kube-proxy-5thr6 kube-system/csi-azurefile-node-wz6c7 kube-system/csi-azuredisk-node-vsljb kube-system/cloud-node-manager-wcrvk kube-system/azure-ip-masq-agent-mr5d7 kube-system/ama-logs-6h992]"
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.000152    2480 kuberuntime_container.go:709] "Killing container with a grace period" pod="default/nginx" podUID=27aff94d-e0d9-43d1-84d6-9ab000aa57e2 containerName="nginx" containerID="containerd://4296b9e2377fddb0e7e42d20223c36771268cb7a1828315331405b66f0030add" gracePeriod=30
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.357018    2480 kubelet.go:2231] "SyncLoop (PLEG): event for pod" pod="default/nginx" event=&{ID:27aff94d-e0d9-43d1-84d6-9ab000aa57e2 Type:ContainerDied Data:4296b9e2377fddb0e7e42d20223c36771268cb7a1828315331405b66f0030add}
Oct 12 19:34:45 aks-nodepool1-24207654-vmss000002 kubelet[2480]: I1012 19:34:45.445172    2480 eviction_manager.go:595] "Eviction manager: pod is evicted successfully" pod="default/nginx"
```

> ## exitcode.143

```
Quando vês 143 na prática?
Escalonamento automático (horizontal scaling down)
Rolling update
Pod eviction (por falta de recursos)
Comandos kubectl delete pod
Falhas do nó
```

- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination: TERM (aka. SIGTERM) signal.. Once the grace period has expired, the KILL (SIGKILL) signal
- https://discuss.kubernetes.io/t/when-scale-replicas-0-do-k8s-send-sigterm/11838: It should receive SIGTERM and if its taking too long, it will eventually get a SIGKILL. You can adjust the timeout with terminationGracePeriodSeconds.

```
# no repro with any of the items below, and no exitCode=143 in the syslog

# exitcode.143.example (manual pod kill)
kubectl run sigterm-test --image=nginx
kubectl get po -w
kubectl delete pod sigterm-test
kubectl get pod sigterm-test -o jsonpath="{.status.containerStatuses[*].lastState.terminated.exitCode}" # Error from server (NotFound): pods "nginx-676b6c5bbc-2nzpk" not found

kubectl create deploy nginx --image=nginx
kubectl scale deploy nginx --replicas 10
kubectl get deploy -w
kubectl get po -l app=nginx -owide
kubectl delete pod nginx-676b6c5bbc-2nzpk
kubectl get pod nginx-676b6c5bbc-2nzpk -o jsonpath="{.status.containerStatuses[*].lastState.terminated.exitCode}" # Error from server (NotFound): pods "nginx-676b6c5bbc-2nzpk" not found

# exitcode.143.example2 (send SIGTERM with kubectl exec)
kubectl run test-143 --image=ubuntu --restart=Never -it -- bash
sleep 3600
## terminal 2
kubectl exec test-143 -- pkill -15 sleep
kubectl get pod test-143 -o jsonpath="{.status.containerStatuses[*].lastState.terminated.exitCode}" # no lastState.terminated

# exitcode.143.example3 (scale-down to 0 with a deployment)
kubectl scale deployment nginx --replicas=0
Vai terminar os pods com SIGTERM > exit code 143 # no log indicating 143
```

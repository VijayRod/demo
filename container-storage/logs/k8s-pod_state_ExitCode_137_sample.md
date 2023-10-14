```
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

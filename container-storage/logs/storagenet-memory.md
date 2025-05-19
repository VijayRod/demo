## memory

- https://lwn.net/Kernel/Index/#Memory_management
- https://tldp.org/LDP/tlk/mm/memory.html
- https://www.itprotoday.com/networking-security/how-windows-nt-dispatches-processes-and-threads
  - processor's cache memory stores the most commonly used instructions
- https://www.itprotoday.com/it-infrastructure/windows-nt-architecture-part-2: 32-bit (4GB) address space; however, applications can directly access only the first 2GB
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-memory-management (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-memory-management/cheatsheet
  
## memory.error.OOMKilled

```
# Refer to the k8s section for a syslog example

tail /dev/zero
Killed

bash -c "for b in {0..99999999}; do a=$b$a; done"
Killed

# stress-ng works in pods/containers too
```

- https://askubuntu.com/questions/1188024/how-to-test-oom-killer-from-command-line
- https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html#oom-dump-tasks: pgtables_bytes
- https://serverfault.com/questions/1118560/explain-of-oom-killer-logs: rss
- https://www.baeldung.com/linux/memory-overcommitment-oom-killer
- https://www.kernel.org/doc/gorman/html/understand/understand016.html: Chapter?13??Out Of Memory Management
- tbd https://sysctl-explorer.net/vm/oom_dump_tasks/
  
## memory.error.OOMKilled.k8s

- https://komodor.com/learn/how-to-fix-oomkilled-exit-code-137/
- add tbd https://mihai-albert.com/2022/02/13/out-of-memory-oom-in-kubernetes-part-2-the-oom-killer-and-application-runtime-implications/

```
# OOMKilled.k8s.example

kubectl run nginx --image=nginx
kubectl get po -w
kubectl exec -it nginx -- /bin/bash
bash -c "for b in {0..99999999}; do a=$b$a; done" 
# bash: "command terminated with exit code 137"

kubectl describe po | grep -A5 "Last State"
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Mon, 19 May 2025 10:14:23 +0000
      Finished:     Mon, 19 May 2025 10:14:43 +0000
    Ready:          True
    Restart Count:  1

kubectl describe no
  Warning  OOMKilling          65s                kernel-monitor                                                Memory cgroup out of memory: Killed process 7788 (bash) total-vm:7169492kB, anon-rss:7165824kB, file-rss:44kB, shmem-rss:0kB, UID:0 pgtables:14076kB oom_score_adj:1000
```

```
# "bash invoked oom-killer": The memory-command was "bash -c ..". 
cat /var/log/syslog
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201253] bash invoked oom-killer: gfp_mask=0xcc0(GFP_KERNEL), order=0, oom_score_adj=1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201260] CPU: 0 PID: 7788 Comm: bash Not tainted 5.15.0-1087-azure #96-Ubuntu
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201264] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS Hyper-V UEFI Release v4.1 08/23/2024
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201265] Call Trace:
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201268]  <TASK>
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201271]  show_stack+0x52/0x5c
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201277]  dump_stack_lvl+0x38/0x4d
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201281]  dump_stack+0x10/0x16
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201284]  dump_header+0x53/0x228
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201287]  oom_kill_process.cold+0xb/0x10
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201290]  out_of_memory+0x106/0x2e0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201294]  ? srso_alias_return_thunk+0x5/0x7f
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201298]  mem_cgroup_out_of_memory+0x13f/0x160
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201303]  try_charge_memcg+0x6cd/0x790
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201308]  charge_memcg+0x45/0xa0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201311]  __mem_cgroup_charge+0x2d/0x90
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201314]  do_anonymous_page+0x104/0x4c0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201318]  handle_pte_fault+0x21b/0x260
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201320]  __handle_mm_fault+0x409/0x760
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201325]  handle_mm_fault+0xc8/0x2a0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201328]  do_user_addr_fault+0x1bc/0x630
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201333]  exc_page_fault+0x71/0x160
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201337]  asm_exc_page_fault+0x27/0x30
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201340] RIP: 0033:0x7efde8451109
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201343] Code: 8d 34 19 48 39 d5 48 89 75 60 0f 95 c2 48 29 d8 48 83 c1 10 0f b6 d2 48 83 c8 01 48 c1 e2 02 48 09 da 48 83 ca 01 48 89 51 f8 <48> 89 46 08 e9 7b ff ff ff 48 8d 0d 20 f0 0f 00 48 8d 15 90 4a 10
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201345] RSP: 002b:00007ffcc76d5c40 EFLAGS: 00010206
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201348] RAX: 000000000000dff1 RBX: 0000000000000020 RCX: 000055a84b591000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201350] RDX: 0000000000000021 RSI: 000055a84b591010 RDI: 0000000000000004
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201351] RBP: 00007efde858bc60 R08: 00007efde858bc60 R09: 0000000000000000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201353] R10: 19fd188c4916f13c R11: 0000000000000020 R12: 0000000000000010
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201354] R13: 0000000000000002 R14: ffffffffffffffb8 R15: 00007efde858bcc0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201359]  </TASK>
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201360] memory: usage 7464436kB, limit 7464436kB, failcnt 1133
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201362] swap: usage 0kB, limit 9007199254740988kB, failcnt 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201364] Memory cgroup stats for /kubepods.slice:
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] anon 7601418240
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] file 24576
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] kernel_stack 1605632
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] pagetables 17588224
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] percpu 280264
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] sock 4096
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] shmem 8192
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] file_mapped 4096
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] file_dirty 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] file_writeback 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] swapcached 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] anon_thp 987758592
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] file_thp 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] shmem_thp 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] inactive_anon 7601324032
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] active_anon 102400
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] inactive_file 8192
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] active_file 8192
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] unevictable 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] slab_reclaimable 2725296
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] slab_unreclaimable 2729520
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] slab 5454816
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] workingset_refault_anon 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] workingset_refault_file 905
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] workingset_activate_anon 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] workingset_activate_file 268
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201378] workingset_restore_anon 0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201381] Tasks state (memory values in pages):
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201382] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201384] [   7557] 65535  7557      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201388] [   7620]     0  7620     2866     1264    61440        0          1000 nginx
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201391] [   7656]   101  7656     2982      610    61440        0          1000 nginx
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201394] [   7657]   101  7657     2982      610    61440        0          1000 nginx
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201396] [   7712]     0  7712     1048      366    49152        0          1000 bash
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201399] [   7788]     0  7788  1792373  1791695 14413824        0          1000 bash
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201402] [   4792] 65535  4792      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201405] [   5724]     0  5724   318532     6957   229376        0          -997 azure-cns
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201408] [   4796] 65535  4796      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201411] [   5045]     0  5045   403969     1852   184320        0          -997 ip-masq-agent-v
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201414] [   4769] 65535  4769      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201417] [   4961]     0  4961   311100     1681   126976        0          -997 livenessprobe
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201420] [   5265]     0  5265   311117     1688   131072        0          -997 csi-node-driver
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201423] [   5847]     0  5847   323304     2602   237568        0          -997 azurediskplugin
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201426] [   4814] 65535  4814      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201429] [   4996] 65532  4996   325733     3168   253952        0          -997 cloud-node-mana
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201432] [   4783] 65535  4783      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201435] [   4953]     0  4953   311164     1680   131072        0          -997 livenessprobe
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201438] [   5291]     0  5291   311117     1175   126976        0          -997 csi-node-driver
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201440] [   5632]     0  5632   322267     2575   225280        0          -997 azurefileplugin
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201443] [   4776] 65535  4776      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201446] [   5708]     0  5708   322762     3234   229376        0          -999 kube-proxy
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201449] [   6457] 65535  6457      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201452] [   7336]     0  7336   352485    11659   356352        0           996 fluent-bit
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201455] [   6171] 65535  6171      243        1    28672        0          -998 pause
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201457] [   6256]     0  6256   317665     1737   184320        0           996 app
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201460] [   6312]     0  6312   315110     2270   163840        0           984 app
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201462] [   6331]     0  6331  1393044    20814   417792        0           984 ig
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201465] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope,mems_allowed=0,oom_memcg=/kubepods.slice,task_memcg=/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-poda5d8fdd1_1369_469e_8a7d_2c1047529435.slice/cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope,task=bash,pid=7788,uid=0
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.201482] Memory cgroup out of memory: Killed process 7788 (bash) total-vm:7169492kB, anon-rss:7165824kB, file-rss:956kB, shmem-rss:0kB, UID:0 pgtables:14076kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.208991] Tasks in /kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-poda5d8fdd1_1369_469e_8a7d_2c1047529435.slice/cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope are going to be killed due to memory.oom.group set
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.209001] Memory cgroup out of memory: Killed process 7620 (nginx) total-vm:11464kB, anon-rss:1156kB, file-rss:3900kB, shmem-rss:0kB, UID:0 pgtables:60kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.217970] Memory cgroup out of memory: Killed process 7656 (nginx) total-vm:11928kB, anon-rss:1572kB, file-rss:616kB, shmem-rss:0kB, UID:101 pgtables:60kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.227944] Memory cgroup out of memory: Killed process 7657 (nginx) total-vm:11928kB, anon-rss:1572kB, file-rss:616kB, shmem-rss:0kB, UID:101 pgtables:60kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.235585] Memory cgroup out of memory: Killed process 7712 (bash) total-vm:4192kB, anon-rss:520kB, file-rss:44kB, shmem-rss:0kB, UID:0 pgtables:48kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 kernel: [  139.243276] Memory cgroup out of memory: Killed process 7788 (bash) total-vm:7169492kB, anon-rss:7165824kB, file-rss:44kB, shmem-rss:0kB, UID:0 pgtables:14076kB oom_score_adj:1000
May 19 18:14:43 aks-np0cas-14924781-vmss000008 systemd[1]: cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope: A process of this unit has been killed by the OOM killer.
May 19 18:14:43 aks-np0cas-14924781-vmss000008 containerd[2723]: time="2025-05-19T18:14:43.465831620Z" level=info msg="Container exec \"793f1dc5a4f72c1099308b12ccdab3177240d37a149d0b264ca083adeb281ce0\" stdin closed"
May 19 18:14:43 aks-np0cas-14924781-vmss000008 containerd[2723]: time="2025-05-19T18:14:43.578084676Z" level=info msg="TaskOOM event container_id:\"9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987\""
May 19 18:14:43 aks-np0cas-14924781-vmss000008 systemd[1]: cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope: Deactivated successfully.
May 19 18:14:43 aks-np0cas-14924781-vmss000008 systemd[1]: cri-containerd-9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987.scope: Consumed 10.443s CPU time.
May 19 18:14:43 aks-np0cas-14924781-vmss000008 containerd[2723]: time="2025-05-19T18:14:43.767267300Z" level=info msg="received exit event container_id:\"9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987\"  id:\"9192cb33411ff69d015a3577db136757f5b145064a1703efea3d0e12e8a64987\"  pid:7620  exit_status:137  exited_at:{seconds:1747649683  nanos:725415123}"
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.767687    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.700333489 +0000 UTC m=+98.358875828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7788 (bash) total-vm:7169492kB, anon-rss:7165824kB, file-rss:956kB, shmem-rss:0kB, UID:0 pgtables:14076kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.769475    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.707852489 +0000 UTC m=+98.366394828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7620 (nginx) total-vm:11464kB, anon-rss:1156kB, file-rss:3900kB, shmem-rss:0kB, UID:0 pgtables:60kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.769656    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.716821489 +0000 UTC m=+98.375363828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7656 (nginx) total-vm:11928kB, anon-rss:1572kB, file-rss:616kB, shmem-rss:0kB, UID:101 pgtables:60kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.769848    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.726795489 +0000 UTC m=+98.385337828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7657 (nginx) total-vm:11928kB, anon-rss:1572kB, file-rss:616kB, shmem-rss:0kB, UID:101 pgtables:60kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.770048    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.734436489 +0000 UTC m=+98.392978828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7712 (bash) total-vm:4192kB, anon-rss:520kB, file-rss:44kB, shmem-rss:0kB, UID:0 pgtables:48kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
May 19 18:14:43 aks-np0cas-14924781-vmss000008 node-problem-detector-startup.sh[4208]: I0519 18:14:43.770277    4208 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-05-19 18:14:42.742127489 +0000 UTC m=+98.400669828 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 7788 (bash) total-vm:7169492kB, anon-rss:7165824kB, file-rss:44kB, shmem-rss:0kB, UID:0 pgtables:14076kB oom_score_adj:1000}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-05-19 18:13:04.519479174 +0000 UTC m=+0.178021503 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-05-19 18:13:04.519479274 +0000 UTC m=+0.178021603 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
```

## memory.k8s

```
# Allocatable, Allocated resources - overcommitted, Non-terminated Pods - Memory Requests / Memory Limits
kubectl describe no
Allocatable:
  memory:             5930240Ki
Non-terminated Pods:          (8 in total)
  Namespace                   Name                                   CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                   ------------  ----------  ---------------  -------------  ---
  kube-system                 azure-cns-55g95                        40m (2%)      40m (2%)    250Mi (4%)       250Mi (4%)     129m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  memory             510Mi (8%)  4460Mi (77%)
```
  
## memory.page-cache

```
# After the system starts, it takes just a few minutes for my memory cache to fill up, at which point the system starts using the swap
cat /proc/meminfo
MemTotal:        8129812 kB
MemFree:         5546728 kB
MemAvailable:    6940988 kB
Buffers:           45688 kB
Cached:          1556788 kB
SwapCached:            0 kB

# To determine the true amount of free RAM, excluding cached data
free -m | sed -n -e '3p' | grep -Po "\d+$"
0

# To "clean" the cache and free up memory
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
## Cached:           605812 kB
## SwapCached:            0 kB```
```

- https://docs.kernel.org/admin-guide/mm/concepts.html#page-cache
- https://www.linuxatemyram.com/

## memory.perf.stressng

```
#!/usr/bin/env bash
apt update
apt install stress-ng -y
swapoff -a
for ((i = 0 ; i < 100 ; i++)); do
  stress-ng --vm 1 --vm-bytes 5% -t 1h &> /dev/null &
  sleep 1
done
```

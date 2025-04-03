## process

- https://tldp.org/LDP/tlk/kernel/processes.html

> ## process.task.TaskHung - INFO: task systemd-journal:1729 blocked for more than 180 seconds

```
# If there are no performance issues and the tasks include kernel tasks like systemd-journal, we might need to look into the Linux kernel. If it's just one node, maybe try deleting it. Also, check if the issue happens with an ephemeral OS disk.

# syslog
# Or kubectl describe node # Events
https://access.redhat.com/solutions/6709431
[250396.966263] systemd[1]: systemd-journald.service: State 'stop-sigabrt' timed out. Terminating.
[250418.116445] INFO: task systemd-journal:1729 blocked for more than 180 seconds.
[250418.117922]       Tainted: G        W I      --------- -  - 4.18.0-348.2.1.rt7.132.el8_5.x86_64 #1
[250418.118535] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[250418.119154] task:systemd-journal state:D stack:    0 pid: 1729 ppid:     1 flags:0x00080324
[250418.119157] Call Trace:
[250418.119166]  __schedule+0x34d/0x880
[250418.119171]  ? _raw_spin_lock+0x13/0x40
[250418.119173]  preempt_schedule_lock+0x19/0x40
[250418.119176]  rt_spin_lock_slowlock_locked+0x10e/0x2c0
[250418.119179]  rt_read_lock+0xaf/0xf0
[250418.119186]  do_prlimit+0x14c/0x1e0
[250418.119188]  __x64_sys_prlimit64+0x133/0x270
[250418.119192]  ? syscall_trace_enter+0x144/0x310
```

- https://github.com/openzfs/zfs/discussions/14609: This could be caused by bad sectors on a hard drive. You might want to check the SMART data using smartctl. There are other possible causes, but that one is the most likely. I switched the "storage" to "volatile" in every lxd container.

## process.cli.bash

```
ps -aux
```

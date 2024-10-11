## os-linux-memory.error.OOMKilled

```
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
  
## os-linux-memory.error.OOMKilled.k8s

- https://komodor.com/learn/how-to-fix-oomkilled-exit-code-137/
- add tbd https://mihai-albert.com/2022/02/13/out-of-memory-oom-in-kubernetes-part-2-the-oom-killer-and-application-runtime-implications/

## os-linux-memory.page-cache

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

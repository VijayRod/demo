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

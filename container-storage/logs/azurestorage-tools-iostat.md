```
# w/s represents the IOPS, w_await represents the latency in milliseconds for write requests, and aqu-sz represents the queue depth.
root@aks-nodepool1-88846437-vmss000000:/# iostat -dxctm 1 /dev/sdb | tee -a /tmp/iostat.out
root@aks-nodepool1-88846437-vmss000000:/# cat /tmp/iostat.out
Linux 5.15.0-1041-azure (aks-nodepool1-88846437-vmss000000)     09/25/23        _x86_64_        (4 CPU)
09/24/23 13:00:39
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.75    0.00    2.00    0.25    0.00   96.00
Device            r/s     rMB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wMB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dMB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
sdb              0.00      0.00     0.00   0.00    0.00     0.00 3490.00     13.63     0.00   0.00    4.36     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   15.23  95.60
09/24/23 13:00:40
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00    2.02    0.00    0.00   97.47
Device            r/s     rMB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wMB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dMB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
sdb              0.00      0.00     0.00   0.00    0.00     0.00 3560.00     13.91     0.00   0.00    4.53     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   16.14 101.60
```

- https://www.man7.org/linux/man-pages/man1/iostat.1.html

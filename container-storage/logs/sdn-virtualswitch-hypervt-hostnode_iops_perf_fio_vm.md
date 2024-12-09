```
mkdir /test # Use the OS disk i.e., not on the temporary disk

cat << EOF > /tmp/fiowrite.ini
[global]
size=30g
direct=1
iodepth=256
ioengine=libaio
bs=4k
numjobs=4

[reader1]
rw=randread
directory=/test
EOF

apt-get install fio -y
sudo fio --runtime 30 /tmp/fiowrite.ini
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-benchmarks#fio: Benchmark a disk

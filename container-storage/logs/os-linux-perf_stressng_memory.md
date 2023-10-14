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

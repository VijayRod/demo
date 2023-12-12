```
TBD
# https://tldp.org/HOWTO/html_single/TCP-Keepalive-HOWTO/#libkeepalive
cd /tmp
wget -P /tmp http://prdownloads.sourceforge.net/libkeepalive/libkeepalive-0.3.tar.gz?downloadlibkeepalive-0.3.tar.gz
tar -xzvf /tmp/libkeepalive-0.3.tar.gz?downloadlibkeepalive-0.3.tar.gz
# cat /tmp/libkeepalive-0.3/Makefile
sudo apt update && sudo apt install make -y
make -C /tmp/libkeepalive-0.3/src/ # TBD make: gcc: No such file or directory
LD_PRELOAD=libkeepalive.so KEEPCNT=20 KEEPIDLE=3 KEEPINTVL=3 ./client # Replace with client command # TBD ERROR: ld.so: object 'libkeepalive.so' cannot be preloaded (cannot open shared object file): ignored.
```

- https://libkeepalive.sourceforge.net/#download: Latest version of libkeepalive is...
- https://github.com/msantos/libkeepalive (alternative libkeepalive)

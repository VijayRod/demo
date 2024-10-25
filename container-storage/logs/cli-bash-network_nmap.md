```
apt update -y && apt install nmap -y

nmap -PN nfs7914577893d242738351.blob.core.windows.net -p 2048,111
Starting Nmap 7.80 ( https://nmap.org ) at 2024-10-25 18:29 UTC
Nmap scan report for nfs7914577893d242738351.blob.core.windows.net (20.60.79.4)
Host is up (0.0046s latency).
PORT     STATE SERVICE
111/tcp  open  rpcbind
2048/tcp open  dls-monitor
Nmap done: 1 IP address (1 host up) scanned in 0.39 seconds
```

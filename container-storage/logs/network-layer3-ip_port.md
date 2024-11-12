## ip.port

## ip.port.apps.devtcp

```
echo > /dev/tcp/google.com/80
echo "Test" > /dev/tcp/google.com/80

echo > /dev/tcp/google.com/81
^C-bash: connect: Network is unreachable
-bash: /dev/tcp/google.com/81: Network is unreachable
```

```
# Send the output to port 3333 and view the output with netcat
# Terminal 1
nc -l 3333
# Terminal 2
ls >/dev/tcp/localhost/3333
```

```
while true; echo -e '\n\n\n\n'$(date);  do sleep 1; (echo > /dev/tcp/google.com/443) >/dev/null 2>&1 && echo "up" || echo "down"; done >result.txt # cat result.txt | grep down # Credits: Ricardo
while true; echo -e '\n\n\n\n'$(date);  do sleep 1; (echo > /dev/tcp/8.8.8.8/443) >/dev/null 2>&1 && echo "up" || echo "down"; done # Credits: Ricardo
```

- https://tldp.org/LDP/abs/html/devref1.html#DEVTCP
- https://unix.stackexchange.com/questions/311095/are-dev-udp-tcp-standardized-or-available-everywhere
- https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Redirections: /dev/tcp
- https://andreafortuna.org/2021/03/06/some-useful-tips-about-dev-tcp/
  
## ip.port.apps.nc aka netcat

```
# nc.telnet
nc -v www.microsoft.com 80
Connection to www.microsoft.com 80 port [tcp/http] succeeded!

# nc.listenmode
# Send the output to port 3333 and view the output with netcat
# Terminal 1
nc -l 3333
# Terminal 2
ls >/dev/tcp/localhost/3333
```

- https://www.unixfu.ch/use-netcat-instead-of-telnet/: telnet is history

## ip.port.apps.netstat

```
apt update -y && apt install net-tools -y
netstat -antpl
```

## ip.port.apps.nmap

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

## ip.port.apps.ss

```
ss -anlp # apt-get update && apt-get install iproute2 -y
```

## ip.port.debug

```
# See the sections about azureblob and azurefile CSI debug

nc -zvvw2 8.8.8.8 53 # Connection to 8.8.8.8 53 port [tcp/domain] succeeded!
nc -zvvw2 dns.google.com 53 # Connection to dns.google.com (8.8.8.8) 53 port [tcp/domain] succeeded!

netstat -anp | grep port # to find out which ports services are listening on
netstat -antpl | grep port

lsof -p 2741 # the PID comes from the netstat command. Lists open files, including those opened by processes, directories, users, ports, and protocols

tbd find grep # https://stackoverflow.com/questions/16956810/find-all-files-containing-a-specific-text-string-on-linux

# nc -v nfs7914577893d242738351.blob.core.windows.net 2048
# telnet nfs7914577893d242738351.blob.core.windows.net 2048
tcpdump host 20.60.79.4 # nfs7914577893d242738351.blob.core.windows.net
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:54:27.373036 IP aks-nodepool1-13337413-vmss000000.internal.cloudapp.net.52090 > 20.60.79.4.2048: Flags [S], seq 138131897, win 64240, options [mss 1460,sackOK,TS val 2963820743 ecr 0,nop,wscale 7], length 0
19:54:27.374209 IP 20.60.79.4.2048 > aks-nodepool1-13337413-vmss000000.internal.cloudapp.net.52090: Flags [S.], seq 3829096321, ack 138131898, win 65535, options [mss 1440,nop,wscale 8,sackOK,TS val 3907516489 ecr 2963820743], length 0
19:54:27.374227 IP aks-nodepool1-13337413-vmss000000.internal.cloudapp.net.52090 > 20.60.79.4.2048: Flags [.], ack 1, win 502, options [nop,nop,TS val 2963820745 ecr 3907516489], length 0
```

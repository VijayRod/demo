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
# Keep tcpping or psping, whichever they prefer, running to the destination. Please ask them to leave running continuously. We need tcp ping on the specific port
# please take the output of psping as well. please use the Azure VM, instead of on-premise system, since it'll make troubleshooting a lot easier due to fewer intermediate network devices.

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
nc -v google.com 443 -w 1 # exits or times out in a sec
Connection to google.com (142.250.178.14) 443 port [tcp/https] succeeded!
nc -v google1.com 443 -w 1
nc: getaddrinfo for host "google1.com" port 443: Name or service not known
nc -v www.microsoft.com 80 # Ctrl+C to exit
Connection to www.microsoft.com 80 port [tcp/http] succeeded!

# nc.listenmode
# Send the output to port 3333 and view the output with netcat
# Terminal 1
nc -l 3333
# Terminal 2
ls >/dev/tcp/localhost/3333
```

- https://www.unixfu.ch/use-netcat-instead-of-telnet/: telnet is history

```
# between pods on different nodes
# run one to listen on
kubectl run nc1 --image=nicolaka/netshoot -it --rm --overrides='{"spec": {"nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-39736488-vmss00000a"}}}' -- nc -k -l 8080
# get ip
NC1IP=$(kubectl get pod nc1 -o jsonpath='{.status.podIP}')
echo $NC1IP
# run one to query from
kubectl run nc2 --image=nicolaka/netshoot -it --rm   --overrides='{"spec": {"nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-39736488-vmss00000b"}}}' -- sh
# run timings on it
export NC1IP=<ipfromabove>
while true; do
    date
    time nc -zv $NC1IP 8080
    sleep 0.5
done
```

```
# between nodes
kubectl get no -owide

kubectl node-shell aks-nodepool1-39736488-vmss000002
root@aks-nodepool1-39736488-vmss000002:/# nc -k -l 8080

kubectl node-shell aks-nodepool1-39736488-vmss000003
root@aks-nodepool1-39736488-vmss000003:/# export NC1IP=10.224.0.4
root@aks-nodepool1-39736488-vmss000003:/# while true; do
    date
    time nc -zv $NC1IP 8080
    sleep 0.5
done
Thu Jan  9 18:31:19 UTC 2025
Connection to 10.224.0.4 8080 port [tcp/http-alt] succeeded!
real    0m0.003s
user    0m0.002s
sys     0m0.000s
```

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

## ip.port.apps.psping

```
# This one's for Windows OS
```

## ip.port.apps.ss

```
ss -anlp # apt-get update && apt-get install iproute2 -y
```

## ip.port.apps.tcpping

- https://github.com/deajan/tcpping
- http://www.vdberg.org/~richard/: The script is called tcpping, the current version is 2.0 and is now being maintained on github by Orsiris de Jong
- http://www.vdberg.org/~richard/tcpping

## ip.port.apps.tcpspray

- https://manpages.org/tcpspray

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

```
# tcpdump while executing the mount command from the node until the mount failure is encountered (start tcpdump, execute the mount command and wait for the failure, then stop tcpdump).

tcpdump
tcpdump -w - # to write binary data to stdout
tcpdump -w /tmp/tcpdump/capture
tcpdump --list-interfaces # ip a # tcpdump -i eth0 # tcpdump -i any
tcpdump -i lo # captures packets on the loopback interface
tcpdump – version
man tcpdump

curl ifconfig.me # ip a

apt update -y && apt install tcpdump -y && tcpdump host redis3696.redis.cache.windows.net
```

- https://www.tcpdump.org/
- https://www.tcpdump.org/manpages/tcpdump.1.html
- https://man.archlinux.org/man/tcpdump.1
- https://danielmiessler.com/p/tcpdump
- https://wiki.archlinux.org/title/Network_Debugging: Tcpdump
- https://wizardzines.com/zines/tcpdump/
- https://superuser.com/questions/925286/does-tcpdump-bypass-iptables: tcpdump is the first software found after the wire (and the NIC, if you will) on the way IN, and the last one on the way OUT....
<br>

- Frequently Asked Questions
  - tbd https://linuxconfig.org/how-to-use-tcpdump-command-on-linux
  - https://superuser.com/questions/1455476/what-does-tcp-packet-p-flag-means-in-tcpdumps-output
  - https://stackoverflow.com/questions/25603831/how-can-i-have-tcpdump-write-to-file-and-standard-output-the-appropriate-data
  - https://superuser.com/questions/273489/how-do-i-make-tcpdump-to-write-to-file-for-each-packet-it-captures
  - https://stackoverflow.com/questions/19808483/tcpdump-resolve-ip-and-skip-resolving-ports
<br>

```
kubectl debug node/aks-nodepool1-14217322-vmss000000 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
# chroot /host
root@aks-nodepool1-14217322-vmss000000:/# tcpdump 1.2.3.4
kubectl cp <debugger podname>:/host/tmp/tcpdump-keda-law.pcap /tmp/tcpdump/tcpdump-keda-law-aks-nodepool1-14217322-vmss000000.pcap

kubectl get po --show-labels
node-debugger-aks-nodepool1-14217322-vmss000000-n6rvn   1/1     Running   0          2m44s   <none>
```
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks

```
kubectl krew install dumpy

kubectl dumpy get
kubectl dumpy capture pod nginx
# kubectl dumpy capture deploy keda-operator -n kube-system
# kubectl dumpy capture node worker-node
# kubectl dumpy capture node all

# kubectl dumpy get dumpy-43945520
kubectl dumpy export dumpy-43945520 /tmp/tcpdump
# kubectl dumpy stop dumpy-43945520
kubectl dumpy delete dumpy-43945520 # Or k delete po --all # pod "sniffer-dumpy-59308185-2320" deleted
ls /tmp/tcpdump/dumpy*


kubectl dumpy capture pod nginx
Getting target resource info..
Dumpy init
Capture name: dumpy-43945520
  PodName: nginx
  ContainerName: nginx
  ContainerID: 9345aa4378e597e1140ab219fb3e9c353d2b143e66db0d5f5da66ea338f2537b
  NodeName: aks-nodepool1-12914153-vmss000000
sniffer-dumpy-43945520-6041 started sniffing
All dumpy sniffers are Ready.

kubectl dumpy get
NAME            NAMESPACE  TARGET     TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------  ------     ---------------  --------------  --------
dumpy-43945520  default    pod/nginx  default          -i any          1/1

kubectl dumpy get dumpy-43945520
Getting capture details..
name: dumpy-43945520
namespace: default
tcpdumpfilters: -i any
image: larrytheslap/dumpy:0.2.0
targetSpec:
    name: nginx
    namespace: default
    type: pod
    container: nginx
    items:
        nginx  <-----  sniffer-dumpy-43945520-6041 [Running]
pvc:
pullsecret:

kubectl dumpy export dumpy-43945520 /tmp/tcpdump
Downloading capture dumps from sniffers:
  nginx ---> path /tmp/tcpdump/dumpy-43945520-nginx.pcap
  
kubectl dumpy stop dumpy-43945520
Stopping capture dumpy-43945520..
sniffer-dumpy-43945520-6041 stopped
dumpy-43945520 sniffers have been successfully stopped

kubectl dumpy delete -n kube-system dumpy-43945520
deleting sniffer-dumpy-43945520-6041
dumpy capture dumpy-43945520 successfully deleted


ls /tmp/tcpdump/dumpy*
/tmp/tcpdump/dumpy-43945520-nginx.pcap

kubectl get po -A | grep snif
default       sniffer-dumpy-43945520-6041          0/1     Completed   0          7m3s # Else this indicates it's in a Running state if it is still capturing

kubectl dumpy get
NAME            NAMESPACE  TARGET     TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------  ------     ---------------  --------------  --------
dumpy-43945520  default    pod/nginx  default          -i any          0/1


kubectl dumpy capture deploy keda-operator -n kube-system
Getting target resource info..
Dumpy init
Capture name: dumpy-09671733
  PodName: keda-operator-5c76fdd585-94pmg
  ContainerName: keda-operator
  ContainerID: 0c86a8bfd850b92aed8ca4990f5b70a8e348c7e0a2d077da7d7562abb716f801
  NodeName: aks-nodepool1-10714812-vmss000000
  PodName: keda-operator-5c76fdd585-6tmzs
  ContainerName: keda-operator
  ContainerID: 0e5c11efcd5e8d270ff3090fe99217c253663d6e4e0f64a41aedd739d3b8bb67
  NodeName: aks-nodepool1-10714812-vmss000000
sniffer-dumpy-09671733-1817 started sniffing
sniffer-dumpy-09671733-1302 started sniffing
All dumpy sniffers are Ready.

kubectl dumpy get -n kube-system
NAME            NAMESPACE    TARGET                    TARGETNAMESPACE  TCPDUMPFILTERS  SNIFFERS
----            ---------    ------                    ---------------  --------------  --------
dumpy-09671733  kube-system  deployment/keda-operator  kube-system      -i any          2/2

kubectl dumpy get -n kube-system dumpy-09671733
Getting capture details..
name: dumpy-09671733
namespace: kube-system
tcpdumpfilters: -i any
image: larrytheslap/dumpy:0.2.0
targetSpec:
    name: keda-operator
    namespace: kube-system
    type: deployment
    container: keda-operator
    items:
        keda-operator-5c76fdd585-94pmg  <-----  sniffer-dumpy-09671733-1302 [Running]
        keda-operator-5c76fdd585-6tmzs  <-----  sniffer-dumpy-09671733-1817 [Running]
pvc:
pullsecret:

kubectl dumpy export -n kube-system dumpy-09671733 /tmp/tcpdump
Downloading capture dumps from sniffers:
  keda-operator-5c76fdd585-94pmg ---> path /tmp/tcpdump/dumpy-09671733-keda-operator-5c76fdd585-94pmg.pcap
  keda-operator-5c76fdd585-6tmzs ---> path /tmp/tcpdump/dumpy-09671733-keda-operator-5c76fdd585-6tmzs.pcap

kubectl dumpy stop -n kube-system dumpy-09671733
Stopping capture dumpy-09671733..
sniffer-dumpy-09671733-1302 stopped
sniffer-dumpy-09671733-1817 stopped
dumpy-09671733 sniffers have been successfully stopped

kubectl dumpy delete -n kube-system dumpy-09671733
deleting sniffer-dumpy-09671733-1302
deleting sniffer-dumpy-09671733-1817
dumpy capture dumpy-09671733 successfully deleted
```

- https://github.com/larryTheSlap/dumpy
<br>

- capture filters

```
tcpdump host 1.1.1.1 # Source or destination
tcpdump host fqdn
tcpdump port 443
tcpdump host $(nslookup api.loganalytics.io | awk '/^Address: / {print $2}') -w /tmp/tcpdump-keda-law.pcap # Execute TCPDump with a filter targetting the LAW endpoint and let it run until the issue occurs again

# Use tcpdump to exclude traffic from specific IP addresses
tcpdump 'not net 168.63.129.16' # Alternatively, you can use tcpdump 'not net 168.63.129.16/32' or tcpdump '! net 168.63.129.16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254'
tcpdump 'host 10.224.0.69 and not net 168.63.129.16 and not net 10.255.0.0/16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254 and not port 10250 and not net 13.87.229.75' # aks fqdn
```

- https://wiki.wireshark.org/CaptureFilters
- https://www.tcpdump.org/manpages/pcap-filter.7.html
- https://blog.wains.be/2007/2007-10-01-tcpdump-advanced-filters/
<br>

- http

```
tcpdump tcp port http # tcpdump port 80 # tcpdump port http
tcpdump tcp dst port 80 # tcpdump 'tcp dst port 80'
tcpdump tcp dst port 80 -A # Displays the HTTP request/response in ASCII format.
tcpdump -A -vvv host 169.254.169.254
tcpdump 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)' # print only (http) packets that contain data
```

```
curl google.com
tcpdump 'tcp dst port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420' # Here 0x47455420 depicts the ASCII value of  characters  'G' 'E' 'T' ' '
# tcpdump -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'
# tcpdump -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 and not net 168.63.129.16 and not net 169.254.169.254 and not port 10250'
23:02:09.004064 IP 1.2.3.4.49878 > mad07s25-in-f14.1e100.net.http: Flags [P.], seq 3472752388:3472752462, ack 1346174452, win 502, options [nop,nop,TS val 89192113 ecr 1101230501], length 74: HTTP: GET / HTTP/1.1

curl google.com
tcpdump 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450' # 0x48545450 represents the ASCII value of 'H' 'T' 'T' 'P' this is to capture the HTTP response
23:00:21.662418 IP mad41s11-in-f14.1e100.net.http > 1.2.3.4.42180: Flags [P.], seq 1942071783:1942072556, ack 3228441095, win 256, options [nop,nop,TS val 1187180250 ecr 1887773435], length 773: HTTP: HTTP/1.1 301 Moved Permanently

curl google.com
tcpdump 'tcp dst port 80 or tcp dst port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420 or tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450'
23:09:02.975303 IP 1.2.3.4.36630 > mad41s13-in-f14.1e100.net.http: Flags [P.], seq 2710103797:2710103871, ack 980434831, win 502, options [nop,nop,TS val 574057378 ecr 3641890559], length 74: HTTP: GET / HTTP/1.1
23:09:03.018202 IP mad41s13-in-f14.1e100.net.http > 1.2.3.4.36630: Flags [P.], seq 1:774, ack 74, win 256, options [nop,nop,TS val 3641890603 ecr 574057378], length 773: HTTP: HTTP/1.1 301 Moved Permanently

curl google.com -I
tcpdump 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48454144' # HEAD
23:44:18.889621 IP 1.2.3.4.45238 > mad07s23-in-f14.1e100.net.http: Flags [P.], seq 3735714866:3735714941, ack 774239603, win 502, options [nop,nop,TS val 214544517 ecr 1619348354], length 75: HTTP: HEAD / HTTP/1.1
```

- https://security.stackexchange.com/questions/121011/wireshark-tcp-filter-tcptcp121-0xf0-24
- https://onlinetools.com/hex/convert-hex-to-ascii?input=0x47455420 # GET 
- https://onlinetools.com/hex/convert-ascii-to-hex?input=GET  # 47455420. Remember to deselect 'Add 0x Hex Prefix' and 'Add Extra Spacing'. Also, don't forget to manually add a space after typing GET to match the 4 bytes requirement.
- tbd https://www.rapidtables.com/code/text/ascii-table.html
- tbd https://www.middlewareinventory.com/blog/tcpdump-capture-http-get-post-requests-apache-weblogic-websphere/
- https://stackoverflow.com/questions/9241391/how-to-capture-all-the-http-packets-using-tcpdump
- https://stackoverflow.com/questions/39012132/how-to-capture-only-http-with-tcpdump-with-linux
<br>

- https

```
tcpdump tcp port https

```

- ip

```
tcpdump ip
```

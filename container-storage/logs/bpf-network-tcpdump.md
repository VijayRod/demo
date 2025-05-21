## tcpdump

```
# tcpdump while executing the mount command from the node until the mount failure is encountered (start tcpdump, execute the mount command and wait for the failure, then stop tcpdump).

tcpdump
tcpdump -w - # to write binary data to stdout
tcpdump -w /tmp/tcpdump/capture
tcpdump --list-interfaces # ip a # tcpdump -i eth0 # tcpdump -i any
tcpdump -i lo # captures packets on the loopback interface
tcpdump -i any # tcpdump --list-interfaces: any (Pseudo-device that captures on all interfaces)
tcpdump – version
man tcpdump

curl ifconfig.me # ip a

apt update -y && apt install tcpdump -y && tcpdump host redis3696.redis.cache.windows.net
```

- https://www.tcpdump.org/
- https://www.tcpdump.org/manpages/tcpdump.1.html
- https://man.archlinux.org/man/tcpdump.1
- https://danielmiessler.com/p/tcpdump: tutorial
- https://danielmiessler.com/p/tcpflags/: tutorial
- https://hackertarget.com/tcpdump-examples/
- https://wiki.archlinux.org/title/Network_Debugging: Tcpdump
- https://wizardzines.com/zines/tcpdump/: tutorial
- https://superuser.com/questions/925286/does-tcpdump-bypass-iptables: tcpdump is the first software found after the wire (and the NIC, if you will) on the way IN, and the last one on the way OUT....

```
# single command tcpdump

timeout 5 tcpdump port 443 &
curl https://example.com
wait

tcpdump port 443 &
TCPDUMP_PID=$!
curl https://example.com
sleep 2
kill $TCPDUMP_PID

tcpdump &
TCPDUMP_PID=$!
curl https://coredns.io
sleep 2
kill $TCPDUMP_PID
```

## tcpdump.capture.export.etl.pcapng

```
# For packet capture conversion from Etl to WireShark's pcapng, use etl2pcapng (preferred). 
## If that doesn't work, try pktmon, or netsh (which converts to txt and should be used if the others don't work).

# The UI tools for analyzing ETL are Message Analyzer (deprecated) and NetMon (deprecated).
```

## tcpdump.capture.export.etl.pcapng.etl2pcapng

```
# Download the exe and run the command in the same folder. The output file will have the same name and be in the same folder by default.
etl2pcapng.exe trace.etl
IF: medium=eth                  ID=0    IfIndex=10      VlanID=0
Wrote 38698 frames to trace.pcapng
```

- https://github.com/microsoft/etl2pcapng

## tcpdump.capture.export.etl.pcapng.netsh

```
netsh trace convert input=trace.etl # converts to txt
```

## tcpdump.capture.filter

```
tcpdump host 1.1.1.1 # Source or destination
tcpdump host fqdn
tcpdump port 443
tcpdump port 80 -w /tmp/capture_file
tcpdump host $(nslookup api.loganalytics.io | awk '/^Address: / {print $2}') -w /tmp/tcpdump-keda-law.pcap # Execute TCPDump with a filter targetting the LAW endpoint and let it run until the issue occurs again

# Use tcpdump to exclude traffic from specific IP addresses
tcpdump 'not net 168.63.129.16' # Alternatively, you can use tcpdump 'not net 168.63.129.16/32' or tcpdump '! net 168.63.129.16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254'
tcpdump 'host 10.224.0.69 and not net 168.63.129.16 and not net 10.255.0.0/16'
tcpdump 'not net 168.63.129.16 and not net 169.254.169.254 and not port 10250 and not net 13.87.229.75' # aks fqdn

# wireshark
ip.addr!=169.254.169.254 && ip.addr!=168.63.129.16
```

- https://wiki.wireshark.org/CaptureFilters
- https://www.tcpdump.org/manpages/pcap-filter.7.html
- https://blog.wains.be/2007/2007-10-01-tcpdump-advanced-filters/
- https://gist.github.com/tuxfight3r/9ac030cb0d707bb446c7

```
# multiple ports
tcpdump port 80 or port 3128
tcpdump port '(80 or 443)'
tcpdump -an portrange 1-25
tcpdump -i eth0 port 80 or port 8080
tcpdump -i any 'udp port 1812 or tcp port 1813'
```

- https://stackoverflow.com/questions/2187932/monitoring-multiple-ports-in-tcpdump

## tcpdump.capture.filter.http

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

## tcpdump.capture.filter.https

```
# Refer to https

tcpdump tcp port https

```

- tbd https://www.netnea.com/cms/2022/01/20/decrypt-tls-encrypted-http-traffic-for-debugging/

## tcpdump.capture.filter.ip

```
tcpdump ip
```

## tcpdump.capture.tools.k8s

```

```

## tcpdump.capture.tools.k8s.dumpy

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

## tcpdump.capture.tools.k8s.kubectldebug

```
kubectl -n myns debug -i nginx-9456bbbf9-97gjc --image=nicolaka/netshoot –-target=nginx -- tcpdump -i eth0 -w - | wireshark -k -i -
```

- https://stackoverflow.com/questions/72388304/how-to-find-all-the-outgoing-network-traffic-from-a-pod-in-k8s

## tcpdump.capture.tools.k8s.kubeshark

```
# brew install kubeshark
kubeshark tap
# Browser: http://127.0.0.1:8899/
```

- https://docs.kubeshark.co/en/introduction: Think Wireshark re-invented for Kubernetes (K8s). 
  - Using extended BPF (eBPF), Kubeshark traces function calls in both the kernel and user spaces.
  - Kubeshark can sniff the encrypted traffic (TLS) in your cluster without actually performing decryption.
- https://www.kubeshark.co/
- https://github.com/kubeshark/kubeshark

## tcpdump.capture.tools.k8s.sniff

```
kubectl sniff nginx-azurefile -f "port 80" # tbd Error: exec: "wireshark": executable file not found in $PATH
```

- https://github.com/eldadru/ksniff: ksniff use kubectl to upload a statically compiled tcpdump binary to your pod and redirecting it's output to your local Wireshark for smooth network debugging experience.
- https://stackoverflow.com/questions/72388304/how-to-find-all-the-outgoing-network-traffic-from-a-pod-in-k8s

## tcpdump.capture.tools.iperf

```
# install

sudo apt update -y && apt install -y iperf3
iperf3 --version
```

- https://software.es.net/iperf/
- https://github.com/esnet/iperf

```
# install2

kubectl debug node/aks-nodepool1-xxxxxx-vmss000001 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
apt-get update && apt-get install iperf3 -y
apt-get update && apt-get install net-tools jq -y

VM1: 
iperf3 -s -p 20003
# nohup iperf3 --server --port 20003 &> /dev/null &

VM2: 
for p in $(seq 1 5);
do
    iperf3 -c 10.224.0.4 -p 20003 -V -t 100 -i 0 -P $p
    sleep 10
done
```

```
# Ideally, we need two VMs that can run iperf, although both the server and the client can be on the same machine.

On VM1, run: iperf3 -s # this starts the server to listen for client connections
On VM2, run: iperf3 -c 10.224.0.5 # this connects the client to the server

root@aks-nodepool1-24567707-vmss000002:/# iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.224.0.4, port 50654
[  5] local 10.224.0.5 port 5201 connected to 10.224.0.4 port 50656
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   128 MBytes  1.07 Gbits/sec
[  5]   1.00-2.00   sec   113 MBytes   950 Mbits/sec
[  5]   2.00-3.00   sec   113 MBytes   952 Mbits/sec
[  5]   3.00-4.00   sec   113 MBytes   951 Mbits/sec
[  5]   4.00-5.00   sec   114 MBytes   953 Mbits/sec
[  5]   5.00-6.00   sec   113 MBytes   951 Mbits/sec
[  5]   6.00-7.00   sec   114 MBytes   954 Mbits/sec
[  5]   7.00-8.00   sec   113 MBytes   951 Mbits/sec
[  5]   8.00-9.00   sec   114 MBytes   954 Mbits/sec
[  5]   9.00-10.00  sec   113 MBytes   952 Mbits/sec
[  5]  10.00-10.04  sec  4.42 MBytes   905 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.04  sec  1.13 GBytes   964 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------

root@aks-nodepool1-24567707-vmss000003:/# iperf3 -c 10.224.0.5
Connecting to host 10.224.0.5, port 5201
[  5] local 10.224.0.4 port 50656 connected to 10.224.0.5 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   136 MBytes  1.14 Gbits/sec    0   2.34 MBytes
[  5]   1.00-2.00   sec   112 MBytes   944 Mbits/sec    0   2.34 MBytes
[  5]   2.00-3.00   sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
[  5]   3.00-4.00   sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
[  5]   4.00-5.00   sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
[  5]   5.00-6.00   sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
[  5]   6.00-7.00   sec   112 MBytes   944 Mbits/sec    0   2.34 MBytes
[  5]   7.00-8.00   sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
[  5]   8.00-9.00   sec   112 MBytes   944 Mbits/sec    0   2.34 MBytes
[  5]   9.00-10.00  sec   114 MBytes   954 Mbits/sec    0   2.34 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  1.13 GBytes   969 Mbits/sec    0             sender
[  5]   0.00-10.04  sec  1.13 GBytes   964 Mbits/sec                  receiver

iperf Done.
```

- https://lindevs.com/install-iperf-on-ubuntu/
- https://fasterdata.es.net/performance-testing/network-troubleshooting-tools/iperf/: can find sample commands

```
VM1: iperf3 -s -p 12555
VM2: iperf3 -c 10.224.0.4 -p 12555 -i 1 -V -t 100

  -i, --interval  #         seconds between periodic throughput reports
  -V, --verbose             more detailed output
  -t, --time      #         time in seconds to transmit for (default 10 secs)
  -P, --parallel  #         number of parallel client streams to run # include the flag -P 1 (reducing from the default 50 flows to just 1 flow) to see if it changes the behavior

# on the server (VM1) side, run the following command and check the output file to see if the missed packet counts are increasing.
for count in {1..1000} ; do  (echo `date +"%Y-%m-%d %H:%M:%S"` >> phy_interface_stats.txt ; ip -s link show `ip link | awk -F: '/^[0-9]+: / {print $2}' | egrep enP` | egrep -A 1 '(RX|TX)' >> phy_interface_stats.txt; sleep 1); done
# output sample:
--
    RX:  bytes packets errors dropped  missed   mcast
       2125397    4771      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
      13811532    3342      0       0       0       0
--
    RX:  bytes packets errors dropped  missed   mcast
       1097790    3052      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
       3839047    3262      0       0       0       0
```

## tcpdump.capture.tools.wireshark.tshark
```
root@aks-nodepool1-14724824-vmss000001:/# apt update -y && apt install tshark -y
# root@aks-nodepool1-14724824-vmss000001:/# apt update -y && apt install wireshark -y

tshark --version
tshark
```
- https://tshark.dev/setup/install/
- https://tshark.dev/setup/about/: tshark (Terminal wireSHARK) is the command line tool (CLI) that has most, but not all, of the features of Wireshark.

## tcpdump.capture.tools.windows.pktmon

```
# admin: cmd

ipconfig /all
pktmon component list

sc qc pktmon
[SC] QueryServiceConfig SUCCESS
SERVICE_NAME: pktmon
        TYPE               : 1  KERNEL_DRIVER
        START_TYPE         : 3   DEMAND_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : system32\drivers\PktMon.sys
        LOAD_ORDER_GROUP   :
        TAG                : 0
        DISPLAY_NAME       : Packet Monitor Driver
        DEPENDENCIES       :
        SERVICE_START_NAME :
```

```
# capture
# admin: cmd
pktmon filter remove
pktmon filter add myprotocol -t ICMP
pktmon filter add myIPFilter -i 127.0.0.1
pktmon start -c -f .\pktmon.etl
# pktmon counters

ping 8.8.8.8
ping 127.0.0.1

pktmon stop
pktmon etl2pcap pktmon.etl # pktmon.pcapng (wireshark)

# wireshark: icmp
1	2024-11-20 22:13:44.429602	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
2	2024-11-20 22:13:44.429619	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
3	2024-11-20 22:13:44.429624	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
4	2024-11-20 22:13:44.429626	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
```

- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/pktmon
- https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon: The tool is especially helpful in virtualization scenarios, like container networking and SDN, because it provides visibility within the networking stack

## tcpdump.debug

```
# error.socket hang up
# error: Error: socket hang up

Do they have a keepalive mechanism in their app?
How are they handling exceptions?
Do they retry the request if it fails?
Do we have a more detailed call stack from that node.js app? Just curious, but we won't be supporting it anyway...
```

- https://github.com/nodejs/node/blob/main/lib/_http_client.js: nodejs. emitErrorEvent(req, new ConnResetException('socket hang up'));

```
# rst.Challenge-ACK
```

- https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000boBJCAY: Firewall dropping RST from Client after Server's Challenge-ACK. While dropping the out of window RST (in the Palo Alto firewall) is actually an intended behavior, it breaks the Challenge-ACK mechanism.
- https://datatracker.ietf.org/doc/html/rfc5961#section-4: the handling of the SYN in the synchronized state SHOULD be performed as follows: 1) If the SYN bit is set, irrespective of the sequence number, TCP MUST send an ACK (also referred to as challenge ACK) to the remote peer
- https://www.networkdefenseblog.com/post/wireshark-tcp-challenge-ack
  
## tcpdump.debug.faqs

- Frequently Asked Questions
  - tbd https://linuxconfig.org/how-to-use-tcpdump-command-on-linux
  - https://superuser.com/questions/1455476/what-does-tcp-packet-p-flag-means-in-tcpdumps-output
  - https://stackoverflow.com/questions/25603831/how-can-i-have-tcpdump-write-to-file-and-standard-output-the-appropriate-data
  - https://superuser.com/questions/273489/how-do-i-make-tcpdump-to-write-to-file-for-each-packet-it-captures
  - https://stackoverflow.com/questions/19808483/tcpdump-resolve-ip-and-skip-resolving-ports

```
fqdn=aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io

nc -vz $fqdn 443
Connection to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io 443 port [tcp/https] succeeded!

telnet $fqdn 443
Trying 4.225.35.13...
Connected to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io.
Escape character is '^]'.

curl https://$fqdn -k
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}

tcpdump host 4.225.35.13 # curl https://$fqdn -k
tcpdump port 443
19:35:19.532786 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [S], seq 1260532285, win 64240, options [mss 1460,sackOK,TS val 3053044232 ecr 0,nop,wscale 7], length 0
19:35:19.595717 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [S.], seq 3282737313, ack 1260532286, win 65160, options [mss 1412,sackOK,TS val 2200849497 ecr 3053044232,nop,wscale 7], length 0
19:35:19.595774 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [.], ack 1, win 502, options [nop,nop,TS val 3053044295 ecr 2200849497], length 0
19:35:19.602266 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 1:518, ack 1, win 502, options [nop,nop,TS val 3053044301 ecr 2200849497], length 517
19:35:19.666022 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 518, win 506, options [nop,nop,TS val 2200849568 ecr 3053044301], length 0
19:35:19.688419 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 1:2458, ack 518, win 506, options [nop,nop,TS val 2200849589 ecr 3053044301], length 2457
19:35:19.688441 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [.], ack 2458, win 498, options [nop,nop,TS val 3053044387 ecr 2200849589], length 0
19:35:19.689361 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 518:612, ack 2458, win 501, options [nop,nop,TS val 3053044388 ecr 2200849589], length 94
19:35:19.689439 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 612:707, ack 2458, win 501, options [nop,nop,TS val 3053044388 ecr 2200849589], length 95
19:35:19.689845 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 707:829, ack 2458, win 501, options [nop,nop,TS val 3053044389 ecr 2200849589], length 122
19:35:19.762583 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 612, win 506, options [nop,nop,TS val 2200849653 ecr 3053044388], length 0
19:35:19.762584 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2458:2610, ack 612, win 506, options [nop,nop,TS val 2200849654 ecr 3053044388], length 152
19:35:19.762585 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2610:2671, ack 612, win 506, options [nop,nop,TS val 2200849654 ecr 3053044388], length 61
19:35:19.762586 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 707, win 506, options [nop,nop,TS val 2200849654 ecr 3053044388], length 0
19:35:19.762586 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 829, win 506, options [nop,nop,TS val 2200849654 ecr 3053044389], length 0
19:35:19.762587 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2671:2706, ack 829, win 506, options [nop,nop,TS val 2200849654 ecr 3053044389], length 35
19:35:19.762587 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2706:2737, ack 829, win 506, options [nop,nop,TS val 2200849654 ecr 3053044389], length 31
19:35:19.762587 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2737:2902, ack 829, win 506, options [nop,nop,TS val 2200849655 ecr 3053044389], length 165
19:35:19.762664 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 2902:3090, ack 829, win 506, options [nop,nop,TS val 2200849655 ecr 3053044389], length 188
19:35:19.762874 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 829:860, ack 3090, win 501, options [nop,nop,TS val 3053044462 ecr 2200849654], length 31
19:35:19.763513 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [P.], seq 860:884, ack 3090, win 501, options [nop,nop,TS val 3053044462 ecr 2200849654], length 24
19:35:19.763541 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [F.], seq 884, ack 3090, win 501, options [nop,nop,TS val 3053044462 ecr 2200849654], length 0
19:35:19.826987 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 860, win 506, options [nop,nop,TS val 2200849727 ecr 3053044462], length 0
19:35:19.826990 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 884, win 506, options [nop,nop,TS val 2200849728 ecr 3053044462], length 0
19:35:19.832967 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [P.], seq 3090:3114, ack 884, win 506, options [nop,nop,TS val 2200849728 ecr 3053044462], length 24
19:35:19.832970 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [F.], seq 3114, ack 884, win 506, options [nop,nop,TS val 2200849728 ecr 3053044462], length 0
19:35:19.832972 IP 4.225.35.13.https > 172.30.58.38.52630: Flags [.], ack 885, win 506, options [nop,nop,TS val 2200849728 ecr 3053044462], length 0
19:35:19.833040 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [R], seq 1260533169, win 0, length 0
19:35:19.833062 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [R], seq 1260533169, win 0, length 0
19:35:19.833067 IP 172.30.58.38.52630 > 4.225.35.13.https: Flags [R], seq 1260533170, win 0, length 0
```

```
kubectl debug -it --image=busybox -n kube-system metrics-server-5bd48455f4-dn8tf
/ # nc -vz $fqdn 443
aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io (4.225.35.13:443) open
/ # telnet $fqdn 443
Connected to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io
^C
Console escape. Commands are:
 l      go to line mode
 c      go to character mode
 z      suspend telnet
 e      exit telnet
e
```

- https://blog.cloudtrooper.net/2019/01/23/a-day-in-the-life-of-a-packet-in-aks-part-2-kubenet-and-ingress-controller/: NAT aka masquerading, ...

```
# kubenet (cni), external ingress to a pod without an ingress class/controller

kubectl delete po nginx
kubectl delete svc nginx
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --type=LoadBalancer

kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
nginx        LoadBalancer   10.0.192.18   20.240.25.37   80:31148/TCP   16s

# kubectl get ep
NAME         ENDPOINTS         AGE
nginx        10.244.0.33:80    5m22s
# kubectl describe svc
IP:                       10.0.192.18
IPs:                      10.0.192.18
LoadBalancer Ingress:     20.240.25.37 (VIP)
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31148/TCP
Endpoints:                10.244.0.33:80
Session Affinity:         None
External Traffic Policy:  Cluster
# kubectl get po -owide
NAME             READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
nginx            1/1     Running   0          72m   10.244.0.33   aks-nodepool1-33086427-vmss000001   <none>           <none>
# kubectl get no -owide
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-33086427-vmss000001   Ready    <none>   61m   v1.30.6   10.224.0.5    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
lb=kubernetes
az network lb frontend-ip list -g $noderg --lb-name $lb -o table
Name                                  PrivateIPAllocationMethod    ProvisioningState    ResourceGroup
------------------------------------  ---------------------------  -------------------  -----------------------
77d48a65-578b-46d1-9425-8e099370353a  Dynamic                      Succeeded            mc_rg_aks_swedencentral
af1bcd8bddd304b098c13de27b0f922b      Dynamic                      Succeeded            mc_rg_aks_swedencentral

pipid=$(az network lb frontend-ip show -g $noderg --lb-name $lb -n af1bcd8bddd304b098c13de27b0f922b --query publicIPAddress.id -o tsv)
az network public-ip show --id $pipid --query ipAddress -o tsv
20.240.25.37

az network lb rule list -g $noderg --lb-name $lb -o table # port 80, tcp (not http)
BackendPort    DisableOutboundSnat    EnableFloatingIP    EnableTcpReset    FrontendPort    IdleTimeoutInMinutes    LoadDistribution    Name                                     Protocol    ProvisioningState    ResourceGroup
-------------  ---------------------  ------------------  ----------------  --------------  ----------------------  ------------------  ---------------------------------------  ----------  -------------------  -----------------------
80             True                   True                True              80              4			    Default             af1bcd8bddd304b098c13de27b0f922b-TCP-80  Tcp         Succeeded            mc_rg_aks_swedencentral

az network lb probe list -g $noderg --lb-name $lb -o table
IntervalInSeconds    Name                                     NumberOfProbes    Port    ProbeThreshold    Protocol    ProvisioningState    ResourceGroup
-------------------  ---------------------------------------  ----------------  ------  ----------------  ----------  -------------------  -----------------------
5                    af1bcd8bddd304b098c13de27b0f922b-TCP-80  2                 31148   2                 Tcp         Succeeded            mc_rg_aks_swedencentral

# nslookup

curl -Iv 20.240.25.37
*   Trying 20.240.25.37:80...
* Connected to 20.240.25.37 (20.240.25.37) port 80
> HEAD / HTTP/1.1
Server: nginx/1.27.3

iptables-save | grep loadbal
-A KUBE-SERVICES -d 20.240.25.37/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -j KUBE-EXT-2CMXP7HKUVJN7L6M

-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
-A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M

-A KUBE-SVC-2CMXP7HKUVJN7L6M -d 10.0.192.18/32 ! -i azv+ -p tcp -m comment --comment "default/nginx cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.33:80" -j KUBE-SEP-4X7S3D7PCAJUKXXB

-A KUBE-SEP-4X7S3D7PCAJUKXXB -s 10.244.0.33/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-4X7S3D7PCAJUKXXB -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.244.0.33:80

tbd
conntrack -L | grep 31148
tcp      6 9 TIME_WAIT src=168.63.129.16 dst=10.224.0.5 sport=53108 dport=31148 src=10.244.0.33 dst=10.224.0.5 sport=80 dport=64173 [ASSURED] mark=0 use=1
conntrack -L -d 10.244.0.33
tcp      6 102 TIME_WAIT src=10.224.0.4 dst=10.244.0.33 sport=48181 dport=80 src=10.244.0.33 dst=10.224.0.4 sport=80 dport=48181 [ASSURED] mark=0 use=1
```


```
# kubenet (cni), external ingress to a deployment without an ingress class/controller

kubectl delete deploy nginx
kubectl delete svc nginx
kubectl create deploy nginx --image=nginx --port=80 --replicas=2
# kubectl scale deploy nginx --replicas=3
kubectl expose deploy nginx --type=LoadBalancer

kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
nginx        LoadBalancer   10.0.42.82   4.225.83.202   80:32670/TCP   40s

# kubectl get ep
NAME         ENDPOINTS                         AGE
nginx        10.244.0.113:80,10.244.1.136:80   48s
# kubectl describe svc
IP:                       10.0.42.82
IPs:                      10.0.42.82
LoadBalancer Ingress:     4.225.83.202 (VIP)
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32670/TCP
Endpoints:                10.244.1.136:80,10.244.0.113:80
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
# kubectl get po -owide
NAME                     READY   STATUS    RESTARTS   AGE   IP             NODE                                NOMINATED NODE   READINESS GATES
nginx-6cfb64b7c5-cd62p   1/1     Running   0          68s   10.244.1.136   aks-nodepool1-33086427-vmss000000   <none>           <none>
nginx-6cfb64b7c5-twbl8   1/1     Running   0          68s   10.244.0.113   aks-nodepool1-33086427-vmss000001   <none>           <none>
# kubectl get no -owide
NAME                                STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE    KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-33086427-vmss000000   Ready    <none>   102m   v1.30.6   10.224.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1
aks-nodepool1-33086427-vmss000001   Ready    <none>   102m   v1.30.6   10.224.0.5    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
lb=kubernetes
az network lb frontend-ip list -g $noderg --lb-name $lb -o table
Name                                  PrivateIPAllocationMethod    ProvisioningState    ResourceGroup
------------------------------------  ---------------------------  -------------------  -----------------------
77d48a65-578b-46d1-9425-8e099370353a  Dynamic                      Succeeded            mc_rg_aks_swedencentral
acfb364359ebd47d2a267e12691cb5f3      Dynamic                      Succeeded            mc_rg_aks_swedencentral

pipid=$(az network lb frontend-ip show -g $noderg --lb-name $lb -n acfb364359ebd47d2a267e12691cb5f3 --query publicIPAddress.id -o tsv)
az network public-ip show --id $pipid --query ipAddress -o tsv
4.225.83.202

az network lb rule list -g $noderg --lb-name $lb -o table # port 80, tcp (not http)
BackendPort    DisableOutboundSnat    EnableFloatingIP    EnableTcpReset    FrontendPort    IdleTimeoutInMinutes    LoadDistribution    Name                                     Protocol    ProvisioningState    ResourceGroup
-------------  ---------------------  ------------------  ----------------  --------------  ----------------------  ------------------  ---------------------------------------  ----------  -------------------  -----------------------
80             True                   True                True              80              4                       Default             acfb364359ebd47d2a267e12691cb5f3-TCP-80  Tcp         Succeeded            mc_rg_aks_swedencentral

az network lb probe list -g $noderg --lb-name $lb -o table
IntervalInSeconds    Name                                     NumberOfProbes    Port    ProbeThreshold    Protocol    ProvisioningState    ResourceGroup
-------------------  ---------------------------------------  ----------------  ------  ----------------  ----------  -------------------  -----------------------
5                    acfb364359ebd47d2a267e12691cb5f3-TCP-80  2                 32670   2                 Tcp         Succeeded            mc_rg_aks_swedencentral

# nslookup

curl -Iv 4.225.83.202
* Connected to 4.225.83.202 (4.225.83.202) port 80
> HEAD / HTTP/1.1
HTTP/1.1 200 OK
< Server: nginx/1.27.3

iptables-save | grep loadbal
-A KUBE-SERVICES -d 4.225.83.202/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -j KUBE-EXT-2CMXP7HKUVJN7L6M

-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
-A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M

-A KUBE-SVC-2CMXP7HKUVJN7L6M -d 10.0.42.82/32 ! -i azv+ -p tcp -m comment --comment "default/nginx cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.113:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-ESQ56IRPPG5O3T2M
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.136:80" -j KUBE-SEP-4JJP2BCEIDJE7FLC

-A KUBE-SEP-ESQ56IRPPG5O3T2M -s 10.244.0.113/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-ESQ56IRPPG5O3T2M -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.244.0.113:80

-A KUBE-SEP-4JJP2BCEIDJE7FLC -s 10.244.1.136/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-4JJP2BCEIDJE7FLC -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.244.1.136:80

tbd
conntrack -L | grep 32670
tcp      6 48 TIME_WAIT src=168.63.129.16 dst=10.224.0.4 sport=57628 dport=32670 src=10.244.0.113 dst=10.224.0.4 sport=80 dport=1591 [ASSURED] mark=0 use=1
tcp      6 0 TIME_WAIT src=168.63.129.16 dst=10.224.0.4 sport=57400 dport=32670 src=10.244.1.136 dst=10.224.0.4 sport=80 dport=31248 [ASSURED] mark=0 use=1
conntrack -L -d 10.244.1.136
tcp      6 86395 ESTABLISHED src=10.224.0.5 dst=10.244.1.136 sport=29998 dport=80 src=10.244.1.136 dst=10.224.0.5 sport=80 dport=29998 [ASSURED] mark=0 use=1
```

```
# kubenet (cni), external ingress to a deployment with the webapprouting ingress class
# See the section on --enable-app-routing
```

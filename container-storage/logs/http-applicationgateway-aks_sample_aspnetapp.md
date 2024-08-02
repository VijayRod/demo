```
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml

kubectl get ing
NAME        CLASS                       HOSTS   ADDRESS         PORTS   AGE
aspnetapp   azure-application-gateway   *       135.225.8.189   80      50m

curl -I 135.225.8.189
HTTP/1.1 200 OK
```

```
# frontendIP
publicIpResourceUri=$(az network application-gateway show -g $noderg -n myApplicationGateway --query frontendIPConfigurations[0].publicIPAddress.id -otsv)
ping -c2 $(az network public-ip show --ids $publicIpResourceUri --query ipAddress -otsv)
PING 135.225.8.189 (135.225.8.189) 56(84) bytes of data.
64 bytes from 135.225.8.189: icmp_seq=1 ttl=101 time=62.8 ms
64 bytes from 135.225.8.189: icmp_seq=2 ttl=101 time=63.1 ms

# backendAddressPools
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network application-gateway show -g $noderg -n myApplicationGateway --query backendAddressPools[0].backendAddresses
[
  {
    "ipAddress": "10.224.0.46"
  }
]
kubectl get po -A -owide | grep .46
default       aspnetapp                                  1/1     Running   0             5m57s   10.224.0.46   aks-nodepool1-23009221-vmss000000   <none>           <none>

kubectl get po -A -l app=ingress-appgw
kube-system   ingress-appgw-deployment-7766b47b8-gncdl   1/1     Running   2 (36m ago)   37m
kubectl logs -n kube-system -l app=ingress-appgw
```

```
curl -I 135.225.8.189
HTTP/1.1 200 OK

# tcpdump # 135.225.8.189
18:25:16.765615 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [S], seq 17414682, win 64480, options [mss 1240,sackOK,TS val 2768497815 ecr 0,nop,wscale 7], length 0
18:25:16.831588 IP 135.225.8.189.http > 1.2.3.4.34256: Flags [S.], seq 2877874075, ack 17414683, win 65160, options [mss 1386,sackOK,TS val 2610277127 ecr 2768497815,nop,wscale 10], length 0
18:25:16.831736 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [.], ack 1, win 504, options [nop,nop,TS val 2768497881 ecr 2610277127], length 0
18:25:16.831966 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [P.], seq 1:79, ack 1, win 504, options [nop,nop,TS val 2768497881 ecr 2610277127], length 78: HTTP: HEAD / HTTP/1.1
18:25:16.898088 IP 135.225.8.189.http > 1.2.3.4.34256: Flags [.], ack 79, win 64, options [nop,nop,TS val 2610277195 ecr 2768497881], length 0
18:25:16.902663 IP 135.225.8.189.http > 1.2.3.4.34256: Flags [P.], seq 1:138, ack 79, win 64, options [nop,nop,TS val 2610277199 ecr 2768497881], length 137: HTTP: HTTP/1.1 200 OK
18:25:16.902706 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [.], ack 138, win 503, options [nop,nop,TS val 2768497952 ecr 2610277199], length 0
18:25:16.903327 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [F.], seq 79, ack 138, win 503, options [nop,nop,TS val 2768497953 ecr 2610277199], length 0
18:25:16.969475 IP 135.225.8.189.http > 1.2.3.4.34256: Flags [F.], seq 138, ack 80, win 64, options [nop,nop,TS val 2610277264 ecr 2768497953], length 0
18:25:16.969528 IP 1.2.3.4.34256 > 135.225.8.189.http: Flags [.], ack 139, win 503, options [nop,nop,TS val 2768498019 ecr 2610277264], length 0

aks-nodepool1-23009221-vmss000000:/# tcpdump host 10.224.0.46
18:20:03.342110 IP vm000001.internal.cloudapp.net.29638 > 10.224.0.46.http-alt: Flags [P.], seq 3490304742:3490305031, ack 952502621, win 63, options [nop,nop,TS val 3267899200 ecr 2363865408], length 289: HTTP: HEAD / HTTP/1.1
18:20:03.342995 IP 10.224.0.46.http-alt > vm000001.internal.cloudapp.net.29638: Flags [P.], seq 1:114, ack 289, win 503, options [nop,nop,TS val 2363889471 ecr 3267899200], length 113: HTTP: HTTP/1.1 200 OK
18:20:03.344150 IP vm000001.internal.cloudapp.net.29638 > 10.224.0.46.http-alt: Flags [.], ack 114, win 63, options [nop,nop,TS val 3267899202 ecr 2363889471], length 0
```

- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new#deploy-a-sample-application-by-using-agic

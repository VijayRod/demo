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

```
aks-nodepool1-23009221-vmss000000:/# tcpdump host 10.224.0.46

length 35: HTTP: GET / HTTP/1.1 # health probe
16:42:22.884414 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 3348438743 ecr 2444429012], length 35: HTTP: GET / HTTP/1.1
16:42:22.885287 IP vm000000.internal.cloudapp.net.23516 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 982434400 ecr 3021102863], length 35: HTTP: GET / HTTP/1.1
16:42:52.891272 IP vm000001.internal.cloudapp.net.29768 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 3348468749 ecr 2444459018], length 35: HTTP: GET / HTTP/1.1
16:42:52.892178 IP vm000000.internal.cloudapp.net.18812 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 982464407 ecr 3021132870], length 35: HTTP: GET / HTTP/1.1
16:43:22.891980 IP vm000001.internal.cloudapp.net.56484 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 3348498750 ecr 2444489019], length 35: HTTP: GET / HTTP/1.1
16:43:22.895398 IP vm000000.internal.cloudapp.net.48602 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 982494410 ecr 3021162873], length 35: HTTP: GET / HTTP/1.1
16:43:52.894431 IP vm000001.internal.cloudapp.net.16766 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 3348528753 ecr 2444519021], length 35: HTTP: GET / HTTP/1.1
16:43:52.897252 IP vm000000.internal.cloudapp.net.27086 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 982524412 ecr 3021192876], length 35: HTTP: GET / HTTP/1.1

port 36182
16:42:22.883606 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [S], seq 3632701684, win 64240, options [mss 1410,sackOK,TS val 3348438741 ecr 0,nop,wscale 10], length 0
16:42:22.883677 IP 10.224.0.46.http-alt > vm000001.internal.cloudapp.net.36182: Flags [S.], seq 3349943661, ack 3632701685, win 65160, options [mss 1460,sackOK,TS val 2444429012 ecr 3348438741,nop,wscale 7], length 0
16:42:22.884414 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [.], ack 1, win 63, options [nop,nop,TS val 3348438743 ecr 2444429012], length 0
16:42:22.884414 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 3348438743 ecr 2444429012], length 35: HTTP: GET / HTTP/1.1
16:42:22.884456 IP 10.224.0.46.http-alt > vm000001.internal.cloudapp.net.36182: Flags [.], ack 36, win 509, options [nop,nop,TS val 2444429013 ecr 3348438743], length 0
16:42:22.885743 IP 10.224.0.46.http-alt > vm000001.internal.cloudapp.net.36182: Flags [P.], seq 1:3607, ack 36, win 509, options [nop,nop,TS val 2444429014 ecr 3348438743], length 3606: HTTP: HTTP/1.1 200 OK
16:42:22.886566 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [.], ack 3607, win 62, options [nop,nop,TS val 3348438745 ecr 2444429014], length 0
16:42:22.886590 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [F.], seq 36, ack 3607, win 63, options [nop,nop,TS val 3348438745 ecr 2444429014], length 0
16:42:22.886669 IP 10.224.0.46.http-alt > vm000001.internal.cloudapp.net.36182: Flags [F.], seq 3607, ack 37, win 509, options [nop,nop,TS val 2444429015 ecr 3348438745], length 0
16:42:22.887122 IP vm000001.internal.cloudapp.net.36182 > 10.224.0.46.http-alt: Flags [.], ack 3608, win 63, options [nop,nop,TS val 3348438746 ecr 2444429015], length 0

aks-nodepool1-23009221-vmss000000:/# tcpdump host 10.224.0.46 -nn
16:52:22.955759 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [S], seq 2888930515, win 64240, options [mss 1410,sackOK,TS val 983034468 ecr 0,nop,wscale 10], length 0
16:52:22.955808 IP 10.224.0.46.8080 > 10.225.0.4.39600: Flags [S.], seq 1608255906, ack 2888930516, win 65160, options [mss 1460,sackOK,TS val 3021702935 ecr 983034468,nop,wscale 7], length 0
16:52:22.956820 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [.], ack 1, win 63, options [nop,nop,TS val 983034472 ecr 3021702935], length 0
16:52:22.956820 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [P.], seq 1:36, ack 1, win 63, options [nop,nop,TS val 983034472 ecr 3021702935], length 35: HTTP: GET / HTTP/1.1
16:52:22.956853 IP 10.224.0.46.8080 > 10.225.0.4.39600: Flags [.], ack 36, win 509, options [nop,nop,TS val 3021702936 ecr 983034472], length 0
16:52:22.958091 IP 10.224.0.46.8080 > 10.225.0.4.39600: Flags [P.], seq 1:3607, ack 36, win 509, options [nop,nop,TS val 3021702937 ecr 983034472], length 3606: HTTP: HTTP/1.1 200 OK
16:52:22.958780 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [.], ack 3607, win 62, options [nop,nop,TS val 983034474 ecr 3021702937], length 0
16:52:22.958780 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [F.], seq 36, ack 3607, win 63, options [nop,nop,TS val 983034474 ecr 3021702937], length 0
16:52:22.959023 IP 10.224.0.46.8080 > 10.225.0.4.39600: Flags [F.], seq 3607, ack 37, win 509, options [nop,nop,TS val 3021702938 ecr 983034474], length 0
16:52:22.959469 IP 10.225.0.4.39600 > 10.224.0.46.8080: Flags [.], ack 3608, win 63, options [nop,nop,TS val 983034474 ecr 3021702938], length 0

az network application-gateway show -g $noderg -n myApplicationGateway --query backendHttpSettingsCollection[0].port
az network application-gateway show -g $noderg -n myApplicationGateway --query backendHttpSettingsCollection[0].protocol
az network application-gateway show -g $noderg -n myApplicationGateway --query backendHttpSettingsCollection[0].requestTimeout
az network application-gateway show -g $noderg -n myApplicationGateway --query probes[0].interval
az network application-gateway show -g $noderg -n myApplicationGateway --query probes[0].path
az network application-gateway show -g $noderg -n myApplicationGateway --query probes[0].protocol

8080
"Http"
30
30
"/"
"Http"

kubectl get svc aspnetapp -oyaml
spec:
  internalTrafficPolicy: Cluster
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  type: ClusterIP

subnetResourceUri=$(az network application-gateway show -g $noderg -n myApplicationGateway --query gatewayIPConfigurations[0].subnet.id -otsv)
az network vnet subnet show --ids $subnetResourceUri --query addressPrefix -otsv # 10.225.0.0/16, which includes 10.225.0.4
```

```
kubectl delete ing aspnetapp
kubectl delete svc aspnetapp
kubectl delete po aspnetapp
```

- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new#deploy-a-sample-application-by-using-agic

```
kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80 # --dry-run=client -oyaml # containerPort: 80 # --type=LoadBalancer
kubectl expose po nginx

# Or

kubectl delete po nginx
kubectl delete svc nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80 #
EOF
kubectl expose po nginx
sleep 5
kubectl get po
```

```
kubectl get svc -l run=nginx
kubectl get ep -l run=nginx
kubectl get po -l run=nginx # containerPort in the Pod is exposed with the same label as the Service (and endpoint)
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.0.30.96   <none>        80/TCP    27s
NAME    ENDPOINTS        AGE
nginx   10.244.0.34:80   43s
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          2m23s

kubectl describe svc -l run=nginx | grep ort
TargetPort:        80/TCP
kubectl describe po -l run=nginx | grep ort
Port:           80/TCP
kubectl get po -oyaml -l run=nginx | grep ort
      - containerPort: 80
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#debugging-services
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#my-service-is-missing-endpoints

```
kubectl delete deploy hostnames
kubectl create deploy hostnames --image=registry.k8s.io/serve_hostname --replicas=1
sleep 5
kubectl get po -owide -l app=hostnames

kubectl run -it --rm nginx --image=nginx -- curl http://10.244.0.38:9376 # $podIp:9376
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#setup

```
kubectl delete deploy hostnames
kubectl create deploy hostnames --image=registry.k8s.io/serve_hostname --replicas=1
sleep 5
kubectl expose deployment hostnames --port=80 --target-port=9376
kubectl get svc -l app=hostnames
kubectl run -it --rm nginx --image=nginx -- curl hostnames # Server: 10.0.0.10. Name: hostnames.default.svc.cluster.local
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#does-the-service-exist

```
kubectl get netpol -A
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#any-network-policy-ingress-rules-affecting-the-target-pods

```
kubectl run -it --rm busybox --image=busybox -- nslookup hostnames # svcname # Server: 10.0.0.10. Name: hostnames.default.svc.cluster.local
kubectl run -it --rm busybox --image=busybox -- cat /etc/resolv.conf # nameserver 10.0.0.10
kubectl get svc kubernetes --show-labels # 10.0.0.1 (not the cluster-dns service)
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#does-the-service-work-by-dns-name

```
kubectl run -it --rm busybox --image=busybox -- nslookup kubernetes # Server: 10.0.0.10
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#does-any-service-exist-in-dns

```
kubectl get svc -l app=hostnames
kubectl run -it --rm busybox --image=busybox -- wget -qO- 10.0.134.96:80
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#does-the-service-work-by-ip

```
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#is-the-service-defined-correctly

```
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#does-the-service-have-any-endpoints

```
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#are-the-pods-working

```
root@aks-nodepool1-26220731-vmss000000:/# ps auxw | grep kube-proxy
root        3743  0.0  0.7 764880 58068 ?        Ssl  08:42   0:04 kube-proxy --conntrack-max-per-core=0 --metrics-bind-address=0.0.0.0:10249 --cluster-cidr=10.244.0.0/16 --detect-local-mode=ClusterCIDR --pod-interface-name-prefix= --v=3

root@aks-nodepool1-26220731-vmss000000:/# cat /var/log/syslog | grep -e kube-proxy -e proxier
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#is-kube-proxy-running

```
-A KUBE-SEP-4TUEANZT3D3KOYIH -s 10.244.0.38/32 -m comment --comment "default/hostnames" -j KUBE-MARK-MASQ
-A KUBE-SEP-4TUEANZT3D3KOYIH -p tcp -m comment --comment "default/hostnames" -m tcp -j DNAT --to-destination 10.244.0.38:9376
-A KUBE-SERVICES -d 10.0.134.96/32 -p tcp -m comment --comment "default/hostnames cluster IP" -m tcp --dport 80 -j KUBE-SVC-YN5D6RYVEVZOH44Q
-A KUBE-SVC-YN5D6RYVEVZOH44Q ! -s 10.244.0.0/16 -d 10.0.134.96/32 -p tcp -m comment --comment "default/hostnames cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-YN5D6RYVEVZOH44Q -m comment --comment "default/hostnames -> 10.244.0.38:9376" -j KUBE-SEP-4TUEANZT3D3KOYIH
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#iptables-mode

```
kubectl get svc -l app=hostnames
root@aks-nodepool1-26220731-vmss000000:/# curl 10.0.134.96 $ serviceIp i.e. service.ClusterIp # Optionally, you can also curl $podId:9376

kill 3743 # TBD
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#is-kube-proxy-proxying

```
root@aks-nodepool1-26220731-vmss000000:/# ps auxw | grep kubelet
root        2683  2.0  1.5 1633396 128108 ?      Ssl  08:42   8:42 /usr/local/bin/kubelet --enable-server --node-labels=agentpool=nodepool1,kubernetes.azure.com/agentpool=nodepool1,agentpool=nodepool1,kubernetes.azure.com/agentpool=nodepool1,kubernetes.azure.com/cluster=MC_rg_aks_swedencentral,kubernetes.azure.com/consolidated-additional-properties=redact-9e4a-11ee-8ae6-5e340d7caa24,kubernetes.azure.com/kubelet-identity-client-id=redact-01d3-44da-93d8-c5bc7edb44f8,kubernetes.azure.com/mode=system,kubernetes.azure.com/node-image-version=AKSUbuntu-2204gen2containerd-202312.06.0,kubernetes.azure.com/nodepool-type=VirtualMachineScaleSets,kubernetes.azure.com/os-sku=Ubuntu,kubernetes.azure.com/role=agent,kubernetes.azure.com/storageprofile=managed,kubernetes.azure.com/storagetier=Premium_LRS,storageprofile=managed,storagetier=Premium_LRS --v=2 --volume-plugin-dir=/etc/kubernetes/volumeplugins --kubeconfig /var/lib/kubelet/kubeconfig --bootstrap-kubeconfig /var/lib/kubelet/bootstrap-kubeconfig --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock --runtime-cgroups=/system.slice/containerd.service --cgroup-driver=systemd --address=0.0.0.0 --anonymous-auth=false --authentication-token-webhook=true --authorization-mode=Webhook --azure-container-registry-config=/etc/kubernetes/azure.json --cgroups-per-qos=true --client-ca-file=/etc/kubernetes/certs/ca.crt --cloud-config=/etc/kubernetes/azure.json --cloud-provider=external --cluster-dns=10.0.0.10 --cluster-domain=cluster.local --container-log-max-size=50M --enforce-node-allocatable=pods --event-qps=0 --eviction-hard=memory.available<750Mi,nodefs.available<10%,nodefs.inodesFree<5%,pid.available<2000 --feature-gates=CSIMigrationAzureFile=true,DelegateFSGroupToCSIDriver=true --image-gc-high-threshold=85 --image-gc-low-threshold=80 --keep-terminated-pod-volumes=false --kube-reserved=cpu=100m,memory=1843Mi,pid=1000 --kubeconfig=/var/lib/kubelet/kubeconfig --max-pods=110 --node-status-update-frequency=10s --pod-infra-container-image=mcr.microsoft.com/oss/kubernetes/pause:3.6 --pod-manifest-path=/etc/kubernetes/manifests --protect-kernel-defaults=true --read-only-port=0 --rotate-certificates=true --streaming-connection-idle-timeout=4h --tls-cert-file=/etc/kubernetes/certs/kubeletserver.crt --tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256 --tls-private-key-file=/etc/kubernetes/certs/kubeletserver.key

root@aks-nodepool1-26220731-vmss000000:/# cat /var/log/syslog | grep -I hairpin
Dec 19 08:42:31 aks-nodepool1-26220731-vmss000000 kubelet[2683]: I1219 08:42:31.806013    2683 flags.go:64] FLAG: -hairpin-mode="promiscuous-bridge"

root@aks-nodepool1-26220731-vmss000000:/# apt install net-tools
root@aks-nodepool1-26220731-vmss000000:/# ifconfig cbr0 |grep PROMISC
cbr0: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/#a-pod-fails-to-reach-itself-via-the-service-ip

```
```

- https://kubernetes.io/docs/concepts/services-networking/
  - https://kubernetes.io/docs/concepts/services-networking/service/
  - https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- https://kubernetes.io/docs/reference/networking/service-protocols/
- https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster-services/
- https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/
- https://kubernetes.io/docs/tutorials/services/connect-applications-service/
- https://www.tkng.io/services/

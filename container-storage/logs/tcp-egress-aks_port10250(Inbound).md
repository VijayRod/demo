```
# Blocks node communication, including kubelet on TCP 10250.

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no

kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-40004829-vmss000000"}}}'
sleep 10
kubectl get po nginx

kubectl logs nginx
# Error from server: Get "https://10.224.0.4:10250/containerLogs/default/nginx/nginx": http2: client connection lost

kubectl exec -it nginx -- ls
Error from server: error dialing backend: EOF

kubectl get no
NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-40004829-vmss000000   Ready    agent   3h32m   v1.27.7
aks-nodepool1-40004829-vmss000001   Ready    agent   83m     v1.27.7

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-40004829-vmss --command-id RunShellScript --instance-id 0 --scripts "cat /var/log/syslog"
Nov 22 19:04:51 aks-nodepool1-40004829-vmss000000 kubelet[2461]: I1122 19:04:51.391291    2461 flags.go:64] FLAG: --port=\"10250\"
Nov 22 19:04:51 aks-nodepool1-40004829-vmss000000 kubelet[2461]: I1122 19:04:51.770554    2461 server.go:162] \"Starting to listen\" address=\"0.0.0.0\" port=10250
Nov 22 19:25:47 aks-nodepool1-40004829-vmss000000 kubelet[2461]: E1122 19:25:47.541212    2461 upgradeaware.go:426] Error proxying data from client to backend: readfrom tcp 127.0.0.1:40894->127.0.0.1:45449: read tcp 10.224.0.4:10250->10.244.0.14:45454: read: connection timed out
Nov 22 19:26:29 aks-nodepool1-40004829-vmss000000 kubelet[2461]: E1122 19:26:29.269417    2461 upgradeaware.go:426] Error proxying data from client to backend: readfrom tcp 127.0.0.1:50482->127.0.0.1:45449: read tcp 10.224.0.4:10250->10.244.0.13:60464: read: connection timed out
```

- https://kubernetes.io/docs/reference/networking/ports-and-protocols/: TCP	Inbound	10250	Kubelet API	Self, Control plane (Inbound not egress)

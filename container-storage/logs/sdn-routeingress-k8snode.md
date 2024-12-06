## routeingress.k8snode.port10250 (kubelet, node notready)

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

```
# tbd This is for a node that does not have a tunnel pod.

# kubectl get po -A -owide | grep konn

# node: iptables -A INPUT -p tcp --dport 10250 -j DROP
kubectl get no # aks-nodepool1-14945448-vmss000001   NotReady   agent   26m   v1.28.10

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-14945448-vmss000001 --command-id RunShellScript --instance-id 0 --scripts "iptables -D INPUT -p tcp --dport 10250 -j DROP" # ParentResourceNotFound. 

# Tbd One mitigation strategy is to allow a few minutes for the remediator to take action.
```

- https://kubernetes.io/docs/reference/networking/ports-and-protocols/: TCP	Inbound	10250	Kubelet API	Self, Control plane (Inbound not egress)
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/tunnel-connectivity-issues
- https://kubernetes.io/docs/reference/networking/ports-and-protocols/#node: TCP	Inbound	10250	Kubelet API	Self, Control plane

## routeingress.k8snode.port10250.kubectlogs

```
# kubectl get po -A -owide | grep core
kube-system   coredns-6745896b65-jbvz9              1/1     Running   0          19m   10.244.0.2    aks-nodepool1-14945448-vmss000002   <none>           <none>
kube-system   coredns-6745896b65-q8mc7              1/1     Running   0          17m   10.244.0.8    aks-nodepool1-14945448-vmss000002   <none>           <none>
kube-system   coredns-autoscaler-dcbf9c474-k8tkc    1/1     Running   0          19m   10.244.0.6    aks-nodepool1-14945448-vmss000002   <none>           <none>

# kubectl get no -owide
NAME                                STATUS   ROLES   AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE
   KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14945448-vmss000000   Ready    agent   20m   v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14945448-vmss000001   Ready    agent   20m   v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14945448-vmss000002   Ready    agent   21m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

# kubectl run --image=nginx nginx --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-14945448-vmss000000" } } } } }'
pod/nginx created in the non-coredns node

# kubectl logs nginx --v=9
I0729 13:47:43.446613     733 loader.go:373] Config loaded from file:  /root/.kube/config
I0729 13:47:43.453977     733 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx'
I0729 13:47:43.552635     733 round_trippers.go:495] HTTP Trace: DNS Lookup for aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io resolved to [{20.91.163.156 }]
I0729 13:47:43.617712     733 round_trippers.go:510] HTTP Trace: Dial to tcp:20.91.163.156:443 succeed
I0729 13:47:43.793510     733 round_trippers.go:553] GET https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx 200 OK in 339 milliseconds
I0729 13:47:43.793629     733 round_trippers.go:570] HTTP Statistics: DNSLookup 98 ms Dial 64 ms TLSHandshake 101 ms ServerProcessing 73 ms Duration 339 ms
I0729 13:47:43.793687     733 round_trippers.go:577] Response Headers:
I0729 13:47:43.793711     733 round_trippers.go:580]     Content-Length: 3625
I0729 13:47:43.793760     733 round_trippers.go:580]     Date: Mon, 29 Jul 2024 13:47:43 GMT
I0729 13:47:43.793804     733 round_trippers.go:580]     Audit-Id: b2ca685f-6f48-4489-ba72-229e0a06db8d
I0729 13:47:43.793819     733 round_trippers.go:580]     Cache-Control: no-cache, private
I0729 13:47:43.793880     733 round_trippers.go:580]     Content-Type: application/json
I0729 13:47:43.793898     733 round_trippers.go:580]     X-Kubernetes-Pf-Flowschema-Uid: 5db9fb5b-2a50-4de4-b9d7-28c58c26d8fe
I0729 13:47:43.793915     733 round_trippers.go:580]     X-Kubernetes-Pf-Prioritylevel-Uid: 8a123344-90a9-4eb2-a64f-29e3a428c632
I0729 13:47:43.794061     733 request.go:1188] Response Body: {"kind":"Pod","apiVersion":"v1","metadata":{"name":"nginx","namespace":"default","uid":"e389f7f1-bbe5-4eeb-84b9-cb9ff12b89e1","resourceVersion":"5689","creationTimestamp":"2024-07-29T13:47:10Z","labels":{"run":"nginx"},"managedFields":[{"manager":"kubectl-run","operation":"Update","apiVersion":"v1","time":"2024-07-29T13:47:10Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:run":{}}},"f:spec":{"f:containers":{"k:{\"name\":\"nginx\"}":{".":{},"f:image":{},"f:imagePullPolicy":{},"f:name":{},"f:resources":{},"f:terminationMessagePath":{},"f:terminationMessagePolicy":{}}},"f:dnsPolicy":{},"f:enableServiceLinks":{},"f:restartPolicy":{},"f:schedulerName":{},"f:securityContext":{},"f:terminationGracePeriodSeconds":{}}}},{"manager":"kubelet","operation":"Update","apiVersion":"v1","time":"2024-07-29T13:47:12Z","fieldsType":"FieldsV1","fieldsV1":{"f:status":{"f:conditions":{"k:{\"type\":\"ContainersReady\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}},"k:{\"type\":\"Initialized\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}},"k:{\"type\":\"Ready\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}}},"f:containerStatuses":{},"f:hostIP":{},"f:phase":{},"f:podIP":{},"f:podIPs":{".":{},"k:{\"ip\":\"10.244.2.3\"}":{".":{},"f:ip":{}}},"f:startTime":{}}},"subresource":"status"}]},"spec":{"volumes":[{"name":"kube-api-access-nk49n","projected":{"sources":[{"serviceAccountToken":{"expirationSeconds":3607,"path":"token"}},{"configMap":{"name":"kube-root-ca.crt","items":[{"key":"ca.crt","path":"ca.crt"}]}},{"downwardAPI":{"items":[{"path":"namespace","fieldRef":{"apiVersion":"v1","fieldPath":"metadata.namespace"}}]}}],"defaultMode":420}}],"containers":[{"name":"nginx","image":"nginx","resources":{},"volumeMounts":[{"name":"kube-api-access-nk49n","readOnly":true,"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount"}],"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","imagePullPolicy":"Always"}],"restartPolicy":"Always","terminationGracePeriodSeconds":30,"dnsPolicy":"ClusterFirst","serviceAccountName":"default","serviceAccount":"default","nodeName":"aks-nodepool1-14945448-vmss000001","securityContext":{},"schedulerName":"default-scheduler","tolerations":[{"key":"node.kubernetes.io/not-ready","operator":"Exists","effect":"NoExecute","tolerationSeconds":300},{"key":"node.kubernetes.io/unreachable","operator":"Exists","effect":"NoExecute","tolerationSeconds":300}],"priority":0,"enableServiceLinks":true,"preemptionPolicy":"PreemptLowerPriority"},"status":{"phase":"Running","conditions":[{"type":"Initialized","status":"True","lastProbeTime":null,"lastTransitionTime":"2024-07-29T13:47:10Z"},{"type":"Ready","status":"True","lastProbeTime":null,"lastTransitionTime":"2024-07-29T13:47:12Z"},{"type":"ContainersReady","status":"True","lastProbeTime":null,"lastTransitionTime":"2024-07-29T13:47:12Z"},{"type":"PodScheduled","status":"True","lastProbeTime":null,"lastTransitionTime":"2024-07-29T13:47:10Z"}],"hostIP":"10.224.0.6","podIP":"10.244.2.3","podIPs":[{"ip":"10.244.2.3"}],"startTime":"2024-07-29T13:47:10Z","containerStatuses":[{"name":"nginx","state":{"running":{"startedAt":"2024-07-29T13:47:12Z"}},"lastState":{},"ready":true,"restartCount":0,"image":"docker.io/library/nginx:latest","imageID":"docker.io/library/nginx@sha256:6af79ae5de407283dcea8b00d5c37ace95441fd58a8b1d2aa1ed93f5511bb18c","containerID":"containerd://72dcc9d6491f5725fbbbd1debffd5232c7bd54125a9ab3b1ea21b20e5d60cf16","started":true}],"qosClass":"BestEffort"}}
I0729 13:47:43.799258     733 round_trippers.go:466] curl -v -XGET  -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Accept: application/json, */*" -H "Authorization: Bearer <masked>" 'https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/log?container=nginx'
I0729 13:47:43.881036     733 round_trippers.go:553] GET https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/log?container=nginx 200 OK in 81 milliseconds
I0729 13:47:43.881171     733 round_trippers.go:570] HTTP Statistics: GetConnection 0 ms ServerProcessing 81 ms Duration 81 ms
I0729 13:47:43.881195     733 round_trippers.go:577] Response Headers:
I0729 13:47:43.881269     733 round_trippers.go:580]     Audit-Id: 97d171a3-b431-452a-8438-a62a84d76b38
I0729 13:47:43.881297     733 round_trippers.go:580]     Cache-Control: no-cache, private
I0729 13:47:43.881363     733 round_trippers.go:580]     Content-Type: text/plain
I0729 13:47:43.881539     733 round_trippers.go:580]     Date: Mon, 29 Jul 2024 13:47:43 GMT
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/07/29 13:47:12 [notice] 1#1: using the "epoll" event method
2024/07/29 13:47:12 [notice] 1#1: nginx/1.27.0
2024/07/29 13:47:12 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2024/07/29 13:47:12 [notice] 1#1: OS: Linux 5.15.0-1067-azure
2024/07/29 13:47:12 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/07/29 13:47:12 [notice] 1#1: start worker processes
2024/07/29 13:47:12 [notice] 1#1: start worker process 28
2024/07/29 13:47:12 [notice] 1#1: start worker process 29

# aks-nodepool1-14945448-vmss000001: -A INPUT -p tcp --dport 10250 -j DROP
# kubectl logs nginx --v=9
...
I0729 13:51:57.249938     823 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/log?container=nginx'
I0729 13:52:29.037147     823 round_trippers.go:553] GET https://aksdns-rg-efec8e-402yw2w3.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/log?container=nginx 500 Internal Server Error in 31787 milliseconds
I0729 13:52:29.037225     823 round_trippers.go:570] HTTP Statistics: GetConnection 0 ms ServerProcessing 31786 ms Duration 31787 ms
I0729 13:52:29.037237     823 round_trippers.go:577] Response Headers:
I0729 13:52:29.037249     823 round_trippers.go:580]     Audit-Id: 0740e9cc-f2d2-410b-906c-01eae73e0069
I0729 13:52:29.037313     823 round_trippers.go:580]     Cache-Control: no-cache, private
I0729 13:52:29.037323     823 round_trippers.go:580]     Content-Type: application/json
I0729 13:52:29.037356     823 round_trippers.go:580]     Content-Length: 190
I0729 13:52:29.037366     823 round_trippers.go:580]     Date: Mon, 29 Jul 2024 13:52:28 GMT
I0729 13:52:29.037407     823 request.go:1188] Response Body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"Get \"https://10.224.0.6:10250/containerLogs/default/nginx/nginx\": http2: client connection lost","code":500}
I0729 13:52:29.038347     823 helpers.go:246] server response object: [{
  "metadata": {},
  "status": "Failure",
  "message": "Get \"https://10.224.0.6:10250/containerLogs/default/nginx/nginx\": http2: client connection lost",
  "code": 500
}]
Error from server: Get "https://10.224.0.6:10250/containerLogs/default/nginx/nginx": http2: client connection lost

# tbd The NodeNotReady page includes a mitigation for a node that isn't running coredns. One mitigation strategy is to allow a few minutes for the remediator to take action.
```

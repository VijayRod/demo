## k8s

- https://kubernetes.io/docs/home/
- https://book.kubebuilder.io/reference/using-finalizers.html
- https://kubebyexample.com/learning-paths/operator-framework/kubernetes-api-fundamentals/finalizers

## k8s.spec.addons
- https://kubernetes.io/docs/concepts/overview/components/#addons
- https://learn.microsoft.com/en-us/azure/aks/integrations

## k8s.spec.components
- https://kubernetes.io/docs/concepts/overview/components/

## k8s.spec.components.apiserver

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
kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.0.0.1      <none>           443/TCP        2d11h

aks-nodepool1-32897461-vmss000000:/# curl 10.0.0.1:443 -v
*   Trying 10.0.0.1:443...
* Connected to 10.0.0.1 (10.0.0.1) port 443 (#0)
> GET / HTTP/1.1
> Host: 10.0.0.1:443
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
* HTTP 1.0, assume close after body
< HTTP/1.0 400 Bad Request
<
Client sent an HTTP request to an HTTPS server.
* Closing connection 0

aks-nodepool1-32897461-vmss000000:/# iptables-save | grep 10.0.0.1
-A KUBE-SERVICES -d 10.0.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SVC-NPX46M4PTMTKRN6Y ! -s 10.244.0.0/16 -d 10.0.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -j KUBE-MARK-MASQ
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

- https://github.com/kubernetes/community/tree/master/sig-scalability/slos

## k8s.spec.components.apiserver.authorizedIpRanges

```
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 73.140.245.0/24
az aks update -g $rg -n aks --api-server-authorized-ip-ranges ""
az aks show -g $rg -n aks --query apiServerAccessProfile.authorizedIpRanges
```

```
nc -vz $fqdn 443 # works from a non-authorized IP too
Connection to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io 443 port [tcp/https] succeeded!

telnet $fqdn 443 # works from a non-authorized IP too
Trying 4.225.35.13...
Connected to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io.

curl https://$fqdn -k # from a non-authorized IP
curl: (28) Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out

curl https://$fqdn -vk
*   Trying 4.225.35.13:443...
* TCP_NODELAY set
* connect to 4.225.35.13 port 443 failed: Connection timed out
* Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out
* Closing connection 0
curl: (28) Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out

tcpdump host 4.225.35.13 # curl https://$fqdn -k from a non-authorized IP
tcpdump port 443
19:49:04.991368 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053869690 ecr 0,nop,wscale 7], length 0
19:49:06.059940 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053870759 ecr 0,nop,wscale 7], length 0
19:49:08.139988 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053872839 ecr 0,nop,wscale 7], length 0
19:49:12.219820 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053876919 ecr 0,nop,wscale 7], length 0
19:49:20.699964 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053885399 ecr 0,nop,wscale 7], length 0
19:49:37.340037 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053902039 ecr 0,nop,wscale 7], length 0
19:50:09.979829 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053934679 ecr 0,nop,wscale 7], length 0

az aks get-credentials -g $rg -n aks --overwrite-existing # works from a non-authorized IP too
The behavior of this command has been altered by the following extension: aks-preview
Merged "aks" as current context in /root/.kube/config

kubectl get po # from a non-authorized IP
Unable to connect to the server: dial tcp 4.225.35.13:443: i/o timeout

kubectl get po --v=9
I1219 19:47:09.424486     523 loader.go:373] Config loaded from file:  /root/.kube/config
I1219 19:47:09.428626     523 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500'
I1219 19:47:09.472854     523 round_trippers.go:495] HTTP Trace: DNS Lookup for aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io resolved to [{4.225.35.13 }]
I1219 19:47:39.429559     523 round_trippers.go:508] HTTP Trace: Dial to tcp:4.225.35.13:443 failed: dial tcp 4.225.35.13:443: i/o timeout
I1219 19:47:39.429636     523 round_trippers.go:553] GET https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500  in 30000 milliseconds
I1219 19:47:39.429690     523 round_trippers.go:570] HTTP Statistics: DNSLookup 44 ms Dial 29956 ms TLSHandshake 0 ms Duration 30000 ms
I1219 19:47:39.429696     523 round_trippers.go:577] Response Headers:
I1219 19:47:39.429780     523 helpers.go:264] Connection error: Get https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500: dial tcp 4.225.35.13:443: i/o timeout
Unable to connect to the server: dial tcp 4.225.35.13:443: i/o timeout
```
     
- https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
- https://learn.microsoft.com/en-us/azure/architecture/aws-professional/eks-to-aks/private-clusters#authorized-ip-ranges

## k8s.spec.cloudprovider

- https://github.com/kubernetes/cloud-provider
- https://kubernetes.io/docs/concepts/architecture/cloud-controller/: The cloud controller manager uses Go interfaces, specifically, CloudProvider interface defined in cloud.go from kubernetes/cloud-provider to allow implementations from any cloud to be plugged in.

## k8s.spec.cloudprovider.azure

- https://cloud-provider-azure.sigs.k8s.io/install/
- https://cloud-provider-azure.sigs.k8s.io/topics/
- https://github.com/kubernetes-sigs/cloud-provider-azure

### k8s.spec.cloudprovider.azure.azurejson


Unlike a managed identity, the JSON file for a cluster created with a service principal includes the aadClientSecret, so make sure the secret is not shared.

```
root@aks-nodepool1-16663898-vmss000001:/# cat /etc/kubernetes/azure.json
{
    "cloud": "AzurePublicCloud",
    "tenantId": "redactt-1111-1111-1111-111111111111",
    "subscriptionId": "redacts-1111-1111-1111-111111111111",
    "aadClientId": "msi",
    "aadClientSecret": "msi",
...

kubectl exec -it -n kube-system csi-azuredisk-node-grlf2 -c azuredisk -- cat /etc/kubernetes/azure.json # On Windows, use "type c:\k\azure.json"
{
    "cloud": "AzurePublicCloud",
...

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-agentpool-39272355-vmss --command-id RunShellScript --instance-id 4 --scripts "cat /etc/kubernetes/azure.json"
```

- https://cloud-provider-azure.sigs.k8s.io/install/configs/: This doc describes cloud provider config file...
- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md: The azure provider will reference a configuration file called azure.json
- https://learn.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-cluster#update-each-node-manually: Use the new credentials provided by your cloud operator to update /etc/kubernetes/azure.json on each node. After making the update, restart both kubele and kube-controller-manager.
- https://learn.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli#other-considerations: On the agent node VMs in the Kubernetes cluster, the service principal credentials are stored in the /etc/kubernetes/azure.json file.
- https://stackoverflow.com/questions/47350353/where-to-find-kubernetes-api-credentials-with-aks: When your Kubernetes cluster is created by ACS, a file named /etc/kubernetes/azure.json is created to store the Azure credentials for API access. Kubernetes uses this file for the Azure cloud provider.
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/csi-debug.md#case2-volume-mountunmount-failed: get cloud config file(azure.json)

### k8s.spec.cloudprovider.azure.intree

```
# To count the number of in-tree volumes for AzureDisk and AzureFile
kubectl get pv -o yaml | grep azureDisk | wc -l
kubectl get pv -o yaml | grep azureFile | wc -l
```

- https://learn.microsoft.com/en-us/azure/aks/csi-migrate-in-tree-volumes
- https://github.com/kubernetes/kubernetes/tree/v1.13.0/pkg/cloudprovider/providers/azure
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, azurefile CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in azure file plugin would be incorporated into this driver.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.
- https://learn.microsoft.com/en-us/azure/aks/csi-storage-drivers: Starting with Kubernetes version 1.26, in-tree persistent volume types kubernetes.io/azure-disk and kubernetes.io/azure-file are deprecated and will no longer be supported. ...you should migrate to the corresponding CSI drivers disk.csi.azure.com and file.csi.azure.com.
  
## k8s.spec.cloudprovider.azure.aso

```
# Azure Service Operator (ASO)
```

- https://github.com/azure/azure-service-operator
- https://azure.github.io/azure-service-operator/

## k8s.spec.cloudprovider.azure.aso.CAPZ aka cluster-api-provider-azure

```
# https://cluster-api.sigs.k8s.io/user/quick-start#install-clusterctl
cd /tmp
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.8.3/clusterctl-linux-amd64 -o clusterctl
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl

clusterctl version
clusterctl version: &version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.3", GitCommit:"945c938ce3e093c71950e022de4253373f911ae8", GitTreeState:"clean", BuildDate:"2024-09-10T16:29:18Z", GoVersion:"go1.22.7", Compiler:"gc", Platform:"linux/amd64"}
New clusterctl version available: v1.8.3 -> v1.8.4
sigs.k8s.io/cluster-api

# https://cluster-api.sigs.k8s.io/user/quick-start#initialization-for-common-providers

# tbd useragent has aso-controller/... cluster-api-provider-azure/
```

- https://github.com/kubernetes-sigs/cluster-api-provider-azure
- https://github.com/kubernetes-sigs/cluster-api-provider-azure/blob/main/docs/book/src/topics/topics.md
- https://capz.sigs.k8s.io/
- https://opensource.microsoft.com/blog/2020/12/15/introducing-cluster-api-provider-azure-capz-kubernetes-cluster-management/: The Kubernetes community project Cluster API (CAPI) enables users to manage fleets of clusters across multiple infrastructure providers.
- https://dev.to/lastcoolnameleft/when-how-and-where-to-use-clusterapi-capi-and-clusterapi-for-azure-capz-1lpc
- https://techcommunity.microsoft.com/t5/azure-arc-blog/leveraging-azure-arc-cluster-extensions-on-cluster-api-azure/ba-p/2251349

## k8s.spec.cloudprovider.azure.aso.CAPZ.aks

- https://capz.sigs.k8s.io/: CAPZ enables efficient management at scale of self-managed or managed (AKS) clusters on Azure.
- https://capz.sigs.k8s.io/managed/managedcluster

## k8s.tools.md
https://collabnix.github.io/kubetools/

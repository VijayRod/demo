```
az aks create -g $rg -n aksblob -s $vmsize -c 2 --enable-blob-driver
az aks get-credentials -g $rg -n aksblob

kubectl get sc | grep blob
azureblob-fuse-premium   blob.csi.azure.com   Delete          Immediate              true                   45m
azureblob-nfs-premium    blob.csi.azure.com   Delete          Immediate              true                   45m

kubectl get po -n kube-system -l app=csi-blob-node -owide
csi-blob-node-49kmt   4/4     Running   0          45m   10.224.0.5   aks-nodepool1-22045248-vmss000000   <none>           <none>
csi-blob-node-zxrs2   4/4     Running   0          45m   10.224.0.4   aks-nodepool1-22045248-vmss000001   <none>           <none>
```

```
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-blob-storage
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-nfs-premium
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
      readOnly: false
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azure-blob-storage
EOF
kubectl get pv -oyaml | grep volumeHandle
# volumeHandle: MC_rg_aksblob_swedencentral#nfs0011a5b862714b37871a#pvc-e851dcc4-02f4-415f-87a0-5cf33dcfb7cb##default#

kubectl logs -n kube-system -l app=csi-blob-node -c blob
I0829 18:46:10.919795    4956 nodeserver.go:357] volume(MC_rg_aksblob_swedencentral#nfs0011a5b862714b37871a#pvc-e851dcc4-02f4-415f-87a0-5cf33dcfb7cb##default#) mount nfs0011a5b862714b37871a.blob.core.windows.net:/nfs0011a5b862714b37871a/pvc-e851dcc4-02f4-415f-87a0-5cf33dcfb7cb on /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/c53ae8ba383d25a70e04db2b0972027927b6e800d23d7d6df8e620ed0d554073/globalmount succeeded
I0829 18:46:10.919824    4956 utils.go:111] GRPC response: {}
I0829 18:46:10.942183    4956 utils.go:104] GRPC call: /csi.v1.Node/NodePublishVolume

nslookup nfs0011a5b862714b37871b.blob.core.windows.net
Server:         10.255.255.254
Address:        10.255.255.254#53
** server can't find nfs0011a5b862714b37871b.blob.core.windows.net: NXDOMAIN
aks-nodepool1-22045248-vmss000000:/# nslookup nfs0011a5b862714b37871b.blob.core.windows.net
Server:         168.63.129.16
Address:        168.63.129.16#53
** server can't find nfs0011a5b862714b37871b.blob.core.windows.net: NXDOMAIN

telnet nfs0011a5b862714b37871b.blob.core.windows.net 443
Trying 1.2.3.4...
Connected to blob.gvx01prdstf01a.store.core.windows.net.
Escape character is '^]'.

kubectl get po mypod -owide
mypod   1/1     Running   0          56m   10.244.1.9   aks-nodepool1-22045248-vmss000001   <none>           <none>
kubectl get no -owide
aks-nodepool1-22045248-vmss000001   Ready    <none>   123m   v1.29.7   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1070-azure   containerd://1.7.20-1

aks-nodepool1-22045248-vmss000001:/# df -h | grep pvc-
Filesystem                                                                        Size  Used Avail Use% Mounted on
10.161.100.100:/nfs0011a5b862714b37871a/pvc-e851dcc4-02f4-415f-87a0-5cf33dcfb7cb  5.0P     0  5.0P   0% /var/lib/kubelet/pods/e195b443-7e09-45f8-992a-1c78b76d2b69/volumes/kubernetes.io~csi/pvc-e851dcc4-02f4-415f-87a0-5cf33dcfb7cb/mount

kubectl exec -it mypod -- touch /mnt/blob
wireshark
2783	10.224.0.4	20.60.79.4	NFS	280	V3 GETATTR Call (Reply In 2792), FH: 0x7b6c4daa
2792	20.60.79.4	10.224.0.4	NFS	188	V3 GETATTR Reply (Call In 2783)  Directory mode: 0777 uid: 0 gid: 0
2794	10.224.0.4	20.60.79.4	NFS	292	V3 LOOKUP Call (Reply In 2795), DH: 0x7b6c4daa/example2
2795	20.60.79.4	10.224.0.4	NFS	192	V3 LOOKUP Reply (Call In 2794) Error: NFS3ERR_NOENT
2796	10.224.0.4	20.60.79.4	NFS	324	V3 CREATE Call (Reply In 2798), DH: 0x7b6c4daa/example2 Mode: UNCHECKED
2798	20.60.79.4	10.224.0.4	NFS	376	V3 CREATE Reply (Call In 2796)

https://www.azurespeed.com/api/ipAddress?ipOrDomain=20.60.79.4
[{"serviceTagId":"Storage","ipAddress":"20.60.79.4","ipAddressPrefix":"20.60.0.0/16","region":"","regionId":"0","systemService":"AzureStorage","networkFeatures":"API NSG UDR FW VSE"},
{"serviceTagId":"Storage.SwedenCentral","ipAddress":"20.60.79.4","ipAddressPrefix":"20.60.78.0/23","region":"swedencentral","regionId":"76","systemService":"AzureStorage","networkFeatures":"API NSG UDR FW"},
{"serviceTagId":"AzureCloud.swedencentral","ipAddress":"20.60.79.4","ipAddressPrefix":"20.60.78.0/23","region":"swedencentral","regionId":"76","systemService":"","networkFeatures":"API NSG"},
{"serviceTagId":"AzureCloud","ipAddress":"20.60.79.4","ipAddressPrefix":"20.60.78.0/23","region":"","regionId":"0","systemService":"","networkFeatures":"API NSG"}]

az network vnet show -g MC_rg_aksblob_swedencentral -n aks-vnet-25847871 --query subnets[0].serviceEndpoints # aks-subnet
[
  {
    "locations": [
      "swedencentral",
      "swedensouth"
    ],
    "provisioningState": "Succeeded",
    "service": "Microsoft.Storage"
  }
]

wireshark tcp.port==2048
wireshark ip.addr==20.60.79.4
783	20.60.79.4	10.224.0.4	RPC	66	Continuation
784	10.224.0.4	20.60.79.4	TCP	84	722 ? 2048 [ACK] Seq=1 Ack=2 Win=501 Len=0 TSval=3767733903 TSecr=3101295122 SLE=1 SRE=2
2783	10.224.0.4	20.60.79.4	NFS	280	V3 GETATTR Call (Reply In 2792), FH: 0x7b6c4daa
2792	20.60.79.4	10.224.0.4	NFS	188	V3 GETATTR Reply (Call In 2783)  Directory mode: 0777 uid: 0 gid: 0
2793	10.224.0.4	20.60.79.4	TCP	72	722 ? 2048 [ACK] Seq=209 Ack=118 Win=501 Len=0 TSval=3767758589 TSecr=3101469811
2794	10.224.0.4	20.60.79.4	NFS	292	V3 LOOKUP Call (Reply In 2795), DH: 0x7b6c4daa/example2
2795	20.60.79.4	10.224.0.4	NFS	192	V3 LOOKUP Reply (Call In 2794) Error: NFS3ERR_NOENT
2796	10.224.0.4	20.60.79.4	NFS	324	V3 CREATE Call (Reply In 2798), DH: 0x7b6c4daa/example2 Mode: UNCHECKED
2797	20.60.79.4	10.224.0.4	TCP	72	2048 ? 722 [ACK] Seq=238 Ack=681 Win=16381 Len=0 TSval=3101469825 TSecr=3767758593
2798	20.60.79.4	10.224.0.4	NFS	376	V3 CREATE Reply (Call In 2796)
2846	10.224.0.4	20.60.79.4	TCP	72	722 ? 2048 [ACK] Seq=681 Ack=542 Win=501 Len=0 TSval=3767758656 TSecr=3101469835
```

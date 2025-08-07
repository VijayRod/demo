## k8s-node.kubelet
```
root@aks-nodepool1-42220213-vmss000000:/# ps -aux | grep /bin/kubelet
root        2594  1.9  1.5 1795616 129144 ?      Ssl  19:01   0:12 /usr/local/bin/kubelet --enable-server 
--node-labels=agentpool=nodepool1,kubernetes.azure.com/agentpool=nodepool1,agentpool=nodepool1,kubernetes.azure.com/agentpool=nodepool1,kubernetes.azure.com/cluster=MC_rg_aks_swedencentral,kubernetes.azure.com/consolidated-additional-properties=redactp-7a48-11ee-93bb-822a5061c86d,kubernetes.azure.com/kubelet-identity-client-id=redactc-2506-4bdb-97a9-e5df219246e4,kubernetes.azure.com/mode=system,kubernetes.azure.com/node-image-version=AKSUbuntu-2204gen2containerd-202310.04.0,kubernetes.azure.com/nodepool-type=VirtualMachineScaleSets,kubernetes.azure.com/os-sku=Ubuntu,kubernetes.azure.com/role=agent,kubernetes.azure.com/storageprofile=managed,kubernetes.azure.com/storagetier=Premium_LRS,storageprofile=managed,storagetier=Premium_LRS
--v=2
--volume-plugin-dir=/etc/kubernetes/volumeplugins
--kubeconfig /var/lib/kubelet/kubeconfig
--bootstrap-kubeconfig /var/lib/kubelet/bootstrap-kubeconfig
--runtime-request-timeout=15m
--container-runtime-endpoint=unix:///run/containerd/containerd.sock
--runtime-cgroups=/system.slice/containerd.service
--container-runtime=remote
--cgroup-driver=systemd
--address=0.0.0.0
--anonymous-auth=false
--authentication-token-webhook=true
--authorization-mode=Webhook
--azure-container-registry-config=/etc/kubernetes/azure.json
--cgroups-per-qos=true
--client-ca-file=/etc/kubernetes/certs/ca.crt
--cloud-config=/etc/kubernetes/azure.json
--cloud-provider=external
--cluster-dns=10.0.0.10
--cluster-domain=cluster.local
--container-log-max-size=50M
--enforce-node-allocatable=pods
--event-qps=0
--eviction-hard=memory.available<750Mi,nodefs.available<10%,nodefs.inodesFree<5%,pid.available<2000
--feature-gates=CSIMigration=true,CSIMigrationAzureDisk=true,CSIMigrationAzureFile=true,DelegateFSGroupToCSIDriver=true
--image-gc-high-threshold=85
--image-gc-low-threshold=80
--keep-terminated-pod-volumes=false
--kube-reserved=cpu=100m,memory=1843Mi,pid=1000
--kubeconfig=/var/lib/kubelet/kubeconfig
--max-pods=110
--node-status-update-frequency=10s
--pod-infra-container-image=mcr.microsoft.com/oss/kubernetes/pause:3.6
--pod-manifest-path=/etc/kubernetes/manifests
--protect-kernel-defaults=true
--read-only-port=0
--rotate-certificates=true
--streaming-connection-idle-timeout=4h
--tls-cert-file=/etc/kubernetes/certs/kubeletserver.crt
--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256
--tls-private-key-file=/etc/kubernetes/certs/kubeletserver.key
```

```
# See the section on journalctl in bash

journalctl -u kubelet -o cat > /tmp/kubeletlogs
journalctl -u kubelet > /tmp/kubelet.log && journal -u containerd > /tmp/containerd.log
journalctl -xeu kubelet
```

- https://kubernetes.io/docs/concepts/overview/components/#kubelet
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
- https://blog.techiescamp.com/docs/kubelet-deep-dive/
- https://www.gravitycloud.tech/blog/kubelet-in-kubernetes

## k8s-node.kubelet.credentials.kubeletidentity

```
az aks show -g $rgname -n $clustername --query identityProfile.kubeletidentity
{
  "clientId": "redactc-ff96-4106-873c-7f52972f0c52",
  "objectId": "redacto-e53d-42c3-9385-8e11f066376c",
  "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rg_aksacr_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aksacr-agentpool"
}

noderg=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -o tsv)   
az vmss show -g $noderg -n aks-nodepool1-74128781-vmss --query identity.userAssignedIdentities
{
  "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aksacr_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aksacr-agentpool": {
    "clientId": "redactc-ff96-4106-873c-7f52972f0c52",
    "principalId": "redacto-e53d-42c3-9385-8e11f066376c"
  }
}
# Azure portal: VMSS, Security, Identity, User assigned.

root@aks-nodepool1-74128781-vmss000000:/# cat /etc/kubernetes/azure.json
    "aadClientId": "msi",
    "aadClientSecret": "msi",
    "userAssignedIdentityID": "redactc-ff96-4106-873c-7f52972f0c52",
```

## k8s-node.kubelet.evict
```
k8s-node.kubelet.evict.pod

kubectl get pod mypod -o json | jq '.status'

status:
  phase: Failed
  reason: Evicted
  message: "The node had condition: [DiskPressure]"


```
- https://github.com/kubernetes/kubernetes/issues/132001: Evicted pods from soft eviction do not always generate an event: When Pods are evicted due to a soft eviction threshold (e.g., disk pressure), most pods have an Evicted event(kubectl get events), but some do not.
- https://learn.microsoft.com/en-us/azure/aks/resize-node-pool?tabs=azure-cli: drain/evict operation will fail.
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/: Node-pressure eviction is the process by which the kubelet proactively terminates pods to reclaim resources on nodes

```
# k8s-node.kubelet.evict.pod.node
```
- https://learn.microsoft.com/en-us/azure/aks/spot-node-pool: If Azure needs capacity back, the Azure infrastructure evicts the Spot nodes.
- https://kubernetes.io/docs/concepts/scheduling-eviction/api-eviction/

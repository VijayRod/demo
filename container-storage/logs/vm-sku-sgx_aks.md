- https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-nodes-aks-overview
- https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-enclave-nodes-aks-get-started: DCsv2/DCSv3/DCdsv3. Confidential computing Intel SGX nodes are not recommended for system node pools.
  
```
# cc (confidential compute)

g=rgcc
# az group delete -n $rg -y --no-wait
az group create -n $rg -l eastus2 # $loc. Else VMSizeNotSupported in swedencentral for the SGX node pool.
az aks create -g $rg -n aks --enable-addons confcom -s $vmsize # -c 1 # --enable-addons confcom # -s Standard_DC4s_v3 to include primary node pool with cc nodes
# az aks enable-addons --addons confcom -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks nodepool add -g $rg --cluster-name aks -n npcc -s Standard_DC4s_v3 # -c 2

az aks show -g $rg -n aks --query addonProfiles.ACCSGXDevicePlugin
The behavior of this command has been altered by the following extension: aks-preview
{
  "config": {
    "ACCSGXQuoteHelperEnabled": "false"
  },
  "enabled": true,
  "identity": null
}

kubectl get deploy -n kube-system -l app=sgx-webhook
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
sgx-webhook   1/1     1            1           4m59s

kubectl get po -n kube-system -l app=sgx-webhook -owide
NAME                           READY   STATUS    RESTARTS   AGE     IP           NODE NOMINATED NODE   READINESS GATES
sgx-webhook-6d45565fb9-nqz5n   1/1     Running   0          8m26s   10.244.0.7   aks-nodepool1-25077743-vmss000000   <none>           <none>

kubectl get ds -n kube-system -l app=sgx-plugin
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
sgx-plugin   0         0         0       0            0           <none>          2m23s
```

```
az aks nodepool add -g $rg --cluster-name aks --name confcompool1 --node-vm-size Standard_DC2s_v3 -c 1

az aks nodepool show -g $rg --cluster-name aks --name confcompool1 --query vmSize
"Standard_DC2s_v3"

kubectl get ds -n kube-system -l app=sgx-plugin
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
sgx-plugin   1         1         1       1            1           <none>          6m4s

kubectl get po -n kube-system -l app=sgx-plugin -owide
NAME               READY   STATUS    RESTARTS   AGE     IP           NODE                                   NOMINATED NODE   READINESS GATES
sgx-plugin-lz4ml   1/1     Running   0          2m55s   10.244.1.2   aks-confcompool1-26803838-vmss000000   <none>           <none>

# node pool without a CC vm size
kubectl describe no
                    node.kubernetes.io/instance-type=Standard_B2ms

# node pool with a CC vm size
k describe no aks-npcc-51758617-vmss000000
Labels:             agentpool=npcc
                    kubernetes.azure.com/node-image-version=AKSUbuntu-2204gen2containerd-202506.03.0
                    node.kubernetes.io/instance-type=Standard_DC4s_v3
Capacity:
  cpu:                      4
  ephemeral-storage:        129886128Ki
  hugepages-1Gi:            0
  hugepages-2Mi:            0
  memory:                   32864252Ki
  pods:                     250
  sgx.intel.com/enclave:    110
  sgx.intel.com/epc:        17179869184
  sgx.intel.com/provision:  110
Allocatable:
  cpu:                      3860m
  ephemeral-storage:        119703055367
  hugepages-1Gi:            0
  hugepages-2Mi:            0
  memory:                   27590652Ki
  pods:                     250
  sgx.intel.com/enclave:    110
  sgx.intel.com/epc:        17179869184
  sgx.intel.com/provision:  110
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                 Requests    Limits
  --------                 --------    ------
  cpu                      360m (9%)   560m (14%)
  memory                   570Mi (2%)  7612Mi (28%)
  ephemeral-storage        0 (0%)      0 (0%)
  hugepages-1Gi            0 (0%)      0 (0%)
  hugepages-2Mi            0 (0%)      0 (0%)
  sgx.intel.com/enclave    0           0
  sgx.intel.com/epc        0           0
  sgx.intel.com/provision  0           0
```

```
az aks nodepool add -g $rg --cluster-name aks -n npcc -s standard_dc2eds_v5 # DC-series
(BadRequest) Code="BadRequest" Message="The VM size 'standard_dc2eds_v5' is not supported for creation of VMs and Virtual Machine Scale Set with '<NULL>' security type."
Code: BadRequest
# make sure to use az aks create --enable-addons confcom
```

```
rg=rgsku
az group create -n $rg -l eastus # $loc. Else VMSizeNotSupported in swedencentral for the SGX node pool.
az aks create -g $rg -n aks --enable-addons confcom -s $vmsize -c 1
# az aks enable-addons --addons confcom -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

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

kubectl describe no
                    node.kubernetes.io/instance-type=Standard_B2ms
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
```

- https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-nodes-aks-overview
- https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-enclave-nodes-aks-get-started: DCsv2/DCSv3/DCdsv3. Confidential computing Intel SGX nodes are not recommended for system node pools.

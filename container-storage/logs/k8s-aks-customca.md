```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-custom-ca-trust -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query securityProfile.customCaTrustCertificates # null

kubectl get ds -n kube-system custom-ca-trust
NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR
       AGE
custom-ca-trust   1         1         1       1            1           kubernetes.azure.com/custom-ca-trust-enabled=true   9m40s

kubectl get po -n kube-system -l app=custom-ca-trust
NAME                    READY   STATUS    RESTARTS   AGE
custom-ca-trust-2mhqt   1/1     Running   0          10m

kubectl get secret -n kube-system custom-ca-trust-secret-generated
kubectl get secret -n kube-system custom-ca-trust-secret-generated -oyaml
NAME                               TYPE     DATA   AGE
custom-ca-trust-secret-generated   Opaque   0      12m

root@aks-nodepool1-33084591-vmss000000:/# systemctl -l status update_certs.service
? update_certs.service - Updates certificates copied from AKS DS
     Loaded: loaded (/etc/systemd/system/update_certs.service; static)
     Active: inactive (dead)
TriggeredBy: ? update_certs.path
```

```
az aks create -g $rg -n aks --enable-custom-ca-trust --custom-ca-trust-certificates pathToFileWithCAs
az aks update -g $rg -n aks --custom-ca-trust-certificates pathToFileWithCAs # az aks create -g $rg -n aks  --enable-custom-ca-trust --custom-ca-trust-certificates pathToFileWithCAs
 
az aks nodepool add -g $rg --cluster-name aks -n nptrust --enable-custom-ca-trust -s $vmsize # --os-sku Mariner
az aks nodepool update -g $rg --cluster-name aks --name nptrust --enable-custom-ca-trust
az aks nodepool update -g $rg --cluster-name aks --name nptrust --disable-custom-ca-trust
```

- https://learn.microsoft.com/en-us/azure/aks/custom-certificate-authority

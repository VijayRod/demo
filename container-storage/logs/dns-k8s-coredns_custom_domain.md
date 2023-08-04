```
# These steps are similar to those for a private cluster with a private DNS zone
clustername=akscustomdomain
az aks create -g $rgname -n $clustername --enable-managed-identity --assign-identity $identityUri --vnet-subnet-id $subnetId
fqdn=$(az aks show -g $rgname -n $clustername --query fqdn -otsv); nslookup $fqdn

# To add an A record
az network private-dns record-set a add-record -g $rgname -z $privatezone -n db -a 20.91.129.141 # IP of the cluster FQDN

# To test in a cluster node with ping, ensure that the private DNS zone record returns the IP of the cluster FQDN
az aks get-credentials -g $rgname -n $clustername
root@aks-nodepool1-38956877-vmss000000:/# ping db.private.contoso.com
PING db.private.contoso.com (20.91.129.141) 56(84) bytes of data.

# To configure the CoreDNS config map
azureVip="168.63.129.16"
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  puglife.server: | # you may select any name here, but it must end with the .server file extension
    db.$privatezone:53 {
        errors
        cache 30
        forward . $azureVip  # this is my test/dev DNS server
    }
EOF
kubectl get cm -n kube-system coredns-custom -oyaml
kubectl -n kube-system rollout restart deployment coredns
kubectl get po -n kube-system -l k8s-app=kube-dns
```

```
# To test ping of the A record from a pod. Returns the IP of the cluster FQDN, i.e., 20.91.129.141.
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- nslookup db.private.contoso.com
```
https://learn.microsoft.com/en-us/azure/aks/coredns-custom#use-custom-domains

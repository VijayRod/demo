```
kubectl delete po nginx
kubectl delete svc nginx
kubectl run --image=nginx nginx --port=80
dnslabel="azure$RANDOM$RANDOM"
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: $dnslabel
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  type: LoadBalancer
EOF
kubectl get po,svc
```

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
## az network public-ip list -g $noderg -otable
az network public-ip show -g $noderg -n kubernetes-a651ffd11644f4e478971339715d4584 --query dnsSettings
{
  "domainNameLabel": "azure174699429",
  "fqdn": "azure174699429.swedencentral.cloudapp.azure.com"
}
```

- https://learn.microsoft.com/en-us/azure/aks/static-ip: Set a public-facing DNS label to the service using the service.beta.kubernetes.io/azure-dns-label-name service annotation...
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#customizations-via-kubernetes-annotations: service.beta.kubernetes.io/azure-dns-label-name
- https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#loadbalancer-annotations

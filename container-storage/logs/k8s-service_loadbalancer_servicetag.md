Alternatively, manually add the service tag ranges to loadBalancerSourceRanges.

```
kubectl delete po nginx
kubectl delete svc nginx
kubectl run --image=nginx nginx --port=80
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-allowed-service-tags: AzureTrafficManager,Internet
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
sleep 20
kubectl get po,svc

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv) 
az network nsg rule list -g $noderg --nsg-name aks-agentpool-37790187-nsg -otable # SourceAddressPrefixes=AzureTrafficManager,Internet for Direction=Inbound
```

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#customizations-via-kubernetes-annotations: service.beta.kubernetes.io/azure-allowed-service-tags

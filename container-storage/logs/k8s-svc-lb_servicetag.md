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
- https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#loadbalancer-annotations: When loadBalancerSourceRanges have been set on service spec, service.beta.kubernetes.io/azure-allowed-service-tags won’t work because of DROP iptables rules from kube-proxy. The CIDRs from service tags should be merged into loadBalancerSourceRanges to make it work.

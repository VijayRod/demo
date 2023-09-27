```
trafficmanager="akstm$RANDOM$RANDOM"
az group create -n $rg -l $loc
az network traffic-manager profile create -g $rg -n $trafficmanager --routing-method Performance --unique-dns-name $trafficmanager

az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
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
sleep 20
kubectl get po,svc
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
## az network public-ip list -g $noderg -otable
endpointUri=$(az network public-ip show -g $noderg -n kubernetes-a651ffd11644f4e478971339715d4584 --query id -otsv) # Query a public IP resource with a DNS label
az network traffic-manager endpoint create -g $rg -n akstm --profile-name $trafficmanager --type azureEndpoints --endpoint-status enabled --target-resource-id $endpointUri

fqdn=$(az network traffic-manager profile show -g $rg -n $trafficmanager --query dnsConfig.fqdn -otsv)
curl http://$fqdn -I # HTTP/1.1 200 OK. Sent an HTTP request.
```

```
az network traffic-manager profile show -g $rg -n $trafficmanager --query profileStatus # "Enabled"
az network traffic-manager profile show -g $rg -n $trafficmanager --query monitorConfig.profileMonitorStatus # "Online"

az network traffic-manager profile show -g $rg -n $trafficmanager --query "endpoints[0].endpointMonitorStatus" # "Online"
az network traffic-manager profile show -g $rg -n $trafficmanager --query "endpoints[0].endpointStatus" # "Enabled"
```

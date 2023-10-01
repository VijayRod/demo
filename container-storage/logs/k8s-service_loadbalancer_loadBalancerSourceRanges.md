```
kubectl delete po nginx
kubectl delete svc nginx
kubectl run --image=nginx nginx --port=80
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  type: LoadBalancer
  loadBalancerSourceRanges:
  - 1.2.3.4/32
EOF
sleep 20
kubectl get po,svc
```

```
root@aks-nodepool1-84519347-vmss000000:/# iptables-save | grep 1.2.3.4
-A KUBE-FW-2CMXP7HKUVJN7L6M -s 1.2.3.4/32 -m comment --comment "default/nginx loadbalancer IP" -j KUBE-EXT-2CMXP7HKUVJN7L6M

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv) 
az network nsg rule list -g $noderg --nsg-name aks-agentpool-37790187-nsg -otable # SourceAddressPrefixes=1.2.3.4/32
```

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#restrict-inbound-traffic-to-specific-ip-ranges
- https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/iptables/proxier.go#L1021: usesFWChain := hasEndpoints && len(svcInfo.LoadBalancerVIPStrings()) > 0 && len(svcInfo.LoadBalancerSourceRanges()) > 0
- https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/: loadBalancerSourceRanges

## cni.azure.overlay

```
rg=rgcni
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16  -s $vmsize -c 2
# az aks update -g $rg -n aks --network-plugin-mode overlay --pod-cidr 192.168.0.0/16
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks show -g $rg -n aks --query networkProfile.networkPluginMode
"overlay"

kubectl describe no
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/azure-cni-overlay=true
                    kubernetes.azure.com/network-name=aks-vnet-14939177
                    kubernetes.azure.com/network-resourcegroup=rgcni
                    kubernetes.azure.com/network-subnet=aks-subnet
                    kubernetes.azure.com/network-subscription=redacts-1111-1111-1111-111111111111
                    kubernetes.azure.com/nodenetwork-vnetguid=eb6bc04b-710d-4348-8020-be2a2b853bf5
                    kubernetes.azure.com/podnetwork-type=overlay

kubectl get po -n kube-system -l k8s-app=azure-cns
NAME              READY   STATUS    RESTARTS   AGE
azure-cns-d6j9c   1/1     Running   0          60m
azure-cns-hxlw6   1/1     Running   0          60m

kubectl get nnc -n kube-system -owide
NAME                                REQUESTED IPS   ALLOCATED IPS   SUBNET
                   SUBNET CIDR      NC ID                                  NC MODE   NC TYPE   NC VERSION
aks-nodepool1-34233576-vmss000000   0               256             routingdomain_fb71a450-e4af-5861-8f2a-7252c613411c_overlaysubnet   192.168.0.0/16   0a64a24c-9110-4bd0-a688-4b575b8e2e91   static    overlay   0
aks-nodepool1-34233576-vmss000001   0               256             routingdomain_fb71a450-e4af-5861-8f2a-7252c613411c_overlaysubnet   192.168.0.0/16   6d37af7f-cc3d-4a29-a4a4-8349e4750beb   static    overlay   0

kubectl get pods --field-selector spec.nodeName=aks-nodepool1-34233576-vmss000000,status.phase=Running -A -o json | jq -r '.items[] | select(.spec.hostNetwork != 'true').status.podIP' | wc -l
21 # Check running Pod IPs
```

```
kubectl run nginx --image=nginx
sleep 10
kubectl get po -owide
nginx            1/1     Running   0          4m33s   192.168.0.192   aks-nodepool1-34233576-vmss000000   <none>           <none>

kubectl logs -n kube-system -l k8s-app=azure-cns
Defaulted container "cns-container" out of: cns-container, cni-installer (init)
2024/09/28 22:26:21 [1] [azure-cnsrequestIPConfigsHandler] Received cns.IPConfigsRequest {DesiredIPAddresses:[] PodInterfaceID:eb4b0c93-eth0 InfraContainerID:eb4b0c9327ed9d298f9bd6dfd0e2e029d120e5fd4866bd3e8bfb47d7eb540d76 OrchestratorContext:[123 34 80 111 100 78 97 109 101 34 58 34 110 103 105 110 120 34 44 34 80 111 100 78 97 109 101 115 112 97 99 101 34 58 34 100 101 102 97 117 108 116 34 125] Ifname: SecondaryInterfacesExist:false}.
2024/09/28 22:26:21 [1] [GetExistingIPConfig] IPConfigExists [false] for pod [eb4b0c93-eth0]
2024/09/28 22:26:21 [1] [updateIPConfigState] Changing IpId [192.168.0.192] state to [Assigned], podInfo [InfraContainerID: [eb4b0c9327ed9d298f9bd6dfd0e2e029d120e5fd4866bd3e8bfb47d7eb540d76], InterfaceID: [eb4b0c93-eth0], Key: [eb4b0c93-eth0], Name: [nginx], Namespace: [default]]. Current config [ID: [192.168.0.192], NCID: [0a64a24c-9110-4bd0-a688-4b575b8e2e91], IPAddress: [192.168.0.192], State: [Available], LastStateTransition: [2024-09-28T21:43:03Z] PodInfo: [%!s(<nil>)]]
2024/09/28 22:26:21 [1] IP config eb4b0c93-eth0 initialized
2024/09/28 22:26:21 [1] [AssignDesiredIPConfigs] Successfully assigned IPs for pod InfraContainerID: [eb4b0c9327ed9d298f9bd6dfd0e2e029d120e5fd4866bd3e8bfb47d7eb540d76], InterfaceID: [eb4b0c93-eth0], Key: [eb4b0c93-eth0], Name: [nginx], Namespace: [default]
2024/09/28 22:26:21 [1] [azure-cnsrequestIPConfigsHandler] Sent cns.IPConfigsRequest {DesiredIPAddresses:[] PodInterfaceID:eb4b0c93-eth0 InfraContainerID:eb4b0c9327ed9d298f9bd6dfd0e2e029d120e5fd4866bd3e8bfb47d7eb540d76 OrchestratorContext:[123 34 80 111 100 78 97 109 101 34 58 34 110 103 105 110 120 34 44 34 80 111 100 78 97 109 101 115 112 97 99 101 34 58 34 100 101 102 97 117 108 116 34 125] Ifname: SecondaryInterfacesExist:false} *cns.IPConfigsResponse &{PodIPInfo:[{PodIPConfig:{IPAddress:192.168.0.192 PrefixLength:16} NetworkContainerPrimaryIPConfig:{IPSubnet:{IPAddress:192.168.0.0 PrefixLength:16} DNSServers:[] GatewayIPAddress:} HostPrimaryIPInfo:{Gateway:10.224.0.1 PrimaryIP:10.224.0.5 Subnet:10.224.0.0/16} NICType:InfraNIC InterfaceName: MacAddress: SkipDefaultRoutes:false Routes:[]}] Response:{ReturnCode:Success Message:}}.
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl: Like Azure CNI Overlay, Kubenet assigns IP addresses to pods from an address space logically different from the VNet
- https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/troubleshoot-network-aks: If using Azure CNI for dynamic IP allocation

## cni.azure.overlay.upgrade

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl#upgrade-an-existing-cluster-to-cni-overlay: azure-ip-masq-agent-config(, exists and is not intentionally in-place) it should be deleted

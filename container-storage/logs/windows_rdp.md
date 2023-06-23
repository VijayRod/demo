These steps in https://learn.microsoft.com/en-us/azure/aks/rdp?tabs=azure-cli are used to deploy a virtual machine with a publicly accessible IP address to the same subnet as your cluster's Windows Server nodes. This allows you to RDP to the cluster nodes. The public IP is obtained as the output of the `az vm create` command mentioned below, which can be used to RDP to the created VM and then to the Windows cluster node. 

```
# Replace values in the below.
WINDOWS_USERNAME=azureuser
WINDOWS_PASSWORD=
rgname=
clustername=akswin
```

```
# Get the subnet ID used by your Windows Server node pool.
CLUSTER_RG=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -o tsv)
VNET_NAME=$(az network vnet list -g $CLUSTER_RG --query [0].name -o tsv)
SUBNET_NAME=$(az network vnet subnet list -g $CLUSTER_RG --vnet-name $VNET_NAME --query [0].name -o tsv)
SUBNET_ID=$(az network vnet subnet show -g $CLUSTER_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

# Create the VM.
PUBLIC_IP_ADDRESS="myVMPublicIP"
az vm create -g $rgname --name myVM --image win2019datacenter --admin-username WINDOWS_USERNAME --admin-password WINDOWS_PASSWORD --subnet $SUBNET_ID --nic-delete-option delete --os-disk-delete-option delete --nsg "" --public-ip-address $PUBLIC_IP_ADDRESS --query publicIpAddress -o tsv

# Enable access in the NSG.
CLUSTER_RG=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -o tsv)
NSG_NAME=$(az network nsg list -g $CLUSTER_RG --query [].name -o tsv)
az network nsg rule create --name tempRDPAccess --resource-group $CLUSTER_RG --nsg-name $NSG_NAME --priority 100 --destination-port-range 3389 --protocol Tcp --description "Temporary RDP access to Windows nodes"
```

## vm

```
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard
ssh azureuser@publicip
```

## vm.app

```
# Replace the below with appropriate values
rgname=rgvm
loc=swedencentral
vm=myVM
image=debian
user=azureuser

# To create a VM and then perform a 'curl' operation to the web server
az group create -n $rgname --location $loc
az vm create -g $rgname -n $vm --image $image \
  --admin-username $user --public-ip-sku Standard
az vm open-port --port 22 -g $rgname -n $vm # ssh
ip=$(az vm show --show-details -g $rgname -n $vm --query publicIps --output tsv)
az vm run-command invoke -g $rgname -n $vm \
   --command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get install -y nginx" --no-wait
az vm open-port --port 80 -g $rgname -n $vm
sleep 30
curl -I $ip
```

```
HTTP/1.1 200 OK
Server: nginx/1.14.2
Date: Wed, 22 Aug 2023 22:59:00 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Wed, 22 Aug 2023 22:58:20 GMT
Connection: keep-alive
ETag: "64e5e64c-264"
Accept-Ranges: bytes
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-cli

## vm.subnet

```
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard --subnet $subnetId
```

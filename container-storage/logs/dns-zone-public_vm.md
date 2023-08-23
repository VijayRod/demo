```
# Replace the below with appropriate values
rgname=testshack3
loc=swedencentral
vnet=myvnet
subnet=backendSubnet
vm=myVM
image=debian
user=azureuser
zone="contoso.net"

# To create a virtual network
az group create -n $rgname -l $loc
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $subnet --subnet-prefixes 10.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $subnet --query id -otsv)
az vm create -g $rgname -n $vm --image $image --admin-username $user --public-ip-sku Standard --subnet $subnetId
ip=$(az vm show --show-details -g $rgname -n $vm --query publicIps --output tsv)
az vm run-command invoke -g $rgname -n $vm \
   --command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get install -y nginx && sudo apt install dnsutils -y" --no-wait
az vm open-port --port 80 -g $rgname -n $vm
sleep 30
curl -I $ip

# To create a DNS zone and add an A record
az network dns zone create -g $rgname -n $zone
az network dns record-set a add-record -g $rgname -z $zone -n www -a $ip
```

```
az network dns record-set list -g $rgname -z $zone
az network dns record-set ns show -g $rgname --zone-name $zone --name @

curl -I $ip
HTTP/1.1 200 OK
Server: nginx/1.14.2

TBD
azureuser@myVM:~$ nslookup contoso.net ns1-34.azure-dns.com
Server:         ns1-34.azure-dns.com
Address:        150.171.10.34#53
*** Can't find contoso.net: No answer
```

- https://learn.microsoft.com/en-us/azure/dns/dns-getstarted-cli

```
rg=rg
az group create -n $rg -l swedencentral
i=0
while [ $i -le 20 ]
do
  echo Number: $i $(date)
  az aks create -g $rg -n aks -onone
  echo $(az aks show -g $rg -n aks --query fqdn -otsv)
  az aks delete -g $rg -n aks -y
  ((i++))
done
```

```
rg=rgsf
az group create -n $rg -l $loc
az sf cluster create -g $rg --certificate-subject-name "sfcert$RANDOM" --vm-password "Pp1!$RANDOM" --vault-name "sfvault$RANDOM" --vm-sku $vmsize

az sf cluster list -g $rg
az sf cluster show -g $rg -c rgsf -otable
```

- https://learn.microsoft.com/en-us/azure/service-fabric/samples-cli

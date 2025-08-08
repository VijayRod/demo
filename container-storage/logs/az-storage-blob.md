> ## blob.create

```
# blob.create
az storage container create --name backups --account-name $storage --auth-mode login
az storage account update -n $storage --allow-blob-public-access true --public-network-access Enabled
az storage account show -n $storage --query '{allowBlobPublicAccess: allowBlobPublicAccess, publicNetworkAccess: publicNetworkAccess}'
```

> ## blob.download

```
# blob.download..azcopy
# azcopy performs parallel transfers by default - up to 3,000 concurrent operations depending on CPU count. The level of parallelism can be configured using the AZCOPY_CONCURRENCY_VALUE environment variable or the --parallel-level command-line parameter.
```

```
# blob.download..curl
# curl performs sequential downloads over a single TCP connection and does not initiate concurrent or parallel connections
# download to a vm for faster upload

# https://ubuntu.com/download/desktop, ~5GB
cd /tmp
curl -L -O https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-desktop-amd64.iso --progress-bar
# curl -L -o foo.bytes https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-desktop-amd64.iso --progress-bar
# wget https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-desktop-amd64.iso
ls -lh ubuntu*

file="ubuntu-24.04.2-desktop-amd64.iso"
token=$(az storage container generate-sas --account-name $storage --name backups --permissions r --expiry $(date -u -d "1 day" '+%Y-%m-%dT%H:%MZ') --auth-mode login --as-user --output tsv); 
echo $token
cd /tmp; rm $file; ls -lh $file
url="https://$storage.blob.core.windows.net/backups/$file?$token"; echo $url
curl -L -O $url
# curl -L -o foo.bytes $url
# curl -L -o /dev/null $url
# curl -L -o /dev/null -w "%{speed_download}\n" $url
# curl -L -O --progress-bar $url
ls -lh $file

```

```
# blob.download..iperf3
# iperf3 performs sequential data transfers over a single TCP connection by default, but supports parallel streams using the -P option to initiate multiple simultaneous connections.

```


```
# blob.download.k8s-node
# using chroot is necessary to save the file on the host
kubectl debug node/aks-nodepool1-23194169-vmss000002 -it --image=ubuntu
chroot /host
cd /tmp
url=
curl -L -o /dev/null $url
```

> ## blob.upload

```
# blob.upload.az-storage
# Contributor/Reader roles are not enough
userId=$(az ad signed-in-user show --query id --output tsv); echo $userId
az role assignment create --assignee $userId --role "Storage Blob Data Owner" --scope $storageId
az storage blob upload --account-name $storage --container-name backups --name cron.deny --file /etc/cron.deny --auth-mode login
```

```
# blob.upload.azcopy
file="ubuntu-24.04.2-desktop-amd64.iso"
$token=$(az storage container generate-sas --account-name $storage --name backups --permissions r --expiry $(date -u -d "1 day" '+%Y-%m-%dT%H:%MZ') --auth-mode login --as-user --output tsv); echo $token
url="https://$storage.blob.core.windows.net/backups/$file?$token"; echo $url
azcopy copy $file $url
```

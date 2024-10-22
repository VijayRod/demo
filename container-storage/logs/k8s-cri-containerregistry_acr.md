## k8s-aks-acr

```
# Replace the below with appropriate values
rgname=secureshack2
registry=imageshack
clustername=aksacr
az group create -n $rgname -l $loc
```

```
# To create an ACR (Azure Container Registry)
az acr create -g $rgname -n $registry --sku basic

# To create a cluster
az aks create -g $rgname -n $clustername --attach-acr $registry -s $vmsize -c 2
az aks get-credentials -g $rgname -n $clustername

# To deploy a pod with an image from the registry
kubectl run ubuntu --image=$registry.azurecr.io/samples/ubuntu
```

```
# kubectl describe po ubuntu
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  14s               default-scheduler  Successfully assigned default/ubuntu to aks-nodepool1-31040111-vmss000000
  Normal   Pulled     10s               kubelet            Successfully pulled image "imageshack.azurecr.io/samples/ubuntu" in 3.027778658s (3.027782658s including waiting)
  Normal   Pulling    9s (x2 over 13s)  kubelet            Pulling image "imageshack.azurecr.io/samples/ubuntu"
  Normal   Created    9s (x2 over 10s)  kubelet            Created container ubuntu
  Normal   Pulled     9s                kubelet            Successfully pulled image "imageshack.azurecr.io/samples/ubuntu" in 100.976602ms (100.996702ms including waiting)
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration

## k8s-aks-acr.debug

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-troubleshoot-login
  
## k8s-aks-acr.check-acr

```
# az aks check-acr -g $rgname -n $clustername --acr $registry
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:36:46Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:36:46Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:36:46Z] ACR location: swedencentral
[2023-08-03T12:36:46Z] Checking managed identity...
[2023-08-03T12:36:46Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:36:46Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:36:47Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:36:47Z]
Your cluster can pull images from imageshack.azurecr.io!

# --debug
urllib3.connectionpool: https://management.azure.com:443 "POST /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerService/managedClusters/aksacr/listClusterUserCredential?api-version=2024-02-01 HTTP/1.1" 200 12953

# az aks check-acr -g $rgname -n $clustername --acr $registry --node-name aks-nodepool1-31040111-vmss000005
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:37:12Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:37:12Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:37:12Z] ACR location: swedencentral
[2023-08-03T12:37:12Z] Checking managed identity...
[2023-08-03T12:37:12Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:37:13Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:37:13Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:37:13Z]
Your cluster can pull images from imageshack.azurecr.io!
```

## k8s-aks-acr.check-acr.canipull

- https://github.com/Azure/aks-canipull
- https://github.com/andyzhangx/demo/blob/master/aks/canipull/README.md - "deprecation: please use az aks check-acr (--node-name) command to throubleshoot ACR connection issue on specific AKS node"

## k8s-aks-acr.image

```
# Check out the Dockerfile section for instructions on how to create and import a custom image.

az acr import -n $registry --source docker.io/library/nginx # Imports an image from another Container Registry. Import removes the need to docker pull, docker tag, docker push.

tbd root@aks-nodepool1-74128781-vmss000000:/# crictl pull imageshack.azurecr.io/library/nginx:latest # GET request to https://imageshack.azurecr.io/oauth2/token?scope=repository%3Alibrary%2Fnginx%3Apull&service=imageshack.azurecr.io: 401 Unauthorized
k run mynginx --image=imageshack.azurecr.io/library/nginx:latest # kubelet  Successfully pulled image "imageshack.azurecr.io/library/nginx:latest"

az acr repository list -n $registry -otable # library/nginx

az acr repository show-tags -n $registry --repository nginx -otable # latest

az acr repository delete -n $registry --repository nginx -y # Are you sure you want to delete the repository 'nginx' and all images under it? (y/n)
```

## k8s-aks-acr.login

```
# earlier
az acr login -n $registry
You may want to use 'az acr login -n imageshack --expose-token' to get an access token, which does not require Docker to be installed.
2024-10-22 18:23:44.394058 An error occurred: DOCKER_COMMAND_ERROR
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

```
az acr login -n imageshack --expose-token
You can perform manual login using the provided access token below, for example: 'docker login loginServer -u 00000000-0000-0000-0000-000000000000 -p accessToken'
{
  "accessToken": "eyredacted_bhqA",
  "loginServer": "imageshack.azurecr.io"
}

accessToken="eyredacted_bhqA"
acrLoginServer=$(az acr show -g $rgname -n $registry --query loginServer -otsv); echo $acrLoginServer # imageshack.azurecr.io
docker login $acrLoginServer -u 00000000-0000-0000-0000-000000000000 -p $accessToken
# Login Succeeded
```

```
# Replace the below with appropriate values
registry=imageshack
```

```
# To pull and tag an image
docker pull ubuntu
docker tag ubuntu $registry.azurecr.io/samples/ubuntu

# To list images
docker image list
REPOSITORY                             TAG       IMAGE ID       CREATED       SIZE
ubuntu                                 latest    5a81c4b8502e   4 weeks ago   77.8MB
imageshack.azurecr.io/samples/ubuntu   latest    5a81c4b8502e   4 weeks ago   77.8MB
```

```
# To login to ACR (Azure Container Registry)
az acr login --name $registry

# To upload an image to a registry 
docker push $registry.azurecr.io/samples/ubuntu
Using default tag: latest
The push refers to repository [imageshack.azurecr.io/samples/ubuntu]
59c56aee1fb4: Pushed
latest: digest: sha256:75399abc111a48bcabcfe40c8fa5d1d44fb99e078ab449338d08f06dad34127e size: 529
```

```
# To list images
az acr repository list --name $registry
[
  "samples/ubuntu"
]

# az acr repository show -n $registry --repository samples/ubuntu
{
  "changeableAttributes": {
    "deleteEnabled": true,
    "listEnabled": true,
    "readEnabled": true,
    "teleportEnabled": false,
    "writeEnabled": true
  },
  "createdTime": "2023-07-27T02:11:58.4238974Z",
  "imageName": "samples/ubuntu",
  "lastUpdateTime": "2023-07-27T02:11:58.4938336Z",
  "manifestCount": 1,
  "registry": "imageshack.azurecr.io",
  "tagCount": 1
}

# az acr repository show -n $registry --image samples/ubuntu
{
  "changeableAttributes": {
    "deleteEnabled": true,
    "listEnabled": true,
    "readEnabled": true,
    "writeEnabled": true
  },
  "createdTime": "2023-07-27T02:11:58.5316473Z",
  "digest": "sha256:75399abc111a48bcabcfe40c8fa5d1d44fb99e078ab449338d08f06dad34127e",
  "lastUpdateTime": "2023-07-27T02:11:58.5316473Z",
  "name": "latest",
  "quarantineState": "Passed",
  "signed": false
}
```

```
# To delete an image
az acr repository delete --name $registry --image samples/ubuntu -y
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-cli

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

```
# Did the image pulling fail on all agent nodes? Could you try another ACR image in the same ACR or a different ACR repository to help narrow down the issue?
# See the section on k8s-node.kubelet.credentials.kubeletidentity to confirm that either the VM Scale Set or the node's /etc/kubernetes/azure.json includes the identityProfile.kubeletidentity.clientId. The clientId is important because crictl uses the kubeletidentity to fetch the image from the registry.

acrLoginServer=$(az acr show -g $rgname -n $registry --query loginServer -otsv)
echo $acrLoginServer # imageshack.azurecr.io

root@aks-nodepool1-74128781-vmss000000:/# nslookup imageshack.azurecr.io
Server:         168.63.129.16
Address:        168.63.129.16#53
Non-authoritative answer:
imageshack.azurecr.io   canonical name = sec.fe.azcr.io.
sec.fe.azcr.io  canonical name = sec-acr-reg.trafficmanager.net.
sec-acr-reg.trafficmanager.net  canonical name = r0910sec-az.swedencentral.cloudapp.azure.com.
Name:   r0910sec-az.swedencentral.cloudapp.azure.com
Address: 1.2.3.4

root@aks-nodepool1-74128781-vmss000000:/# curl https://imageshack.azurecr.io -I
HTTP/1.1 404 Not Found
Server: AzureContainerRegistry
Date: Tue, 22 Oct 2024 18:24:10 GMT
Content-Type: application/octet-stream
Content-Length: 9
Connection: keep-alive
Strict-Transport-Security: max-age=31536000; includeSubDomains

aks-nodepool1-74128781-vmss000000:/# curl -v https://imageshack.azurecr.io
*   Trying 51.12.25.66:443...
* Connected to imageshack.azurecr.io (1.2.3.4) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
* TLSv1.0 (OUT), TLS header, Certificate Status (22):
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS header, Certificate Status (22):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS header, Finished (20):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.2 (OUT), TLS header, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: C=US; ST=WA; L=Redmond; O=Microsoft Corporation; CN=*.azurecr.io
*  start date: Aug 14 03:29:28 2024 GMT
*  expire date: Feb 10 03:29:28 2025 GMT
*  subjectAltName: host "imageshack.azurecr.io" matched cert's "*.azurecr.io"
*  issuer: C=US; O=Microsoft Corporation; CN=Microsoft Azure RSA TLS Issuing CA 03
*  SSL certificate verify ok.
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
> GET / HTTP/1.1
> Host: imageshack.azurecr.io
> User-Agent: curl/7.81.0
> Accept: */*
>
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
< Server: AzureContainerRegistry
< Date: Tue, 22 Oct 2024 18:23:47 GMT
< Content-Type: application/octet-stream
< Content-Length: 9
< Connection: keep-alive
< Strict-Transport-Security: max-age=31536000; includeSubDomains
<
* Connection #0 to host imageshack.azurecr.io left intact

# tbd AcrPull - cluster has been created with a service principal
# https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/aks-triage-container-registry
ASSIGNEE=$(az aks show -g $rg -n aksacr --query servicePrincipalProfile.clientId -o tsv)
az role assignment list --assignee $ASSIGNEE --all -o table

# AcrPull
ASSIGNEE=$(az aks show -g $rgname -n $clustername --query identityProfile.kubeletidentity.clientId -otsv)
az role assignment list --assignee $ASSIGNEE --all -o table
Principal                             Role     Scope
------------------------------------  -------  ---------------------------------------------------------------------------------------------------------------------------------
redactsc-ff96-4106-873c-7f52972f0c52  AcrPull  /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack

# AcrPull (alternative)
acrId=$(az acr show -g $rgname -n $registry --query id -otsv)
echo $acrId # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack
az role assignment list --scope $acrId
[
  {
    "condition": null,
    "conditionVersion": null,
    "createdBy": "9b4c987b-c068-4a9b-96a0-34b7633a607d",
    "createdOn": "2024-10-22T18:46:05.976312+00:00",
    "delegatedManagedIdentityResourceId": null,
    "description": null,
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack/providers/Microsoft.Authorization/roleAssignments/95af4577-d347-4f53-ac82-8e3443b07a84",
    "name": "95af4577-d347-4f53-ac82-8e3443b07a84",
    "principalId": "redacto-e53d-42c3-9385-8e11f066376c",
    "principalName": "redactc-ff96-4106-873c-7f52972f0c52",
    "principalType": "ServicePrincipal",
    "resourceGroup": "rg",
    "roleDefinitionId": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d",
    "roleDefinitionName": "AcrPull",
    "scope": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack",
    "type": "Microsoft.Authorization/roleAssignments",
    "updatedBy": "9b4c987b-c068-4a9b-96a0-34b7633a607d",
    "updatedOn": "2024-10-22T18:46:05.976312+00:00"
  }
]
# az role assignment list --scope $acrId --query [0].principalId -otsv
# Azure Portal: ACR, Access control (IAM), Role assignments, All or Task Function, AcrPull.

az acr show -g $rgname -n $registry --query publicNetworkAccess # "Enabled"
# Azure Portal: ACR, Settings, Network.

tbd crictl pull imageshack.azurecr.io/library/nginx:latest # 401 Unauthorized
kubectl run mynginx --image=imageshack.azurecr.io/library/nginx:latest # Success
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-troubleshoot-login
- https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/aks-triage-container-registry: Verify the connection to the container registry
  
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

## k8s-aks-acr.check-acr.privatecluster

```
rg=rg
registry=imageshack
clustername=aksacr
az acr create -g $rg -n $registry --sku basic
az aks create -g $rg -n aksprivateacr --enable-private-cluster --attach-acr $registry -s $vmsize -c 2 # success

# The error is occurring because the 'check-acr' command is being executed on a machine that isn't connected to the VNet of our private AKS cluster.
# Same error when using Azure Cloud Shell
az aks check-acr -g $rg -n aksprivateacr --acr $registry
The login server endpoint suffix '.azurecr.io' is automatically appended.
Merged "aksprivateacr2" as current context in /tmp/tmpw8dt0pbe
Unable to connect to the server: tls: failed to verify certificate: x509: certificate is valid for *.notebooks.azure.net, not aksprivate-rg-efec8e-sdh56nw0.b313df19-f990-44e7-8fcd-06f1051b18f7.privatelink.swedencentral.azmk8s.io
The command failed with an unexpected error. Here is the traceback:
'serverVersion'
Traceback (most recent call last):
  File "/opt/az/lib/python3.11/site-packages/knack/cli.py", line 233, in invoke
    cmd_result = self.invocation.execute(args)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/az/lib/python3.11/site-packages/azure/cli/core/commands/__init__.py", line 664, in execute
    raise ex
  File "/opt/az/lib/python3.11/site-packages/azure/cli/core/commands/__init__.py", line 731, in _run_jobs_serially
    results.append(self._run_job(expanded_arg, cmd_copy))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/az/lib/python3.11/site-packages/azure/cli/core/commands/__init__.py", line 701, in _run_job
    result = cmd_copy(params)
             ^^^^^^^^^^^^^^^^
  File "/opt/az/lib/python3.11/site-packages/azure/cli/core/commands/__init__.py", line 334, in __call__
    return self.handler(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/az/lib/python3.11/site-packages/azure/cli/core/commands/command_operation.py", line 121, in handler
    return op(**command_args)
           ^^^^^^^^^^^^^^^^^^
  File "/opt/az/lib/python3.11/site-packages/azure/cli/command_modules/acs/custom.py", line 1611, in aks_check_acr
    kubectl_version["serverVersion"]["minor"])
    ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
KeyError: 'serverVersion'

# Similar error while using kubectl on a machine that isn't connected to the VNet of our private AKS cluster.
az aks get-credentials -g $rg -n aksprivateacr
The behavior of this command has been altered by the following extension: aks-preview
Merged "aksprivateacr" as current context in /root/.kube/config
k get ns
E1022 22:49:10.398697    2193 memcache.go:265] couldn't get current server API group list: Get "https://aksprivate-rg-efec8e-sdh56nw0.b313df19-f990-44e7-8fcd-06f1051b18f7.privatelink.swedencentral.azmk8s.io:443/api?timeout=32s": tls: failed to verify certificate: x509: certificate is valid for *.notebooks.azure.net, not aksprivate-rg-efec8e-sdh56nw0.b313df19-f990-44e7-8fcd-06f1051b18f7.privatelink.swedencentral.azmk8s.io

az aks command invoke -g $rg -n aksprivateacr2 --command "kubectl run mynginx --image=imageshack.azurecr.io/library/nginx:latest"
az aks command invoke -g $rg -n aksprivateacr2 --command "kubectl get po" # mynginx   1/1     Running   0          16s
az aks command invoke -g $rg -n aksprivateacr2 --command "kubectl describe po" # Successfully pulled image "imageshack.azurecr.io/library/nginx:latest"
```

## k8s-aks-acr.check-acr.error.Validating image pull permission: FAILED

```
ASSIGNEE=$(az aks show -g $rgname -n $clustername --query identityProfile.kubeletidentity.clientId -otsv)
az role assignment list --assignee $ASSIGNEE --all -o table
Principal                             Role     Scope
------------------------------------  -------  ---------------------------------------------------------------------------------------------------------------------------------
redactc-ff96-4106-873c-7f52972f0c52  AcrPull  /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack

az role assignment delete --assignee $ASSIGNEE --role AcrPull
# (or) az role assignment delete --assignee $ASSIGNEE --scope $acrId # Message "No matched assignments were found to delete" means its already deleted

az aks check-acr -g $rgname -n $clustername --acr $registry
[2024-10-22T18:32:07Z] Validating managed identity existance: SUCCEEDED
[2024-10-22T18:32:08Z] Validating image pull permission: FAILED
[2024-10-22T18:32:08Z] ACR imageshack.azurecr.io rejected token exchange: ACR token exchange endpoint returned error status: 401. body:

az role assignment create --role AcrPull --assignee $ASSIGNEE --scope $acrId
az aks check-acr -g $rgname -n $clustername --acr $registry # Validating image pull permission: SUCCEEDED
```

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

```
# See the section on crictl.image.creds

az acr token create --registry $registry --name MyToken --repository library/nginx content/write content/read --output json
Please store your generated credentials safely. Meanwhile you can use it through "docker login imageshack.azurecr.io -u MyToken -p 7oredacted".
{
  "creationDate": "2024-10-23T18:47:32.351014+00:00",
  "credentials": {
    "certificates": null,
    "passwords": [
      {
        "creationTime": "2024-10-23T18:47:44.493948+00:00",
        "expiry": null,
        "name": "password1",
        "value": "7oredacted"
      },
      {
        "creationTime": "2024-10-23T18:47:44.493966+00:00",
        "expiry": null,
        "name": "password2",
        "value": "Fcredacted"
      }
    ],
    "username": "MyToken"
  },
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack/tokens/MyToken",
  "name": "MyToken",
  "provisioningState": "Succeeded",
  "resourceGroup": "rg",
  "scopeMapId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack/scopeMaps/MyToken-scope-map",
  "status": "enabled",
  "systemData": {
    "createdAt": "2024-10-23T18:47:32.258021+00:00",
    "createdBy": "email@email.com",
    "createdByType": "User",
    "lastModifiedAt": "2024-10-23T18:47:32.258021+00:00",
    "lastModifiedBy": "email@email.com",
    "lastModifiedByType": "User"
  },
  "type": "Microsoft.ContainerRegistry/registries/tokens"
}
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli

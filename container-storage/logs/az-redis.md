## redis

```
rg=rgredis
redis="redis$RANDOM"
az group create -n $rg -l $loc
az redis create -g $rg -n $redis -l $loc --sku Basic --vm-size c0

redisId=$(az redis show -g $rg -n $redis --query id -otsv); echo $redisId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgredis/providers/Microsoft.Cache/Redis/redis3942

redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redis3942.redis.cache.windows.net

# az redis delete -g $rg -n $redis -y
# az group delete -n $rg -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-whats-new
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#scaling-faq
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-planning-faq
- https://redis.io/docs/latest/operate/oss_and_stack/management/config/
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/scripts/create-manage-cache
- https://stackexchange.github.io/StackExchange.Redis/Basics.html
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-management-faq
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-enterprise-tiers

## redis.app.k8s

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes

## redis.app.k8s.example.connect-from-aks.accesskey

```
# This example demonstrates a simpler method of connecting an AKS pod to the redis cache using an access key, rather than utilizing a Microsoft Entra (workload) identity.

rg=rgredis
redis="redis$RANDOM"
az group create -n $rg -l $loc
az redis create -g $rg -n $redis -l $loc --sku Basic --vm-size c0

az aks create -g $rg -n aks -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#run-sample-locally
# https://github.com/Azure-Samples/azure-cache-redis-samples/tree/main/tutorial/connect-from-aks/ConnectFromAKS
cd /tmp
rm -rf /tmp/azure-cache-redis-samples
git clone https://github.com/Azure-Samples/azure-cache-redis-samples.git
cd /tmp/azure-cache-redis-samples/tutorial/connect-from-aks/ConnectFromAKS

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#configure-your-workload-that-connects-to-azure-cache-for-redis
registry="registry$RANDOM"
az acr create -g $rg -n $registry --sku basic
az aks update -g $rg -n aks --attach-acr $registry
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
acrAccessToken=$(az acr login -n $registry --expose-token | jq .accessToken); echo $acrAccessToken
docker login $acrLoginServer -u 00000000-0000-0000-0000-000000000000 # copy the value of $acrAccessToken (leave out the double quotes) and hit Enter
az acr build --registry $registry --image redis-sample .

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#run-your-workload
# rg=; redis=; registry=
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
echo $rg, $redis - $redisHostName, $registry - $acrLoginServer # , $redisKey
kubectl delete po entrademo-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
 name: entrademo-pod
spec:
 containers:
 - name: entrademo-container
   image: $acrLoginServer/redis-sample
   imagePullPolicy: Always
   command: ["dotnet", "ConnectFromAKS.dll"] 
   resources:
     limits:
       memory: "256Mi"
       cpu: "500m"
     requests:
       memory: "128Mi"
       cpu: "250m"
   env:
   - name: AUTHENTICATION_TYPE
     value: "ACCESS_KEY" # change to ACCESS_KEY to authenticate using access key
   - name: REDIS_HOSTNAME
     value: $redisHostName
   - name: REDIS_ACCESSKEY
     value: $redisKey 
   - name: REDIS_PORT
     value: "6380"
 restartPolicy: Never
EOF
sleep 30
kubectl logs entrademo-pod # Connecting to {cacheHostName} with an access key.. Retrieved value from Redis: Hello, Redis!
kubectl get po entrademo-pod
```

## redis.app.k8s.example.connect-from-aks.accesskey.istio|clustered

```
# This example demonstrates a simpler method of connecting an AKS pod to the redis cache using an access key, bypassing the need for a workload identity. The AKS cluster is set up with Istio, and there's one pod equipped with the Istio sidecar and another without it. Plus, the Redis cache we're using is of the premium, sharded (clustered) variety.
# See the section on k8s-servicemesh-istio.app.redis

az redis delete -g $rg -n $redis -y
az redis create -g $rg -n $redis -l $loc --sku premium --vm-size P1 --shard-count 2 # Premium P1 (6 GB) Redis cache configuration with clustering enabled, and it's setup with 2 shards, bringing the total capacity to 12 GB
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)

az aks mesh enable -g $rg -n aks # Istio
kubectl delete po --all

# rg=; redis=; registry=
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
echo $rg, $redis - $redisHostName, $registry - $acrLoginServer # , $redisKey
po=redis-sample
ns=default
kubectl delete po $po
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
 name: $po
 namespace: $ns
spec:
 containers:
 - name: redis-sample
   image: $acrLoginServer/redis-sample
   imagePullPolicy: Always
   command: ["dotnet", "ConnectFromAKS.dll"] 
   env:
   - name: AUTHENTICATION_TYPE
     value: "ACCESS_KEY" # change to ACCESS_KEY to authenticate using access key
   - name: REDIS_HOSTNAME
     value: $redisHostName
   - name: REDIS_ACCESSKEY
     value: $redisKey 
   - name: REDIS_PORT
     value: "6380"
 restartPolicy: Never
EOF
sleep 30
kubectl logs -n $ns $po # Connecting to {cacheHostName} with an access key.. Retrieved value from Redis: Hello, Redis!
kubectl get po -n $ns $po

# rg=; redis=; registry=
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
echo $rg, $redis - $redisHostName, $registry - $acrLoginServer # , $redisKey
po=redis-sample-istio
ns=istio-ns
istioRevision=$(az aks show -g $rg -n aks --query serviceMeshProfile.istio.revisions -otsv); echo $istioRevision
kubectl delete po -ns $ns $po
kubectl delete ns $ns
kubectl create ns $ns
kubectl label namespace $ns istio.io/rev=$istioRevision
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
 annotations:
   traffic.sidecar.istio.io/excludeOutboundPorts: "15000,15001,15004,15006,15008,15009,15020"
 name: $po
 namespace: $ns
spec:
 containers:
 - name: redis-sample
   image: $acrLoginServer/redis-sample
   imagePullPolicy: Always
   command: ["dotnet", "ConnectFromAKS.dll"] 
   env:
   - name: AUTHENTICATION_TYPE
     value: "ACCESS_KEY" # change to ACCESS_KEY to authenticate using access key
   - name: REDIS_HOSTNAME
     value: $redisHostName
   - name: REDIS_ACCESSKEY
     value: $redisKey 
   - name: REDIS_PORT
     value: "6380"
 restartPolicy: Never
EOF
sleep 30
kubectl logs -n $ns $po -c redis-sample # RedisConnectionException
kubectl get po -n $ns $po
```

## redis.app.k8s.example.connect-from-aks.managedidentity

```
# If there's no specific need for managed identity (workload identity), you might want to go with connect-from-aks.accesskey as your go-to option.

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#set-up-an-azure-cache-for-redis-instance
rg=rgredis
redis="redis$RANDOM"
az group create -n $rg -l $loc
az redis create -g $rg -n $redis -l $loc --sku Basic --vm-size c0

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#configure-your-aks-cluster
# Set up an AKS cluster with OIDC and workload identity. This includes creating a user assigned managed identity, setting up a service account with this identity, and establishing a federated identity credential.

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#set-up-an-azure-cache-for-redis-instance
userIdentityName=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query name -otsv); echo $userIdentityName
userIdentityPrincipalId=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query principalId -otsv); echo $userIdentityPrincipalId
az redis access-policy-assignment create -g $rg -n $redis --access-policy-name "Data Owner" --object-id $userIdentityPrincipalId --object-id-alias $userIdentityName --policy-assignment-name $userIdentityPrincipalId
# az redis access-policy-assignment list -g $rg -n $redis

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#run-sample-locally
# https://github.com/Azure-Samples/azure-cache-redis-samples/tree/main/tutorial/connect-from-aks/ConnectFromAKS
cd /tmp
rm -rf /tmp/azure-cache-redis-samples
git clone https://github.com/Azure-Samples/azure-cache-redis-samples.git
cd /tmp/azure-cache-redis-samples/tutorial/connect-from-aks/ConnectFromAKS

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#configure-your-workload-that-connects-to-azure-cache-for-redis
registry="registry$RANDOM"
az acr create -g $rg -n $registry --sku basic
az aks update -g $rg -n $CLUSTER_NAME --attach-acr $registry
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
acrAccessToken=$(az acr login -n $registry --expose-token | jq .accessToken); echo $acrAccessToken
docker login $acrLoginServer -u 00000000-0000-0000-0000-000000000000 #### This step needs you to paste the password. Copy the value of $acrAccessToken (leave out the double quotes) and hit Enter
az acr build --registry $registry --image redis-sample .

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#run-your-workload
# rg=; redis=; registry=
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
echo $rg, $redis - $redisHostName, $registry - $acrLoginServer # , $redisKey
kubectl delete po entrademo-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
 name: entrademo-pod
 labels:
   azure.workload.identity/use: "true"  # Required. Only pods with this label can use workload identity.
spec:
 serviceAccountName: workload-identity-sa
 containers:
 - name: entrademo-container
   image: $acrLoginServer/redis-sample
   imagePullPolicy: Always
   command: ["dotnet", "ConnectFromAKS.dll"] 
   resources:
     limits:
       memory: "256Mi"
       cpu: "500m"
     requests:
       memory: "128Mi"
       cpu: "250m"
   env:
   - name: AUTHENTICATION_TYPE
     value: "ACCESS_KEY" # change to ACCESS_KEY to authenticate using access key
   - name: REDIS_HOSTNAME
     value: $redisHostName
   - name: REDIS_ACCESSKEY
     value: $redisKey 
   - name: REDIS_PORT
     value: "6380"
 restartPolicy: Never
EOF
sleep 30
kubectl logs entrademo-pod # Connecting to {cacheHostName} with an access key.. Retrieved value from Redis: Hello, Redis!
kubectl get po entrademo-pod

tbd (Invalid authentication type!)
kubectl delete po entrademo-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
 name: entrademo-pod
 labels:
   azure.workload.identity/use: "true"  # Required. Only pods with this label can use workload identity.
spec:
 serviceAccountName: workload-identity-sa
 containers:
 - name: entrademo-container
   image: $acrLoginServer/redis-sample
   imagePullPolicy: Always
   command: ["dotnet", "ConnectFromAKS.dll"] 
   resources:
     limits:
       memory: "256Mi"
       cpu: "500m"
     requests:
       memory: "128Mi"
       cpu: "250m"
   env:
   - name: AUTHENTICATION_TYPE
     value: "MANAGED_IDENTITY" # change to ACCESS_KEY to authenticate using access key
   - name: REDIS_HOSTNAME
     value: $redisHostName
   - name: REDIS_ACCESSKEY
     value: "your access key" 
   - name: REDIS_PORT
     value: "6380"
 restartPolicy: Never
EOF
sleep 30
kubectl logs entrademo-pod # Invalid authentication type!
kubectl get po entrademo-pod
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started

## redis.app.k8s.example.opensource

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-redis bitnami/redis-cluster
export REDIS_PASSWORD=$(kubectl get secret --namespace "default" my-redis-redis-cluster -o jsonpath="{.data.redis-password}" | base64 --decode)
```

- https://techcommunity.microsoft.com/t5/apps-on-azure-blog/run-scalable-and-resilient-redis-with-kubernetes-and-azure/ba-p/3247956

## redis.app.net

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-core-quickstart
- https://stackexchange.github.io/StackExchange.Redis/Basics.html

## redis.billing

- https://azure.microsoft.com/en-us/pricing/details/cache/
  
## redis.debug

```
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redis3942.redis.cache.windows.net

nslookup redis3942.redis.cache.windows.net
Non-authoritative answer:
redis3942.redis.cache.windows.net       canonical name = sec-49818-991148232.vnet.redis.cache.windows.net.
Name:   sec-49818-991148232.vnet.redis.cache.windows.net
Address: 135.225.125.29

telnet redis3942.redis.cache.windows.net 6380 # ssl port
Trying 135.225.125.29...
Connected to sec-49818-991148232.vnet.redis.cache.windows.net.
Escape character is '^]'.

telnet redis3942.redis.cache.windows.net 6379 # non-ssl port
Trying 135.225.125.29...

dig redis3942.redis.cache.windows.net
; <<>> DiG 9.16.48-Ubuntu <<>> redis3942.redis.cache.windows.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27650
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;redis3942.redis.cache.windows.net. IN  A
;; ANSWER SECTION:
redis3942.redis.cache.windows.net. 120 IN CNAME sec-49818-991148232.vnet.redis.cache.windows.net.
sec-49818-991148232.vnet.redis.cache.windows.net. 120 IN A 135.225.125.29
;; Query time: 59 msec
;; SERVER: 10.255.255.254#53(10.255.255.254)
;; WHEN: Thu Oct 24 14:07:41 UTC 2024
;; MSG SIZE  rcvd: 117

az redis show -g $rg -n $redis
  "instances": [
    {
      "isMaster": true,
      "isPrimary": true,
      "nonSslPort": null,
      "shardId": null,
      "sslPort": 15000,
      "zone": null
    }
  ],
  "linkedServers": [],
  "location": "Sweden Central",
  "minimumTlsVersion": null,
  "name": "redis3942",
  "port": 6379,
  "privateEndpointConnections": null,
  "provisioningState": "Succeeded",
  "publicNetworkAccess": "Enabled",
```

- https://redis.io/docs/latest/operate/oss_and_stack/management/troubleshooting/
- https://redis.io/docs/latest/operate/oss_and_stack/management/debugging/
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-troubleshoot-connectivity
- https://techcommunity.microsoft.com/t5/azure-paas-blog/troubleshooting-azure-redis-connectivity-issues/ba-p/1450361: non-SSL port 6379 and SSL port 6380 using REDIS CLI tool. To test the connectivity to non-SSL port, kindly use (redis-cli)
- https://techcommunity.microsoft.com/t5/azure-paas-blog/azure-redis-timeouts-network-issues/ba-p/2022222

## redis.debug.connect

```
Azure portal: navigate to the Azure Cache for Redis resource, Keys, Show Access Keys. This has the conection strings with port numbers.

nc -v redis3697.redis.cache.windows.net 6380
Connection to redis3697.redis.cache.windows.net (135.225.122.181) 6380 port [tcp/*] succeeded!
```

- https://stackexchange.github.io/StackExchange.Redis/Basics.html: default port (6379)
- https://stackexchange.github.io/StackExchange.Redis/Configuration.html: Endpoints without an explicit port will use 6379 if ssl is not enabled, and 6380 if ssl is enabled.
- https://techcommunity.microsoft.com/t5/azure-paas-blog/troubleshooting-azure-redis-connectivity-issues/ba-p/1450361: non-SSL port 6379 and SSL port 6380
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#how-do-i-connect-to-my-cache-when-clustering-is-enabled: You can connect to your cache using the same endpoints, ports, and keys that you use when connecting to a cache that doesn't have clustering enabled. Redis manages the clustering on the backend so you don't have to manage it from your client.
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale?#can-i-directly-connect-to-the-individual-shards-of-my-cache: For non-TLS Premium tier caches, ports are available in the 130XX range. For TLS enabled Premium tier caches, ports are available in the 150XX range

## redis.spec.cluster

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/scripts/create-manage-premium-cache-cluster: two shards (--shard-count 2)

## redis.spec.other.access-policy

```
az redis access-policy list -g $rg -n $redis
az redis access-policy list -g $rg -n $redis -otable
Name              Permissions                                                              ProvisioningState    ResourceGroup    TypePropertiesType
----------------  -----------------------------------------------------------------------  -------------------  ---------------  --------------------
Data Owner        +@all allkeys                                                            Succeeded            rgredis          BuiltIn
Data Contributor  +@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys    Succeeded            rgredis          BuiltIn
Data Reader       +@read +@connection +cluster|info +cluster|nodes +cluster|slots allkeys  Succeeded            rgredis          BuiltIn
```

- https://learn.microsoft.com/en-us/cli/azure/redis/access-policy
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure-role-based-access-control

## redis.spec.other.access-policy.assignment

```
# Azure Portal: redis, Settings, Authentication, Microsoft Entra Authentication.

userIdentityName=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query name -otsv); echo $userIdentityName
userIdentityPrincipalId=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query principalId -otsv); echo $userIdentityPrincipalId
az redis access-policy-assignment create -g $rg -n $redis --access-policy-name "Data Owner" --object-id $userIdentityPrincipalId --object-id-alias $userIdentityName --policy-assignment-name $userIdentityPrincipalId
# az redis access-policy-assignment delete -g $rg -n $redis --policy-assignment-name $userIdentityPrincipalId

az redis access-policy-assignment list -g $rg -n $redis
[
  {
    "accessPolicyName": "Data Owner",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgredis/providers/Microsoft.Cache/Redis/redis20262/accessPolicyAssignments/3b019cde-7176-4100-8f7a-60388d9fcfd7",
    "name": "3b019cde-7176-4100-8f7a-60388d9fcfd7",
    "objectId": "3b019cde-7176-4100-8f7a-60388d9fcfd7",
    "objectIdAlias": "myIdentitywork",
    "provisioningState": "Succeeded",
    "resourceGroup": "rgredis",
    "type": "Microsoft.Cache/Redis/accessPolicyAssignments"
  }
]
```

- https://learn.microsoft.com/en-us/cli/azure/redis/access-policy-assignment#az-redis-access-policy-assignment-list

## redis.spec.other.key

```
# Apps have the option to connect to Redis by using either a user-assigned managed identity or an access key

redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey); # echo redisKey
```

## redis.spec.sku aka tier

```

```
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview#choosing-the-right-tier
- https://azure.microsoft.com/en-us/pricing/details/cache/

## redis.spec.sku-scaling

```
# Recreating the Redis cache using the necessary SKU might actually be faster

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#prerequisiteslimitations-of-scaling-azure-cache-for-redis: You can't scale from a Basic cache directly to a Premium cache. First, scale from Basic to Standard
redis="redis$RANDOM"
az redis create -g $rg -n $redis -l $loc --sku Basic --vm-size c0
az redis update -g $rg -n $redis --sku standard
tbd redisProvisionState=Scaling; while [[ $redisProvisionState -eq "Scaling" ]]; do sleep 5; redisProvisionState=$(az redis show -g $rg -n $redis --query provisioningState -otsv); echo $(date) - $redisProvisionState; done
tbd az redis update -g $rg -n $redis --set "sku.name"="Premium" "sku.capacity"="1" "sku.family"="P"
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#prerequisiteslimitations-of-scaling-azure-cache-for-redis

## redis.spec.vm-size

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#what-is-the-largest-cache-size-i-can-create
- https://azure.microsoft.com/en-us/pricing/details/cache/

## redis.tools.client

- https://aka.ms/redisclients
- https://redis.io/docs/latest/develop/connect/clients/

## redis.tools.client.redis-cli

```
apt update -y && apt install redis-tools -y

redis-cli -h
redis-cli -h redis3697.redis.cache.windows.net -p 6380 # redis3697.redis.cache.windows.net:6380> # quit/exit
```

- https://techcommunity.microsoft.com/t5/azure-paas-blog/troubleshooting-azure-redis-connectivity-issues/ba-p/1450361
- https://techcommunity.microsoft.com/t5/azure-paas-blog/connect-to-azure-cache-for-redis-using-ssl-port-6380-from-linux/ba-p/1186109

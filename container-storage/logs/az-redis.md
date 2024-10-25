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

## redis.app.k8s

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes

## redis.app.k8s.example.connect-from-aks

```
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
git clone https://github.com/Azure-Samples/azure-cache-redis-samples.git
cd /tmp/azure-cache-redis-samples/tutorial/connect-from-aks/ConnectFromAKS

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#configure-your-workload-that-connects-to-azure-cache-for-redis
registry=imageshack
az acr create -g $rg -n $registry --sku basic
az aks update -g $rg -n $CLUSTER_NAME --attach-acr $registry
acrLoginServer=$(az acr show -g $rg -n $registry --query loginServer -otsv); echo $acrLoginServer
acrAccessToken=$(az acr login -n $registry --expose-token | jq .accessToken); echo $acrAccessToken
docker login $acrLoginServer -u 00000000-0000-0000-0000-000000000000 # copy the value of $acrAccessToken (leave out the double quotes) and hit Enter
az acr build --registry $registry --image redis-sample .

# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started#run-your-workload
redisHostName=$(az redis show -g $rg -n $redis --query hostName -otsv); echo $redisHostName
redisKey=$(az redis list-keys -g $rg -n $redis | jq .primaryKey)
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
kubectl logs entrademo-pod
kubectl get po entrademo-pod
# Connecting to {cacheHostName} with an access key.. Retrieved value from Redis: Hello, Redis!

tbd
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
kubectl logs entrademo-pod
kubectl get po entrademo-pod # Invalid authentication type!
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-tutorial-aks-get-started





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

## redis.spec.vm-size

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#what-is-the-largest-cache-size-i-can-create
- https://azure.microsoft.com/en-us/pricing/details/cache/

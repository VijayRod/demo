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

az redis delete -g $rg -n $redis -y
# az group delete -n $rg -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-whats-new
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#scaling-faq
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-planning-faq
- https://redis.io/docs/latest/operate/oss_and_stack/management/config/
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/scripts/create-manage-cache

## redis.app.k8s

```
rg=rgredis
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize --enable-asm -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
# az aks mesh enable -g $rg -n aks
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes

## redis.app.k8s.example

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

## redis.spec.sku aka tier

```

```
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview#choosing-the-right-tier
- https://azure.microsoft.com/en-us/pricing/details/cache/

## redis.spec.vm-size

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale#what-is-the-largest-cache-size-i-can-create
- https://azure.microsoft.com/en-us/pricing/details/cache/

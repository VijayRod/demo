```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksloganalytics -a monitoring -s $vmsize -c 1
az aks get-credentials -g $rg -n aksloganalytics --overwrite-existing
```

```
workspaceId=$(az aks show -g $rg -n aksloganalytics --query addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID -otsv)
echo $workspaceId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/defaultresourcegroup-sec/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-redacts-1111-1111-1111-111111111111-sec
# This workspace was already existing
# az configure -l # []

az monitor log-analytics workspace show --id $workspaceId
{
  "createdDate": "2024-07-03T16:26:35.4465114Z",
  "customerId": "627f1319-f809-4d6c-9899-f5aae50bcf04",
  "etag": "\"c6007779-0000-4700-0000-66857bbf0000\"",
  "features": {
    "enableLogAccessUsingOnlyResourcePermissions": true
  },
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/defaultresourcegroup-sec/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-redacts-1111-1111-1111-111111111111-sec",
  "location": "swedencentral",
  "modifiedDate": "2024-07-03T16:26:39.7589435Z",
  "name": "defaultworkspace-redacts-1111-1111-1111-111111111111-sec",
  "provisioningState": "Succeeded",
  "publicNetworkAccessForIngestion": "Enabled",
  "publicNetworkAccessForQuery": "Enabled",
  "resourceGroup": "defaultresourcegroup-sec",
  "retentionInDays": 30,
  "sku": {
    "lastSkuUpdate": "2024-07-03T16:26:35.4465114Z",
    "name": "PerGB2018"
  },
  "type": "Microsoft.OperationalInsights/workspaces",
  "workspaceCapping": {
    "dailyQuotaGb": -1.0,
    "dataIngestionStatus": "RespectQuota",
    "quotaNextResetTime": "2024-07-04T15:00:00Z"
  }
}

az monitor account list #-otable
[
  {
    "accountId": "a410095c-96b3-498e-a8c0-e84b72862175",
    "defaultIngestionSettings": {
      "dataCollectionEndpointResourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MA_defaultazuremonitorworkspace-sec_swedencentral_managed/providers/Microsoft.Insights/dataCollectionEndpoints/defaultazuremonitorworkspace-sec",
      "dataCollectionRuleResourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MA_defaultazuremonitorworkspace-sec_swedencentral_managed/providers/Microsoft.Insights/dataCollectionRules/defaultazuremonitorworkspace-sec"
    },
    "etag": "\"9400ec61-0000-4700-0000-66857bc60000\"",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/defaultresourcegroup-sec/providers/microsoft.monitor/accounts/defaultazuremonitorworkspace-sec",
    "location": "swedencentral",
    "metrics": {
      "internalId": "mac_a410095c-96b3-498e-a8c0-e84b72862175",
      "prometheusQueryEndpoint": "https://defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com"
    },
    "name": "defaultazuremonitorworkspace-sec",
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled",
    "resourceGroup": "defaultresourcegroup-sec",
    "systemData": {
      "createdAt": "2024-07-03T16:26:34.1434294Z",
      "createdBy": "myemail@office.com",
      "createdByType": "User",
      "lastModifiedAt": "2024-07-03T16:26:34.1434294Z",
      "lastModifiedBy": "myemail@office.com",
      "lastModifiedByType": "User"
    },
    "type": "Microsoft.Monitor/accounts"
  },
```  

- https://stackoverflow.com/questions/70236149/why-does-azure-create-the-defaultresourcegroup-weu-resource-group-and-the-log: Default workspace

```  
# ping defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
PING s-part-0024.t-0009.t-msedge.net (13.107.246.52) 56(84) bytes of data.

# dig defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com

; <<>> DiG 9.16.48-Ubuntu <<>> defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57395
;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com. IN A

;; ANSWER SECTION:
defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com. 300 IN CNAME macdp-prod-sec.trafficmanager.net.
macdp-prod-sec.trafficmanager.net. 60 IN CNAME  macdp-afd-prod-sec-g9fpcrcgcyhjb9hq.b01.azurefd.net.
macdp-afd-prod-sec-g9fpcrcgcyhjb9hq.b01.azurefd.net. 60 IN CNAME shed.dual-low.s-part-0024.t-0009.t-msedge.net.
shed.dual-low.s-part-0024.t-0009.t-msedge.net. 32 IN CNAME s-part-0024.t-0009.t-msedge.net.
s-part-0024.t-0009.t-msedge.net. 35 IN  A       13.107.246.52

;; Query time: 139 msec
;; SERVER: 10.255.255.254#53(10.255.255.254)
;; WHEN: Thu Sep 05 18:58:15 UTC 2024
;; MSG SIZE  rcvd: 316

# A laptop in Portugal connected to this POP location IP address
# curl https://defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
{"error":{"code":"PathNotFound","message":"Path not found"}}
# telnet defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com 443
Trying 13.107.246.52...
Connected to s-part-0024.t-0009.t-msedge.net.
Escape character is '^]'.

# The worker node in Sweden connected to this POP location IP address
aks-nodepool1-19134489-vmss000000:/# curl https://defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
{"error":{"code":"PathNotFound","message":"Path not found"}}
aks-nodepool1-19134489-vmss000000:/# telnet defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com 443
Trying 13.107.246.53...
Connected to s-part-0025.t-0009.t-msedge.net.
Escape character is '^]'.

tbd
kubectl logs -n kube-system -l k8s-app=metrics-server
kubectl logs -n kube-system -l component=ama-logs-agent -c ama-logs
kubectl logs -n kube-system -l component=ama-logs-agent -c ama-logs-prometheus
```
  
- https://learn.microsoft.com/en-us/answers/questions/296886/how-does-azure-cdn-find-closest-location-to-a-clie: Azure Standard Microsoft CDN uses Anycast IPs, so the POP location IP addresses are the same globally. If you perform a Dig/ping on any Azure CDN endpoint, you can see the same 2 Anycast IP addresses. Geo POP edge the request landed
- https://learn.microsoft.com/en-us/azure/cdn/cdn-overview#how-it-works: POP edge
- https://learn.microsoft.com/en-us/azure/cdn/cdn-pop-abbreviations
- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress: analytics / metrics

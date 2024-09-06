```
# s-part-0024.t-0009.t-msedge.net

az monitor account create -g $rg -n monitor
az monitor account show -g $rg -n monitor
az monitor account list #-otable

    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/defaultresourcegroup-sec/providers/microsoft.monitor/accounts/defaultazuremonitorworkspace-sec",
    "location": "swedencentral",
    "metrics": {
      "internalId": "mac_a410095c-96b3-498e-a8c0-e84b72862175",
      "prometheusQueryEndpoint": "https://defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com"

ping defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
PING s-part-0024.t-0009.t-msedge.net (13.107.246.52) 56(84) bytes of data.

dig defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com
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

# A laptop connected to this POP location IP address
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
```
  
- https://learn.microsoft.com/en-us/answers/questions/296886/how-does-azure-cdn-find-closest-location-to-a-clie: Azure Standard Microsoft CDN uses Anycast IPs, so the POP location IP addresses are the same globally. If you perform a Dig/ping on any Azure CDN endpoint, you can see the same 2 Anycast IP addresses. Geo POP edge the request landed
- https://learn.microsoft.com/en-us/azure/cdn/cdn-overview: distributed network of servers that can efficiently deliver web content to users. A content delivery network store cached content on edge servers in point of presence (POP) locations that are close to end users, to minimize latency.
- https://learn.microsoft.com/en-us/azure/cdn/cdn-overview#how-it-works: POP edge
- https://learn.microsoft.com/en-us/azure/frontdoor/front-door-cdn-comparison#service-comparison
- https://learn.microsoft.com/en-us/azure/cdn/cdn-pop-abbreviations
- https://learn.microsoft.com/en-us/azure/cdn/cdn-pop-locations
- https://azure.status.microsoft/en-us/status

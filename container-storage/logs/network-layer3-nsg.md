## nsg

```
az network nsg create -g $rg -n aks-agentpools-nsg
az network nsg rule create -g $rg --nsg-name aks-agentpools-nsg -n DenyAllOutBound-my --priority 100 --access Deny --direction Outbound --protocol "*" --destination-port-ranges "*" --no-wait
az network vnet subnet update -g $rg --vnet-name $vnet -n np2 --nsg aks-agentpools-nsg
```

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network nsg list -g $noderg -otable
az network nsg show -g $noderg -n aks-agentpool-37790187-nsg
```

- https://learn.microsoft.com/en-us/azure/security/fundamentals/network-overview#network-security-rules-nsgs
- https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
- https://learn.microsoft.com/en-us/azure/well-architected/security/networking: Because network security groups work at layers 3 and 4 on the Open Systems Interconnection (OSI) stack
- https://learn.microsoft.com/en-us/azure/network-watcher/vnet-flow-logs-overview: Virtual network flow logs are a feature of Azure Network Watcher. Virtual network flow logs overcome some of the limitations of Network security group flow logs.

## nsg.flowlog (network watcher)

```
# https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-cli
nsg=
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  

az network watcher flow-log update -g $noderg --nsg $nsg -n myFlowLog --log-version 2

az network watcher flow-log list -l $loc --out table

az network watcher flow-log show -g $noderg --nsg $nsg -n myFlowLog
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_swedencentral/flowLogs/myFlowLog

az group list -otable
Name                                                                 Location       Status
-------------------------------------------------------------------  -------------  ---------
NetworkWatcherRG                                                     swedencentral  Succeeded

# create - See the section on nsg.flowlog.create.workspace

# disable (temporary)
az network watcher flow-log update -g $noderg --nsg $nsg -n myFlowLog --storage-account $storageId --traffic-analytics false --workspace $workspaceId
az network watcher flow-log update -g $noderg --nsg $nsg -n myFlowLog --storage-account $storageId --enabled false

# delete
az network watcher flow-log delete --name myFlowLog -l $loc --no-wait true
```

## nsg.flowlog.create.storageaccount

```
# See the section on nsg.flowlog.create.workspace for create

# Instead of just setting up the storage account, enable traffic analytics with 'az network watcher flow-log create --traffic-analytics' because it's easier to query
storage="storage$RANDOM$RANDOM"
az storage account create -g $rg -n $storage
storageId=$(az storage account show -g $rg -n $storage --query id -otsv); echo $storageId
az network watcher flow-log create -g $noderg --nsg $nsg -n myFlowLog --storage-account $storageId --log-version 2

# https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-cli#download-a-flow-log
# Azure portal, go to the storage account, Storage browser, Blob containers, insights-logs-networksecuritygroupflowevent
## https://storage120161285.blob.core.windows.net/insights-logs-networksecuritygroupflowevent/resourceId=/SUBSCRIPTIONS/redacts-1111-1111-1111-111111111111/RESOURCEGROUPS/MC_RG_ASKNAT_SWEDENCENTRAL/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/AKS-AGENTPOOL-42418909-NSG/y=2024/m=11/d=21/h=15/m=00/macAddress=6045BDACE2FA/PT1H.json
root@aks-nodepool1-26864853-vmss000000:/# ip addr show eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 60:45:bd:e9:86:94 brd ff:ff:ff:ff:ff:ff
    
--log-version 1
PT1H.json
{
	"records": [
		{
			"time": "2024-11-21T18:31:06.9240210Z",
			"systemId": "90487218-89e5-47b5-a4b8-138eb46e56e4",
			"macAddress": "6045BDACE2FA",
			"category": "NetworkSecurityGroupFlowEvent",
			"resourceId": "/SUBSCRIPTIONS/redacts-1111-1111-1111-111111111111/RESOURCEGROUPS/MC_RG_ASKNAT_SWEDENCENTRAL/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/AKS-AGENTPOOL-42418909-NSG",
			"operationName": "NetworkSecurityGroupFlowEvents",
			"properties": {
				"Version": 1,
				"flows": [
					{
						"rule": "DefaultRule_AllowVnetOutBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732203050,10.224.0.4,10.224.0.6,46992,19100,T,O,A"
								]
							}
						]
					}
				]
			}
		},
		{
			"time": "2024-11-21T18:32:06.9320808Z",
			"systemId": "90487218-89e5-47b5-a4b8-138eb46e56e4",
			"macAddress": "6045BDACE2FA",
			"category": "NetworkSecurityGroupFlowEvent",
			"resourceId": "/SUBSCRIPTIONS/redacts-1111-1111-1111-111111111111/RESOURCEGROUPS/MC_RG_ASKNAT_SWEDENCENTRAL/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/AKS-AGENTPOOL-42418909-NSG",
			"operationName": "NetworkSecurityGroupFlowEvents",
			"properties": {
				"Version": 1,
				"flows": [
					{
						"rule": "DefaultRule_AllowVnetInBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732203103,10.244.2.2,10.244.0.2,53030,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,33267,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,34088,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,35664,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,37787,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,43958,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,55282,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.8,40148,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.8,37414,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,32833,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,54710,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,34632,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,34525,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,49429,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.8,43444,53,U,I,A",
									"1732203103,10.244.2.2,10.244.0.2,46824,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.8,51081,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.8,43423,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,37741,53,U,I,A",
									"1732203104,10.244.1.2,10.244.0.2,48314,53,U,I,A"
								]
							}
						]
					},
					{
						"rule": "DefaultRule_AllowVnetOutBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732203081,10.224.0.4,10.224.0.6,56098,20257,T,O,A",
									"1732203110,10.224.0.4,10.224.0.6,58968,19100,T,O,A"
								]
							}
						]
					}
				]
			}
		},

--log-version 2
PT1H.json
{
	"records": [
		{
			"time": "2024-11-21T19:00:07.0757201Z",
			"systemId": "90487218-89e5-47b5-a4b8-138eb46e56e4",
			"macAddress": "6045BDACE2FA",
			"category": "NetworkSecurityGroupFlowEvent",
			"resourceId": "/SUBSCRIPTIONS/redacts-1111-1111-1111-111111111111/RESOURCEGROUPS/MC_RG_ASKNAT_SWEDENCENTRAL/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/AKS-AGENTPOOL-42418909-NSG",
			"operationName": "NetworkSecurityGroupFlowEvents",
			"properties": {
				"Version": 1,
				"flows": [
					{
						"rule": "DefaultRule_AllowInternetOutBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732204744,10.224.0.4,4.225.194.90,58916,443,T,O,A",
									"1732204772,10.224.0.4,4.225.194.90,60516,443,T,O,A"
								]
							}
						]
					}
				]
			}
		},
		{
			"time": "2024-11-21T19:01:07.0795183Z",
			"systemId": "90487218-89e5-47b5-a4b8-138eb46e56e4",
			"macAddress": "6045BDACE2FA",
			"category": "NetworkSecurityGroupFlowEvent",
			"resourceId": "/SUBSCRIPTIONS/redacts-1111-1111-1111-111111111111/RESOURCEGROUPS/MC_RG_ASKNAT_SWEDENCENTRAL/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/AKS-AGENTPOOL-42418909-NSG",
			"operationName": "NetworkSecurityGroupFlowEvents",
			"properties": {
				"Version": 1,
				"flows": [
					{
						"rule": "DefaultRule_AllowInternetOutBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732204805,10.224.0.4,4.225.194.90,35822,443,T,O,A"
								]
							}
						]
					},
					{
						"rule": "DefaultRule_AllowVnetOutBound",
						"flows": [
							{
								"mac": "6045BDACE2FA",
								"flowTuples": [
									"1732204805,10.244.0.9,10.244.2.3,41082,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,45404,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,59022,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,55676,53,U,O,A",
									"1732204805,10.244.0.9,10.244.2.3,34633,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,46227,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,53375,53,U,O,A",
									"1732204805,10.244.0.9,10.244.2.3,42215,53,U,O,A",
									"1732204805,10.244.0.9,10.244.2.3,60714,53,U,O,A",
									"1732204805,10.244.0.9,10.244.1.3,40008,53,U,O,A"
								]
							}
						]
					}
				]
			}
		},
```

- https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg#data-aggregation: All flow logs at a network security group between FlowIntervalStartTime_t and FlowIntervalEndTime_t are captured at one-minute intervals as blobs in a storage account.

## nsg.flowlog.create.workspace.aks

```
# https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-cli#create-a-flow-log-and-traffic-analytics-workspace
nsg=aks-agentpool-42418909-nsg # update the name of the nsg
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv) # update the name of the aks cluster
storage="storage$RANDOM$RANDOM"; echo $storage
az storage account create -g $rg -n $storage
storageId=$(az storage account show -g $rg -n $storage --query id -otsv); echo $storageId
az monitor log-analytics workspace create -g $rg -n laworkspace
workspaceId=$(az monitor log-analytics workspace show -g $rg -n laworkspace --query id -otsv)
az network watcher flow-log create -g $noderg --nsg $nsg -n myFlowLog --storage-account $storageId --log-version 2 --traffic-analytics true --workspace $workspaceId --interval 10 # minutes
# az network watcher flow-log update -g $noderg --nsg $nsg -n myFlowLog --interval 10 # minutes
```

```
az network watcher flow-log show -g $noderg --nsg $nsg -n myFlowLog --query flowAnalyticsConfiguration.networkWatcherFlowAnalyticsConfiguration.workspaceResourceId -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/laworkspace

# **nsg.flowlog.SubType_s
# https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg#notes: AzurePublic, ExternalPublic
AzureNetworkAnalytics_CL 
| where SubType_s == "FlowLog"
| summarize count() by FlowType_s
ExternalPublic	53
AzurePublic	51
Unknown		180
IntraVNet	330

# kubenet/node (ExternalPublic) - curl google.com
## AzureNetworkAnalytics_CL
TimeGenerated [UTC]  2024-12-05T18:02:59.4882593Z
FlowType_s  ExternalPublic
SrcIP_s  10.224.0.4
DestPublicIPs_s  142.250.74.46|1|1|6|0|478|0 142.250.74.174|1|1|6|0|478|0
## kubectl get no -owide
aks-nodepool1-75204569-vmss000000   Ready    <none>   83m   v1.30.6   10.224.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1
## Name:   google.com
Address: 142.250.187.238

# kubenet/pod (ExternalPublic) - kubectl run nginx --image=nginx; kubectl exec -it nginx -- curl -I google.com
No entry in the flowlog

# azure-cni/pod (ExternalPublic) - kubectl run nginx --image=nginx; kubectl exec -it nginx -- curl -I google.com
FlowType_s  ExternalPublic
SrcIP_s  10.224.0.33
DestPublicIPs_s  142.250.74.46|2|2|12|0|958|0
kubectl get no -owide
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-23665971-vmss000000   Ready    <none>   33m   v1.30.6   10.224.0.33   <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

# azure-cni/pod - curl to an nginx pod on the same node
# kubectl run nginx0 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-23665971-vmss000000"}}}'
# kubectl get po -owide; kubectl exec nginx -- curl -I 10.224.0.37
No entry in the flowlog

# azure-cni/pod - curl to an nginx pod on an another node
# kubectl run nginx1 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-23665971-vmss000001"}}}'
# kubectl get po -owide; kubectl exec nginx -- curl -I 10.224.0.19
No entry in the flowlog
```

- https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-overview


## nsg.flowlog.schema

```
AzureNetworkAnalytics_CL 
| where SubType_s == "FlowLog"
| limit 02

AzureNetworkAnalytics_CL 
| where SubType_s == "FlowLog" 
| distinct NSGList_s,FlowType_s,SrcIP_s,DestIP_s,DestPort_d,L4Protocol_s,L7Protocol_s,FlowDirection_s,Region_s,Subscription_g,Subnet1_s,NIC1_s,VM1_s
```

- https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg
- https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-overview#log-format
- https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg#data-aggregation: if a processing interval of 10 minutes is selected, traffic analytics will instead pick blobs from the storage account every 10 minute
- https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg#traffic-analytics-schema: TableName	AzureNetworkAnalytics_CL
- https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics-schema?tabs=nsg#notes: See Notes for definitions.
- https://harvestingclouds.com/post/troubleshooting-azure-networking-checking-allowed-and-denied-traffic-in-network-security-groups-nsgs-via-log-analytics-queries/: All the logs from NSG Flow Logs are sent to the "AzureNetworkAnalytics_CL" table in the Log Analytics.

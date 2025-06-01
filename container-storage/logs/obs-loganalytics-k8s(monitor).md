> ## log-analytics.azure-monitor-diagnostic-settings

```
# portal: AKS resource, Monitoring / Diagnostic settings.
# logs: could you share the GMT time and the resource URI of a missing create?
# mitigate: optionally, "Add (another) diagnostic setting" or use az monitor diagnostic-settings create with a new name

aks_state=$(az aks show -g $rg -n aks --query provisioningState -otsv); echo $aks_state # Succeeded

aks_id=$(az aks show -g $rg -n aks --query id -otsv); echo $aks_id
log_analytics_id=$(az monitor log-analytics workspace list --query "[?location=='swedencentral']" --query [0].id -otsv); echo $log_analytics_id
az monitor diagnostic-settings create --name AKS-Diagnostics --resource $aks_id --logs '[{"category": "kube-audit","enabled": true}, {"category": "kube-audit-admin", "enabled": true}, {"category": "kube-apiserver", "enabled": true}, {"category": "kube-controller-manager", "enabled": true}, {"category": "kube-scheduler", "enabled": true}, {"category": "cluster-autoscaler", "enabled": true}, {"category": "cloud-controller-manager", "enabled": true}, {"category": "guard", "enabled": true}, {"category": "csi-azuredisk-controller", "enabled": true}, {"category": "csi-azurefile-controller", "enabled": true}, {"category": "csi-snapshot-controller", "enabled": true}]'  --workspace $log_analytics_id --export-to-resource-specific true

az monitor diagnostic-settings list --resource $aks_id --query [0].logs
[
  {
    "category": "kube-audit",
    "enabled": true,
    "retentionPolicy": {
      "days": 0,
      "enabled": false
    }
  },
  {
    "category": "kube-audit-admin",
    "enabled": true,
    "retentionPolicy": {
      "days": 0,
      "enabled": false
    }
  },..
  
AKSAudit | limit 10 # Message before diagnostic-settings create command: No results found

date; k create ns test-ns
AKSAudit | limit 10 # AKSAudit | where RequestUri startswith "/api/v1/namespaces/test-ns" 
# latency is less than two minutes for events to appear in the AKSAudit table after running the command
# TimeGenerated is typically within the same second or a second later, meaning it's faster to search within the minute
# TenantId is different from the subscription TenantId
# Refer to kube-audit.configmap.list or kube-audit.configmap.watch for all the fields
```

- https://learn.microsoft.com/en-us/azure/aks/monitor-aks?tabs=cilium
- https://learn.microsoft.com/en-us/azure/azure-monitor/platform/create-diagnostic-settings?tabs=cli

```
az monitor log-analytics workspace table update --subscription ContosoSID --resource-group ContosoRG  --workspace-name ContosoWorkspace --name ContainerLogV2  --plan Basic
```
https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-table-plans?tabs=cli-1

```
# kube-audit.ns.create

date; k create ns test-ns
# k get ns --output=custom-columns=NAME:.metadata.name,CREATE_TIMESTAMP:.metadata.creationTimestamp
AKSAudit | where RequestUri startswith "/api/v1/namespaces/test-ns" | project TimeGenerated,AuditId,Verb,RequestUri
5/30/2025, 6:50:55.347 PM
4416f092-9d40-4e44-85fe-98a54d1124d8
create
/api/v1/namespaces/test-ns/serviceaccounts
5/30/2025, 6:50:55.347 PM
9ec4ff1f-1197-4467-8919-786db44d936d
create
/api/v1/namespaces/test-ns/configmaps
```

```
# kube-audit.configmap.create

date; kubectl create configmap app-config \
  --from-literal=ENV=production \
  --from-literal=DEBUG=false
# kubectl get configmap --output=custom-columns=NAME:.metadata.name,CREATE_TIMESTAMP:.metadata.creationTimestamp
AKSAudit | where RequestUri startswith "/api/v1/namespaces/default/configmaps" | project TimeGenerated,AuditId,Verb,RequestUri,ObjectRef,ResponseStatus
TimeGenerated [UTC]
2025-05-30T18:48:52.369488Z
AuditId
e1d12fb7-62b8-445c-805e-23d9a9ac96a8
Verb
create
RequestUri
/api/v1/namespaces/default/configmaps?fieldManager=kubectl-create&fieldValidation=Strict
ObjectRef
{"resource":"configmaps","namespace":"default","name":"app-config","apiVersion":"v1"}
ResponseStatus
{"metadata":{},"code":201}
```

```
# kube-audit.configmap.list
date; kubectl get cm
AKSAudit | where Verb =="list"
TenantId
8c5f99a3-b05f-4598-8ef9-29f7510d32f7
TimeGenerated [UTC]
2025-05-30T18:02:52.4298698Z
Level
Metadata
AuditId
43af2d39-6ad2-4266-9196-c144db8cf714
Stage
ResponseComplete
RequestUri
/api/v1/namespaces/default/configmaps?limit=500
Verb
list
User
{"username":"masterclient","groups":["system:masters","system:authenticated"]}
SourceIps
["1.2.3.4","172.31.22.97"]
UserAgent
kubectl/v1.31.0 (linux/amd64) kubernetes/9edcffc
ObjectRef
{"resource":"configmaps","apiVersion":"v1","namespace":"default"}
ResponseStatus
{"metadata":{},"code":200}
RequestReceivedTime [UTC]
2025-05-30T18:02:52.425513Z
StageReceivedTime [UTC]
2025-05-30T18:02:52.429672Z
Annotations
{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}
PodName
kube-apiserver-6d7fc956fd-s68ss
Type
AKSAudit
_ResourceId
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/microsoft.containerservice/managedclusters/aks
```

```
# kube-audit.configmap.watch
date; kubectl get cm -w
AKSAudit | where Verb =="watch"
TenantId
8c5f99a3-b05f-4598-8ef9-29f7510d32f7
TimeGenerated [UTC]
2025-05-30T15:04:23.9020517Z
Level
Metadata
AuditId
feea66a4-df3a-4904-a034-65e93483aa10
Stage
ResponseComplete
RequestUri
/api/v1/namespaces/default/configmaps?resourceVersion=1259737&watch=true
Verb
watch
User
{"username":"masterclient","groups":["system:masters","system:authenticated"]}
SourceIps
["1.2.3.4","172.31.22.97"]
UserAgent
kubectl/v1.31.0 (linux/amd64) kubernetes/9edcffc
ObjectRef
{"resource":"configmaps","namespace":"default","apiVersion":"v1"}
ResponseStatus
{"metadata":{},"code":200}
RequestReceivedTime [UTC]
2025-05-30T18:04:14.105227Z
StageReceivedTime [UTC]
2025-05-30T18:04:23.901883Z
Annotations
{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}
PodName
kube-apiserver-6d7fc956fd-scmhc
Type
AKSAudit
_ResourceId
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/microsoft.containerservice/managedclusters/aks
```

> ## log-analytics.table.AzureDiagnostics

```
AzureDiagnostics
| where TimeGenerated>ago(1d)
| summarize count() by Category,_ResourceId
| where count_>1000000
| order by count_ desc

AzureDiagnostics
| where Category=="kube-audit"
| summarize count() by bin(TimeGenerated,1d)
| order by count_ desc
```

- https://learn.microsoft.com/en-us/azure/aks/monitor-aks: Azure diagnostics mode sends all data to the AzureDiagnostics table, while resource-specific mode sends data to AKS Audit, AKS Audit Admin, and AKS Control Plane as shown in the table at Resource logs. There can be substantial cost when collecting resource logs for AKS, particularly for kube-audit logs.
- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics

> ## log-analytics.table.ContainerLog

```
ContainerLog
| where TimeGenerated>ago(1d)
| summarize count() by ContainerID,_ResourceId
| order by count_ desc

let date_before_issue=datetime(2023-10-15);
let date_during_issue=datetime(2023-10-25);
let ids1=ContainerLog
| where TimeGenerated == date_before_issue
| distinct ContainerID;
let ids2=ContainerLog
| where TimeGenerated == date_during_issue
| distinct ContainerID
| where ContainerID in (ids1);
ContainerLog
| where ContainerID in (ids2)
| where TimeGenerated==date_before_issue or TimeGenerated==date_during_issue
| project TimeGenerated,ContainerID,_BilledSize
| order by ContainerID asc

KubePodInventory
| distinct ContainerID, Namespace
| join
(
    ContainerLog
)
on ContainerID
| summarize count() by bin(TimeGenerated, 2h), Namespace
| sort by  Namespace asc, TimeGenerated asc
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/containerlog
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-agent-config#data-collection-settings: [log_collection_settings.stdout] exclude_namespaces =
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-v2-migration

> ## log-analytics.table.ContainerLogV2

```
let date_before_issue=datetime(2023-10-15);
let date_during_issue=datetime(2023-10-25);
let ids1=ContainerLogV2
| where TimeGenerated == date_before_issue
| distinct ContainerId;
let ids2=ContainerLogV2
| where TimeGenerated == date_during_issue
| distinct ContainerId
| where ContainerId in (ids1);
ContainerLogV2
| where ContainerId in (ids2)
| where TimeGenerated ==date_before_issue or TimeGenerated ==date_during_issue
| project TimeGenerated,ContainerId,_BilledSize
| order by ContainerId asc 
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/containerlogv2
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-logging-v2?tabs=configure-portal
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-v2-migration

> ## log-analytics.table.KubeEvents

The KubeEvents table provides information about events that occur within a Kubernetes environment.

```
# kubectl run nginx2 --image=nginx2
pod/nginx2 created
```

```
# kubectl get po
NAME     READY   STATUS         RESTARTS   AGE
nginx2   0/1     ErrImagePull   0          4s

# kubectl describe po nginx2
Status:           Pending
Containers:
  nginx2:
    Container ID:
    Image:          nginx2
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ndfpf (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Events:
  Type     Reason     Age                             From               Message
  ----     ------     ----                            ----               -------
  Normal   Scheduled  <invalid>                       default-scheduler  Successfully assigned default/nginx2 to aks-nodepool1-51397738-vmss00000b
  Normal   Pulling    <invalid> (x4 over <invalid>)   kubelet            Pulling image "nginx2"
  Warning  Failed     <invalid> (x4 over <invalid>)   kubelet            Failed to pull image "nginx2": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/nginx2:latest": failed to resolve reference "docker.io/library/nginx2:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed     <invalid> (x4 over <invalid>)   kubelet            Error: ErrImagePull
  Warning  Failed     <invalid> (x6 over <invalid>)   kubelet            Error: ImagePullBackOff
  Normal   BackOff    <invalid> (x63 over <invalid>)  kubelet            Back-off pulling image "nginx2"
```

```
KubePodInventory
| where Name startswith "nginx2"
| project TimeGenerated, Namespace, Name, PodStatus, ContainerStatusReason

# Here is a sample output below.
TimeGenerated [UTC]	Namespace	Name	PodStatus	ContainerStatusReason
7/19/2023, 10:20:31.000 AM	default	nginx2	Pending	ImagePullBackOff
```

```
KubeEvents
| where ObjectKind =="Pod" and Name startswith "nginx2"
| project TimeGenerated, Namespace, Name, Reason, Message

# Here is a sample output below.
TimeGenerated [UTC]	Namespace	Name	Reason	Message
7/19/2023, 10:13:12.000 AM	default	nginx2	Failed	Failed to pull image "nginx2": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/nginx2:latest": failed to resolve reference "docker.io/library/nginx2:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
7/19/2023, 10:13:12.000 AM	default	nginx2	Failed	Error: ErrImagePull
7/19/2023, 10:13:13.000 AM	default	nginx2	Failed	Error: ImagePullBackOff
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/kubeevents
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query#kubernetes-events: By default, Normal event types aren't collected, so you won't see them when you query the KubeEvents table unless the collect_all_kube_events ConfigMap setting is enabled.

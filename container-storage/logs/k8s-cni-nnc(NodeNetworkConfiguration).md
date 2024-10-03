```
# cni.azure.overlay,podsubnet

kubectl get nnc -n kube-system
NAME                                  ALLOCATED IPS   NC MODE   NC VERSION
aks-nodepool1-36149301-vmss000000     255             static    0
aks-nodepool1-36149301-vmss000001     255             static    0

kubectl get nnc -n kube-system -owide
NAME                                  REQUESTED IPS   ALLOCATED IPS   SUBNET       SUBNET CIDR     NC ID                                  NC MODE   NC TYPE     NC VERSION
aks-nodepool1-36149301-vmss000000     250             255             podsubnet    10.40.0.0/13    68eb969e-c8a9-4f82-a0c6-9b3ec8f9b276   static    vnetblock   0
aks-nodepool1-36149301-vmss000001     250             255             podsubnet    10.40.0.0/13    bf0a349b-c6e5-4fa8-bbbd-c84ee001b851   static    vnetblock   0

kubectl describe nnc -n kube-system aks-nodepool1-36149301-vmss000000
Name:         aks-nodepool1-36149301-vmss000000
Namespace:    kube-system
Labels:       kubernetes.azure.com/podnetwork-delegationguid=3371eec1-b861-4dca-838d-c6bfe7032461
              kubernetes.azure.com/podnetwork-subnet=podsubnet
              kubernetes.azure.com/podnetwork-type=vnetblock
              managed=true
              owner=aks-nodepool1-36149301-vmss000000
Annotations:  <none>
API Version:  acn.azure.com/v1alpha
Kind:         NodeNetworkConfig
Metadata:
  Creation Timestamp:  2024-10-03T21:04:54Z
  Finalizers:
    finalizers.acn.azure.com/dnc-operations
  Generation:  1
  Owner References:
    API Version:           v1
    Block Owner Deletion:  true
    Controller:            true
    Kind:                  Node
    Name:                  aks-nodepool1-36149301-vmss000000
    UID:                   e9fe832a-a94b-44b4-a775-0d1b1ce521a5
  Resource Version:        994
  UID:                     490e58b9-5b49-4663-91f4-2901d6325cd9
Spec:
  Requested IP Count:  250
Status:
  Assigned IP Count:  255
  Network Containers:
    Assignment Mode:  static
    Default Gateway:  10.40.0.1
    Id:               68eb969e-c8a9-4f82-a0c6-9b3ec8f9b276
    Ip Assignments:
      Ip:                  10.40.0.176/28
      Name:                0f6c46ba-d85a-44b7-9d25-f9cbf7987dd8
      Ip:                  10.47.255.112/28
      Name:                222e8889-fbb5-416b-afc8-da8ebc1d2006
      Ip:                  10.47.255.32/28
      Name:                bb7dcad0-205d-4b77-8f1d-7471ccee30e0
      Ip:                  10.40.0.192/28
      Name:                1f58c68b-6e32-4a3b-9b9a-0339af897398
      Ip:                  10.40.0.224/28
      Name:                2df4db12-5eff-44a3-9fa2-b91527883ea4
      Ip:                  10.40.0.208/28
      Name:                863d7153-1316-4c7d-a1cf-391f1b845ea1
      Ip:                  10.40.0.240/28
      Name:                4d4a4439-6ee3-44b8-821e-c63913ae4793
      Ip:                  10.47.255.96/28
      Name:                c0150f9c-b648-4d3b-843a-9d2e365c1643
      Ip:                  10.47.255.0/28
      Name:                e1929d2b-7323-4c53-809e-dfef660431a1
      Ip:                  10.40.1.16/28
      Name:                0b62167d-66fa-4e18-846f-a5f1a297cd68
      Ip:                  10.47.255.64/28
      Name:                24e00a74-b759-4997-ab86-44087bba37e7
      Ip:                  10.47.255.16/28
      Name:                4a2ae326-cb6b-4279-93c0-08e687b563a5
      Ip:                  10.47.255.80/28
      Name:                4f2400c3-5e7a-4612-8748-39c67aa3b484
      Ip:                  10.47.255.48/28
      Name:                905f6517-d4d4-462b-baf7-ebd5beadd6c7
      Ip:                  10.40.1.0/28
      Name:                b5b3b9a8-b1c8-4c4c-b78a-35a96f98bdc7
    Node IP:               10.240.0.4
    Primary IP:            10.40.0.160/28
    Resource Group ID:     rg
    Subcription ID:        efec8e52-e1ad-4ae1-8598-f243e56e2b08
    Subnet Address Space:  10.40.0.0/13
    Subnet ID:             podsubnet
    Subnet Name:           podsubnet
    Type:                  vnetblock
    Version:               0
    Vnet ID:               vnet
Events:                    <none>

kubectl get po -n kube-system -l k8s-app=azure-cns -owide
NAME              READY   STATUS      RESTARTS        AGE    IP           NODE                                  NOMINATED NODE   READINESS GATES
azure-cns-rppt6   1/1     Running     0               125m   10.240.0.5   aks-nodepool1-36149301-vmss000001     <none>           <none>
azure-cns-x72x6   1/1     Running     0               125m   10.240.0.4   aks-nodepool1-36149301-vmss000000     <none>           <none>

kubectl logs -n kube-system azure-cns-rppt6
Defaulted container "cns-container" out of: cns-container, cni-installer (init)
2024/10/03 21:05:13 [1] [Configuration] Using config path: /etc/azure-cns/cns_config.json
2024/10/03 21:05:13 [1] GetAzureCloud querying url: http://169.254.169.254/metadata/instance/compute/azEnvironment?api-version=2018-10-01&format=text
2024/10/03 21:05:13 [1] [Utils] Initializing HTTP client with connection timeout: 7, response header timeout: 7
2024/10/03 21:05:13 [1] AI Telemetry Handle created
2024/10/03 21:05:13 [1] [Azure CNS] Using config: &{AZRSettings:{PopulateHomeAzCacheRetryIntervalSecs:60} AsyncPodDeletePath:/var/run/azure-vnet/deleteIDs CNIConflistFilepath:/etc/cni/net.d/15-azure-swift.conflist CNIConflistScenario:swift ChannelMode:CRD EnableAsyncPodDelete:true EnableCNIConflistGeneration:true EnableIPAMv2:false EnablePprof:false EnableStateMigration:false EnableSubnetScarcity:false EnableSwiftV2:false InitializeFromCNI:true KeyVaultSettings:{URL: CertificateName: RefreshIntervalInHrs:12} MSISettings:{ResourceID:} ManageEndpointState:false ManagedSettings:{PrivateEndpoint: InfrastructureNetworkID: NodeID: NodeSyncIntervalInSeconds:30} MellanoxMonitorIntervalSecs:0 MetricsBindAddress::10092 ProgramSNATIPTables:false SWIFTV2Mode: SyncHostNCTimeoutMs:500 SyncHostNCVersionIntervalMs:1000 TLSCertificatePath: TLSEndpoint: TLSPort: TLSSubjectName: TelemetrySettings:{DisableAll:false DisableTrace:false DisableMetric:false DisableEvent:false TelemetryBatchSizeBytes:16384 TelemetryBatchIntervalInSecs:15 HeartBeatIntervalInMins:30 DisableMetadataRefreshThread:false RefreshIntervalInSecs:15 DebugMode:false SnapshotIntervalInMins:60 AppInsightsInstrumentationKey:} UseHTTPS:false UseMTLS:false WatchPods:false WireserverIP:168.63.129.16}
2024/10/03 21:05:13 [1] [Telemetry] Request metadata from wireserver
2024/10/03 21:05:13 [1] Running on Linux version 5.15.0-1071-azure (buildd@lcy02-amd64-063) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #80-Ubuntu SMP Tue Aug 6 19:27:32 UTC 2024
2024/10/03 21:05:13 [1] Acquiring process lock
2024/10/03 21:05:13 [1] Acquired process lock with timeout value of 10s
2024/10/03 21:05:13 [1] Released process lock
? http server started on [::]:10092
2024/10/03 21:05:13 [1] [Azure CNS] GetPrimaryInterfaceInfoFromHost
2024/10/03 21:05:13 [1] [Azure CNS] Response received from NMAgent for get interface details: <Interfaces><Interface MacAddress="7C1E52403503" IsPrimary="true"><IPSubnet Prefix="10.240.0.0/16"><IPAddress Address="10.240.0.5" IsPrimary="true"/></IPSubnet></Interface></Interfaces>
2024/10/03 21:05:13 [1] [Azure CNS] Initialize HTTPRemoteRestService
2024/10/03 21:05:13 [1] user specifies -c option
2024/10/03 21:05:13 [1] [Azure CNS] restoreState
2024/10/03 21:05:13 [1] [Azure CNS]  No state to restore.
2024/10/03 21:05:13 [1] [Azure CNS] Enter Restoring Network State
2024/10/03 21:05:13 [1] [Azure CNS] Store does not exist, nothing to restore for network state.
2024/10/03 21:05:13 [1] [Utils] Initializing HTTP client with connection timeout: 5, response header timeout: 120
2024/10/03 21:05:13 [1] SetContext details called with:  orchestrator nodeID
2024/10/03 21:05:13 [1] [Azure CNS]  Listening.
2024/10/03 21:05:13 [1] Writing {} to CNI statefile /var/run/azure-vnet.json
2024/10/03 21:05:13 [1] Set GlobalPodInfoScheme 1 (InitializeFromCNI=true)
2024/10/03 21:05:13 [1] [Azure CNS] setOrchestratorType
2024/10/03 21:05:13 [1] SetContext details called with: KubernetesCRD orchestrator nodeID
2024/10/03 21:05:13 [1] [azure-cns] Sent cns.Response {ReturnCode:Success Message:}.
2024/10/03 21:05:14 [1] Initializing from CNI
2024/10/03 21:05:14 [1] Reconciling initial CNS state
2024/10/03 21:05:14 [1] reconciling initial CNS state attempt: 1
2024/10/03 21:05:14 [1] Retrieved NNC: &{TypeMeta:{Kind: APIVersion:} ObjectMeta:{Name:aks-nodepool1-36149301-vmss000001 GenerateName: Namespace:kube-system SelfLink: UID:7e0dfe4a-273f-4950-9a67-2cc6d72a3715 ResourceVersion:929 Generation:1 CreationTimestamp:2024-10-03 21:04:48 +0000 UTC DeletionTimestamp:<nil> DeletionGracePeriodSeconds:<nil> Labels:map[kubernetes.azure.com/podnetwork-delegationguid:3371eec1-b861-4dca-838d-c6bfe7032461 kubernetes.azure.com/podnetwork-subnet:podsubnet kubernetes.azure.com/podnetwork-type:vnetblock managed:true owner:aks-nodepool1-36149301-vmss000001] Annotations:map[] OwnerReferences:[{APIVersion:v1 Kind:Node Name:aks-nodepool1-36149301-vmss000001 UID:ae1eb1fe-1ff6-4113-a5c6-1c844991dc62 Controller:0xc00014c0cf BlockOwnerDeletion:0xc00014c0ce}] Finalizers:[finalizers.acn.azure.com/dnc-operations] ManagedFields:[{Manager:dnc-rc Operation:Update APIVersion:acn.azure.com/v1alpha Time:2024-10-03 21:04:48 +0000 UTC FieldsType:FieldsV1 FieldsV1:{"f:metadata":{"f:finalizers":{".":{},"v:\"finalizers.acn.azure.com/dnc-operations\"":{}},"f:labels":{".":{},"f:kubernetes.azure.com/podnetwork-delegationguid":{},"f:kubernetes.azure.com/podnetwork-subnet":{},"f:kubernetes.azure.com/podnetwork-type":{},"f:managed":{},"f:owner":{}},"f:ownerReferences":{".":{},"k:{\"uid\":\"ae1eb1fe-1ff6-4113-a5c6-1c844991dc62\"}":{}}},"f:spec":{".":{},"f:requestedIPCount":{}}} Subresource:} {Manager:dnc-rc Operation:Update APIVersion:acn.azure.com/v1alpha Time:2024-10-03 21:04:54 +0000 UTC FieldsType:FieldsV1 FieldsV1:{"f:status":{".":{},"f:assignedIPCount":{},"f:networkContainers":{}}} Subresource:status}]} Spec:{RequestedIPCount:250 IPsNotInUse:[]} Status:{AssignedIPCount:255 Scaler:{BatchSize:0 ReleaseThresholdPercent:0 RequestThresholdPercent:0 MaxIPCount:0} Status: NetworkContainers:[{ID:bf0a349b-c6e5-4fa8-bbbd-c84ee001b851 AssignmentMode:static Type:vnetblock PrimaryIP:10.40.0.16/28 SubnetName:podsubnet IPAssignments:[{Name:397f308b-4c6c-49a4-b06d-eb5b09b7349e IP:10.40.0.96/28}...
```

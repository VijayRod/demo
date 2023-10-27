```
az storage blob list --account-name $storage --container-name backups --output table --auth-mode login
az storage blob list --account-name $storage --container-name backups --output table --account-key $key
Name
                                                                                              Blob Type    Blob Tier    Length    Content Type              Last Modified              Snapshot
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  -----------  -----------  --------  ------------------------  -------------------------  ----------
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-csi-volumesnapshotclasses.json.gz   BlockBlob    29        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-csi-volumesnapshotcontents.json.gz  BlockBlob    27        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-csi-volumesnapshots.json.gz         BlockBlob    27        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-itemoperations.json.gz              BlockBlob    27        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-logs.gz                             BlockBlob    29077     application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-podvolumebackups.json.gz            BlockBlob    29        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-resource-list.json.gz               BlockBlob    1722      application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-results.gz                          BlockBlob    49        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797-volumesnapshots.json.gz             BlockBlob    29        application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar.gz                              BlockBlob    91081     application/octet-stream  2023-10-09T20:05:00+00:00
backups/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797/velero-backup.json                                                                                                     BlockBlob    3911      application/octet-stream  2023-10-09T20:05:01+00:00

/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar.gz/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar/metadata
version

/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar.gz/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar/resources
apiservices.apiregistration.k8s.io
clusterrolebindings.rbac.authorization.k8s.io
clusterroles.rbac.authorization.k8s.io
configmaps
csidrivers.storage.k8s.io
customresourcedefinitions.apiextensions.k8s.io
endpoints
endpointslices.discovery.k8s.io
flowschemas.flowcontrol.apiserver.k8s.io
mutatingwebhookconfigurations.admissionregistration.k8s.io
namespaces
priorityclasses.scheduling.k8s.io
prioritylevelconfigurations.flowcontrol.apiserver.k8s.io
serviceaccounts
services
storageclasses.storage.k8s.io
validatingwebhookconfigurations.admissionregistration.k8s.io
volumesnapshotclasses.snapshot.storage.k8s.io

/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar.gz/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar/resources/storageclasses.storage.k8s.io/cluster
azurefile.json
azurefile-csi.json
azurefile-csi-premium.json
azurefile-premium.json
default.json
managed.json
managed-csi.json
managed-csi-premium.json
managed-premium.json

cat /clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar.gz/clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797.tar/resources/storageclasses.storage.k8s.io/cluster/default.json
{"allowVolumeExpansion":true,"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"},"creationTimestamp":"2023-10-09T19:37:21Z","labels":{"addonmanager.kubernetes.io/mode":"EnsureExists","kubernetes.io/cluster-service":"true"},"managedFields":[{"apiVersion":"storage.k8s.io/v1","fieldsType":"FieldsV1","fieldsV1":{"f:allowVolumeExpansion":{},"f:metadata":{"f:annotations":{".":{},"f:storageclass.kubernetes.io/is-default-class":{}},"f:labels":{".":{},"f:addonmanager.kubernetes.io/mode":{},"f:kubernetes.io/cluster-service":{}}},"f:parameters":{".":{},"f:skuname":{}},"f:provisioner":{},"f:reclaimPolicy":{},"f:volumeBindingMode":{}},"manager":"kubectl-create","operation":"Update","time":"2023-10-09T19:37:21Z"}],"name":"default","resourceVersion":"341","uid":"6a1ae4cf-93e2-4238-ab8e-e466d518db92"},"parameters":{"skuname":"StandardSSD_LRS"},"provisioner":"disk.csi.azure.com","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}

cat velero-backup.json
{
  "kind": "Backup",
  "apiVersion": "velero.io/v1",
  "metadata": {
    "name": "clusterbackup-dataprotection-microsoft-backup-d8699196-4adf-4810-b6f0-b54e7c7b2797",
    "namespace": "dataprotection-microsoft",
    "uid": "d26cce0e-782c-4a26-99ce-21a54e18c87d",
    "resourceVersion": "81726",
    "generation": 3,
    "creationTimestamp": "2023-10-09T20:04:57Z",
    "labels": {
      "velero.io/storage-location": "default"
    },
    "annotations": {
      "disk.csi.azure.com": "azbackup-disk.csi.azure.com-3a6a743b-fa71-4d62-9012-488648f2ea32",
      "velero.io/source-cluster-k8s-gitversion": "v1.26.6",
      "velero.io/source-cluster-k8s-major-version": "1",
      "velero.io/source-cluster-k8s-minor-version": "26"
    },
    "managedFields": [
      {
        "manager": "manager",
        "operation": "Update",
        "apiVersion": "velero.io/v1",
        "time": "2023-10-09T20:04:57Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:metadata": {
            "f:annotations": {
              ".": {},
              "f:disk.csi.azure.com": {}
            }
          },
          "f:spec": {
            ".": {},
            "f:excludedNamespaces": {},
            "f:excludedResources": {},
            "f:hooks": {},
            "f:includeClusterResources": {},
            "f:metadata": {},
            "f:snapshotVolumes": {},
            "f:ttl": {}
          },
          "f:status": {}
        }
      },
      {
        "manager": "velero-server",
        "operation": "Update",
        "apiVersion": "velero.io/v1",
        "time": "2023-10-09T20:05:01Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:metadata": {
            "f:annotations": {
              "f:velero.io/source-cluster-k8s-gitversion": {},
              "f:velero.io/source-cluster-k8s-major-version": {},
              "f:velero.io/source-cluster-k8s-minor-version": {}
            },
            "f:labels": {
              ".": {},
              "f:velero.io/storage-location": {}
            }
          },
          "f:spec": {
            "f:csiSnapshotTimeout": {},
            "f:defaultVolumesToFsBackup": {},
            "f:itemOperationTimeout": {},
            "f:storageLocation": {},
            "f:volumeSnapshotLocations": {}
          },
          "f:status": {
            "f:expiration": {},
            "f:formatVersion": {},
            "f:phase": {},
            "f:startTimestamp": {},
            "f:version": {}
          }
        }
      }
    ]
  },
  "spec": {
    "metadata": {},
    "excludedNamespaces": [
      "kube-system",
      "kube-node-lease",
      "kube-public",
      "dataprotection-microsoft"
    ],
    "excludedResources": [
      "v1/Secret",
      "backups.clusterbackup.dataprotection.microsoft.com",
      "validateforbackups.clusterbackup.dataprotection.microsoft.com",
      "validateforrestores.clusterbackup.dataprotection.microsoft.com",
      "restores.clusterbackup.dataprotection.microsoft.com",
      "deletebackups.clusterbackup.dataprotection.microsoft.com",
      "nodes",
      "events",
      "events.events.k8s.io",
      "csinodes.storage.k8s.io",
      "backuprepositories.velero.io",
      "backups.velero.io",
      "deletebackuprequests.velero.io",
      "downloadrequests.velero.io",
      "resticrepositories.velero.io",
      "restores.velero.io"
    ],
    "snapshotVolumes": true,
    "ttl": "23976h0m0s",
    "includeClusterResources": true,
    "hooks": {},
    "storageLocation": "default",
    "volumeSnapshotLocations": [
      "default"
    ],
    "defaultVolumesToFsBackup": false,
    "csiSnapshotTimeout": "10m0s",
    "itemOperationTimeout": "1h0m0s"
  },
  "status": {
    "version": 1,
    "formatVersion": "1.1.0",
    "expiration": "2026-07-04T20:04:57Z",
    "phase": "Completed",
    "startTimestamp": "2023-10-09T20:04:57Z",
    "completionTimestamp": "2023-10-09T20:05:01Z"
  }
}
```

## secrets-store

```
# See the section on secrets-store key
```

## secrets-store.debug.error.FailedMount.SecretNotFound

FailedMount with SecretNotFound indicates that the key vault does not have a secret defined in the configured SecretProviderClass.

RCA: Verify that the secret "secret1" mentioned in the error exists in the key vault defined in the associated SecretProviderClass.

```
# Replace the below with appropriate values.
rgname=$rg
clustername=akscert
keyvaultName="keyvault$RANDOM"
```

```
userAssignedIdentityID=$(az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
tenantId=$(az aks show -g $rgname -n $clustername --query identity.tenantId -o tsv)

cat << EOF | kubectl apply -f -
# This is a SecretProviderClass example using user-assigned identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: "$userAssignedIdentityID"   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: "$keyvaultName"        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: key1
          objectType: key
          objectVersion: ""
    tenantId: "$tenantId"                 # The tenant ID of the key vault
---
# This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"
EOF
```

```
kubectl get po busybox-secrets-store-inline-user-msi

NAME                                    READY   STATUS              RESTARTS   AGE
busybox-secrets-store-inline-user-msi   0/1     ContainerCreating   0          34m

kubectl describe po busybox-secrets-store-inline-user-msi

Warning  FailedMount  5m38s (x9 over 26m)  kubelet            Unable to attach or mount volumes: unmounted volumes=[secrets-store01-inline], unattached volumes=[secrets-store01-inline kube-api-access-n68bh]: timed out waiting for the condition
Warning  FailedMount  91s (x21 over 28m)   kubelet            MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-user-msi, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:secret, objectName:secret1, objectVersion:: keyvault.BaseClient#GetSecret: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="SecretNotFound" Message="A secret with (name/id) secret1 was not found in this key vault. If you recently deleted this secret you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"

# Cleanup
kubectl delete po busybox-secrets-store-inline-user-msi --force
kubectl delete SecretProviderClass azure-kvname-user-msi
```

Similar errors can occur if a key or certificate is not found. The link in the error points to [Azure Key Vault recovery management with soft delete and purge protection](https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery?tabs=azure-powershell).

```
Warning  FailedMount  26s (x7 over 58s)  kubelet            MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-user-msi, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:key, objectName:key1, objectVersion:: keyvault.BaseClient#GetKey: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="KeyNotFound" Message="A key with (name/id) key1 was not found in this key vault. If you recently deleted this key you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"
  
Warning  FailedMount  1s (x5 over 9s)  kubelet            MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-user-msi, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:cert, objectName:cert1, objectVersion:: keyvault.BaseClient#GetCertificate: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="CertificateNotFound" Message="A certificate with (name/id) cert1 was not found in this key vault. If you recently deleted this certificate you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"
```

## secrets-store.debug.error.no_matches_for_kind_SecretProviderClass

<b>RCA</b>: When attempting to create a SecretProviderClass in a cluster without the Key Vault addon, you may encounter the error message `no matches for kind "SecretProviderClass"`. To resolve this, ensure that the addon is installed or enable it using the command `az aks enable-addons --addons azure-keyvault-secrets-provider --name myAKSCluster --resource-group myResourceGroup`, and then retry adding the SecretProviderClass.

```
cat << EOF | kubectl apply -f -
# This is a SecretProviderClass example using user-assigned identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: dummyid1-1111-1111-1111-111111111111   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: dummyname        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    tenantId: dummyid1-1111-1111-1111-111111111111                 # The tenant ID of the key vault
EOF
```

<b>Output</b>:

The following error is returned:

```
error: resource mapping not found for name: "azure-kvname-user-msi" namespace: "" from "STDIN": no matches for kind "SecretProviderClass" in version "secrets-store.csi.x-k8s.io/v1"
ensure CRDs are installed first
```

No rows are returned with the following commands:

```
kubectl get crd | grep secrets-store

az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider
```

## secrets-store.key

The following code creates a cluster with the Key Vault addon using the steps mentioned in [this Microsoft Azure documentation](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver), and utilizes the user-assigned managed identity that was created during addon enablement, as indicated in [this documentation](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access#access-with-a-user-assigned-managed-identity).

```
rgname=$rg
clustername=akssecretstore
keyvaultName="keyvault$RANDOM"
keyvaultResourceGroupName=$rg

az aks create -g $rgname -n $clustername --enable-addons azure-keyvault-secrets-provider -s $vmsize -c 2
# (for existing cluster) az aks enable-addons --addons azure-keyvault-secrets-provider -g $rgname -n $clustername

az keyvault create -g $keyvaultResourceGroupName -n $keyvaultName --retention-days 7 --public-network-access Enabled  --enable-rbac-authorization false # Test.
az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value MyAKSExampleSecret

userAssignedIdentityID=$(az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
# Set policy to access keys in your key vault
az keyvault set-policy -n $keyvaultName --key-permissions get --spn "$userAssignedIdentityID"
# Set policy to access secrets in your key vault
az keyvault set-policy -n $keyvaultName --secret-permissions get --spn "$userAssignedIdentityID"
# Set policy to access certs in your key vault
az keyvault set-policy -n $keyvaultName --certificate-permissions get --spn "$userAssignedIdentityID"
```

```
userAssignedIdentityID=$(az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
tenantId=$(az aks show -g $rgname -n $clustername --query identity.tenantId -o tsv)
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

kubectl delete po busybox-secrets-store-inline-user-msi
kubectl delete secretproviderclass azure-kvname-user-msi
cat << EOF | kubectl apply -f -
# This is a SecretProviderClass example using user-assigned identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: "$userAssignedIdentityID"   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: "$keyvaultName"        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: ExampleSecret
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    tenantId: $tenantId                 # The tenant ID of the key vault
---
# This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"
EOF
```

```
## show secrets held in secrets-store
kubectl exec busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store/

ExampleSecret

## print a test secret 'ExampleSecret' held in secrets-store
kubectl exec busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret

MyAKSExampleSecretroot
```

```
# Describe the secret provide class and pod.
kubectl describe SecretProviderClass azure-kvname-user-msi
kubectl describe pod/busybox-secrets-store-inline-user-msi
kubectl get pod/busybox-secrets-store-inline-user-msi

# Cleanup.
kubectl delete pod/busybox-secrets-store-inline-user-msi --force
kubectl delete secretproviderclass.secrets-store.csi.x-k8s.io/azure-kvname-user-msi
```

Each node has a aks-secrets-store-csi-driver pod and a aks-secrets-store-provider-azure pod.

```
kubectl get all -n kube-system | grep secrets
pod/aks-secrets-store-csi-driver-l84kb       3/3     Running   0          3h20m
pod/aks-secrets-store-csi-driver-r5gww       3/3     Running   0          3h20m
pod/aks-secrets-store-csi-driver-xlqfj       3/3     Running   0          3h20m
pod/aks-secrets-store-provider-azure-6nxkd   1/1     Running   0          3h20m
pod/aks-secrets-store-provider-azure-l8cbr   1/1     Running   0          3h20m
pod/aks-secrets-store-provider-azure-m29gg   1/1     Running   0          3h20m
daemonset.apps/aks-secrets-store-csi-driver               3         3         3       3            3           <none>                     3h22m
daemonset.apps/aks-secrets-store-csi-driver-windows       0         0         0       0            0           <none>                     3h22m
daemonset.apps/aks-secrets-store-provider-azure           3         3         3       3            3           kubernetes.io/os=linux     3h22m
daemonset.apps/aks-secrets-store-provider-azure-windows   0         0         0       0            0           kubernetes.io/os=windows   3h22m

kubectl get pods -n kube-system -owide -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)'
NAME                                     READY   STATUS    RESTARTS   AGE    IP           NODE                                NOMINATED NODE   READINESS GATES
aks-secrets-store-csi-driver-m2cqq       3/3     Running   0          3h5m   10.244.2.2   aks-nodepool1-29360345-vmss000001   <none>           <none>
aks-secrets-store-csi-driver-pbl4x       3/3     Running   0          3h5m   10.244.0.2   aks-nodepool1-29360345-vmss000002   <none>           <none>
aks-secrets-store-csi-driver-r9nw2       3/3     Running   0          3h5m   10.244.1.2   aks-nodepool1-29360345-vmss000000   <none>           <none>
aks-secrets-store-provider-azure-27bkf   1/1     Running   0          3h5m   10.224.0.4   aks-nodepool1-29360345-vmss000000   <none>           <none>
aks-secrets-store-provider-azure-bfl6m   1/1     Running   0          3h5m   10.224.0.5   aks-nodepool1-29360345-vmss000001   <none>           <none>
aks-secrets-store-provider-azure-w9kzp   1/1     Running   0          3h5m   10.224.0.6   aks-nodepool1-29360345-vmss000002   <none>           <none>

kubectl get ds -n kube-system | grep -i secrets-store
aks-secrets-store-csi-driver               3         3         3       3            3           <none>                     3h7m
aks-secrets-store-csi-driver-windows       0         0         0       0            0           <none>                     3h7m
aks-secrets-store-provider-azure           3         3         3       3            3           kubernetes.io/os=linux     3h7m
aks-secrets-store-provider-azure-windows   0         0         0       0            0           kubernetes.io/os=windows   3h7m

k api-resources | grep secrets-
secretproviderclasses                                   secrets-store.csi.x-k8s.io/v1          true         SecretProviderClass
secretproviderclasspodstatuses                          secrets-store.csi.x-k8s.io/v1          true         SecretProviderClassPodStatus

kubectl get crd | grep store
secretproviderclasses.secrets-store.csi.x-k8s.io            2023-06-06T14:11:50Z
secretproviderclasspodstatuses.secrets-store.csi.x-k8s.io   2023-06-06T14:11:50Z

az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider
The behavior of this command has been altered by the following extension: aks-preview
{
  "config": {
    "enableSecretRotation": "false",
    "rotationPollInterval": "2m"
  },
  "enabled": true,
  "identity": {
    "clientId": "dummyidc-1111-1111-1111-111111111111",
    "objectId": "dummyido-1111-1111-1111-111111111111",
    "resourceId": "/subscriptions/dummyids-1111-1111-1111-111111111111/resourcegroups/dummyResourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-dummyclustername"
  }
}
```

```
# describe
Name:         azure-kvname-user-msi
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  secrets-store.csi.x-k8s.io/v1
Kind:         SecretProviderClass
Metadata:
  Creation Timestamp:  2023-06-07T09:29:18Z
  Generation:          1
  Resource Version:    218906
  UID:                 34405d15-c71b-46a1-9070-6d7be195c230
Spec:
  Parameters:
    Cloud Name:
    Keyvault Name:  dummyName
    Objects:        array:
  - |
    objectName: ExampleSecret
    objectType: secret              # object types: secret, key, or cert
    objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    Tenant Id:                  dummyt-1111-1111-1111-111111111111
    Use Pod Identity:           false
    Use VM Managed Identity:    true
    User Assigned Identity ID:  dummyi-1111-1111-1111-111111111111
  Provider:                     azure
Events:                         <none>

# describe
Name:             busybox-secrets-store-inline-user-msi
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-nodepool1-32184550-vmss000000/10.224.0.4
Start Time:       Tue, 06 Jun 2023 17:44:54 +0000
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.2.3
IPs:
  IP:  10.244.2.3
Containers:
  busybox:
    Container ID:  containerd://75aadeee6dcf91587f551ba9293feb18e39e107f73d0876f52fb305ec362ba83
    Image:         registry.k8s.io/e2e-test-images/busybox:1.29-1
    Image ID:      registry.k8s.io/e2e-test-images/busybox@sha256:39e1e963e5310e9c313bad51523be012ede7b35bb9316517d19089a010356592
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sleep
      10000
    State:          Running
      Started:      Wed, 07 Jun 2023 07:38:21 +0000
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 07 Jun 2023 04:51:40 +0000
      Finished:     Wed, 07 Jun 2023 07:38:20 +0000
    Ready:          True
    Restart Count:  5
    Environment:    <none>
    Mounts:
      /mnt/secrets-store from secrets-store01-inline (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-774tx (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  secrets-store01-inline:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            secrets-store.csi.k8s.io
    FSType:
    ReadOnly:          true
    VolumeAttributes:      secretProviderClass=azure-kvname-user-msi
  kube-api-access-774tx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

# for pod create
k describe secretproviderclasspodstatuses
Name:         busybox-secrets-store-inline-user-msi-default-azure-kvname-user-msi
Namespace:    default
Labels:       internal.secrets-store.csi.k8s.io/node-name=aks-nodepool1-40899545-vmss000001
Annotations:  <none>
API Version:  secrets-store.csi.x-k8s.io/v1
Kind:         SecretProviderClassPodStatus
Metadata:
  Creation Timestamp:  2024-11-20T18:53:41Z
  Generation:          1
  Owner References:
    API Version:     v1
    Kind:            Pod
    Name:            busybox-secrets-store-inline-user-msi
    UID:             197cf1f7-4d27-41a1-8ac4-b1ddf4c40779
  Resource Version:  12831
  UID:               167de5dc-7235-4e7e-b8e9-1a725ff4b737
Status:
  Mounted:  true
  Objects:
    Id:                        secret/ExampleSecret
    Version:                   dc57c223d6fe48e099b3ac1f68a62b1e
  Pod Name:                    busybox-secrets-store-inline-user-msi
  Secret Provider Class Name:  azure-kvname-user-msi
  Target Path:                 /var/lib/kubelet/pods/197cf1f7-4d27-41a1-8ac4-b1ddf4c40779/volumes/kubernetes.io~csi/secrets-store01-inline/mount
Events:                        <none>

# for pod create
k logs -n kube-system -l app=secrets-store-csi-driver -c secrets-store
I1120 18:30:51.446006       1 nodeserver.go:143] "node publish volume" target="/var/lib/kubelet/pods/e0c6b259-9cd3-4a68-b436-d37043b45c6d/volumes/kubernetes.io~csi/secrets-store01-inline/mount" volumeId="csi-ab5cc7b693d80b579a12dcfaf6b8b530197590e184e081f4cdef683c4bcf3e94" mount flags=null
I1120 18:30:51.447725       1 nodeserver.go:353] "Using gRPC client" provider="azure" pod="busybox-secrets-store-inline-user-msi"
I1120 18:30:51.606179       1 nodeserver.go:253] "node publish volume complete" targetPath="/var/lib/kubelet/pods/e0c6b259-9cd3-4a68-b436-d37043b45c6d/volumes/kubernetes.io~csi/secrets-store01-inline/mount" pod="default/busybox-secrets-store-inline-user-msi" time="160.228828ms"
I1120 18:30:51.606437       1 secretproviderclasspodstatus_controller.go:224] "reconcile started" spcps="default/busybox-secrets-store-inline-user-msi-default-azure-kvname-user-msi"
I1120 18:30:51.606477       1 secretproviderclasspodstatus_controller.go:265] "no secret objects defined for spc, nothing to reconcile" spc="default/azure-kvname-user-msi" spcps="default/busybox-secrets-store-inline-user-msi-default-azure-kvname-user-msi"

# for pod create
k logs -n kube-system -l app=secrets-store-provider-azure
            objectName: ExampleSecret
            objectType: secret              # object types: secret, key, or cert
            objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
 > pod="default/busybox-secrets-store-inline-user-msi"
I1120 18:30:51.485937       1 provider.go:188] "unmarshaled objects yaml array" objectsArray=<
        [objectName: ExampleSecret
        objectType: secret              # object types: secret, key, or cert
        objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty]
 > pod="default/busybox-secrets-store-inline-user-msi"
I1120 `18:30:51.486100       1 provider.go:217] "vault url" vaultName="keyvault28122" vaultURL="https://keyvault28122.vault.azure.net/" pod="default/busybox-secrets-store-inline-user-msi"

# for pod create delete
k logs -n kube-system -l app=secrets-store-csi-driver -c secrets-store
I1120 18:34:04.946994       1 nodeserver.go:306] "node unpublish volume complete" targetPath="/var/lib/kubelet/pods/e0c6b259-9cd3-4a68-b436-d37043b45c6d/volumes/kubernetes.io~csi/secrets-store01-inline/mount" time="2.280396ms"
```

- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
- https://secrets-store-csi-driver.sigs.k8s.io/known-limitations
- https://github.com/kubernetes-sigs/secrets-store-csi-driver/issues

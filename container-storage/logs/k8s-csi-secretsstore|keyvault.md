## secrets-store

- https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/
- https://github.com/kubernetes-sigs/secrets-store-csi-driver
- https://deepwiki.com/kubernetes-sigs/secrets-store-csi-driver
- https://deepwiki.com/Azure/secrets-store-csi-driver-provider-azure

```
# See the section on secrets-store key
# refer to secret

Pod
+-- VolumeMount (CSI: secrets-store.csi.k8s.io)
    +-- SecretProviderClass (YAML Config)
        +-- Secrets Store CSI Driver (Controller DaemonSet)
            +-- Fetch secrets from external provider (e.g. Azure Key Vault, Vault, AWS SM)
            +-- Mount secrets as files inside the pod (ephemeral volume)
            +-- [Optional] Sync secrets as Kubernetes Secrets (cluster-scoped objects)
```

```
# k8s-secret-management.provider.secret-store-csi-driver
# See the section on secrets-store key

# k8s-secret-management.provider.secret-store-csi-driver.secret-controller
# utilizes daemonsets
ds: kube-system   aks-secrets-store-csi-driver               2         2         2       2            2           <none>                     156m
ds: kube-system   aks-secrets-store-csi-driver-windows       0         0         0       0            0           <none>                     156m
kubectl get SecretProviderClass -A # Secret sync controller (opcional)
kubectl get SecretProviderClassPodStatus -A # Pod status controller

# k8s-secret-management.provider.secret-store-csi-driver.provider-plugin
# utilizes daemonsets
ds: kube-system   aks-secrets-store-provider-azure           2         2         2       2            2           kubernetes.io/os=linux     156m
ds: kube-system   aks-secrets-store-provider-azure-windows
```
- https://secrets-store-csi-driver.sigs.k8s.io/

```
# k8s-secret-management.provider.external-secrets
# Refer to external-secrets (https://github.com/external-secrets)

# k8s-secret-management.provider.external-secrets.secret-controller
kubectl get ExternalSecret -A # ExternalSecret Controller, Refresh Controller
kubectl get SecretStore -A # SecretStore Controller
kubectl get ClusterSecretStore # SecretStore Controller
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
k get sc #  no additional rows besides the default disk and file storage classes

k api-resources | grep secret
secrets                                                 v1                                true         Secret
secretproviderclasses                                   secrets-store.csi.x-k8s.io/v1     true         SecretProviderClass
secretproviderclasspodstatuses                          secrets-store.csi.x-k8s.io/v1     true         SecretProviderClassPodStatus

k get secretproviderclasses -A # No resources found by default

k describe po -n kube-system aks-secrets-store-provider-azure-qxkwp
Name:                 aks-secrets-store-provider-azure-qxkwp
Namespace:            kube-system
Priority:             2000001000
Priority Class Name:  system-node-critical
Service Account:      aks-secrets-store-provider-azure
Node:                 aks-nodepool1-22302342-vmss000003/10.224.0.4
Start Time:           Fri, 30 May 2025 18:54:18 +0000
Labels:               app=secrets-store-provider-azure
                      controller-revision-hash=8468d6dbdf
                      kubernetes.azure.com/managedby=aks
                      pod-template-generation=1
Annotations:          <none>
Status:               Running
IP:                   10.224.0.4
IPs:
  IP:           10.224.0.4
Controlled By:  DaemonSet/aks-secrets-store-provider-azure
Containers:
  provider-azure-installer:
    Container ID:  containerd://ae8c65f63d17e98753e7beae98e0c0f0f50ab505f2b8a16c407cb15c3bd7cc5b
    Image:         mcr.microsoft.com/oss/azure/secrets-store/provider-azure:v1.6.2

k describe po -n kube-system aks-secrets-store-csi-driver-h4s8s
Name:                 aks-secrets-store-csi-driver-h4s8s
Namespace:            kube-system
Priority:             2000001000
Priority Class Name:  system-node-critical
Service Account:      aks-secrets-store-csi-driver
Node:                 aks-nodepool1-22302342-vmss000002/10.224.0.5
Start Time:           Fri, 30 May 2025 18:53:56 +0000
Labels:               app=secrets-store-csi-driver
                      controller-revision-hash=69c7d4bfd8
                      kubernetes.azure.com/managedby=aks
                      pod-template-generation=1
Annotations:          <none>
Status:               Running
IP:                   10.244.0.244
IPs:
  IP:           10.244.0.244
Controlled By:  DaemonSet/aks-secrets-store-csi-driver
Containers:
  node-driver-registrar:
    Container ID:  containerd://47ba8923193324a191ce87e0fa7e206d608de8c7bb1cc5a56194ce1c1b17fa93
    Image:         mcr.microsoft.com/oss/kubernetes-csi/csi-node-driver-registrar:v2.11.1
  secrets-store:
    Container ID:  containerd://5f871cd65cb2b91190f8a2ecaa8c7d6c232e7b8960e628bd81260307be2be11a
    Image:         mcr.microsoft.com/oss/kubernetes-csi/secrets-store/driver:v1.4.8

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

> ##secrets-store.key.debug

```
# secret.plain-text

path=/var/lib/kubelet/pods/e0e13dfa-61f1-46d4-ad32-78471ebc750c/volumes/kubernetes.io~csi
ls $path # secrets-store01-inline
ls $path/secrets-store01-inline # mount  vol_data.json

cat ls $path/secrets-store01-inline/vol_data.json
{"attachmentID":"csi-1dc02516447a61ea2b247511d7057774a605c4419f72dd435def8dbfb6a7aba1","driverName":"secrets-store.csi.k8s.io","nodeName":"aks-nodepool1-34137564-vmss000000","specVolID":"secrets-store01-inline","volumeHandle":"csi-75fdc8ff6f0827161b25f96398c40ed524e1ce351b20ceb5e1b5333b143944f2","volumeLifecycleMode":"Ephemeral"}

cat $path/secrets-store01-inline/mount/ExampleSecret # MyAKSExampleSecretroot (non-TLS secret)
```

```
# secret.corruption
# az keyvault certificate download --encoding DER/PEM to obtain the cert
# Then use openssl to compare the downloaded cert with the one in the /var/lib/kubelet/pods path.
# tbd p12: openssl pkcs12 -info -in cert.p12 # for a PEM cert i.e. base64 PEM x509 certificate
# tbd crt: openssl x509 -in cert.crt -text -noout # for a DER cert i.e. binary DER formatted x509 certificate

# Download a certificate as PEM and check its fingerprint in openssl.
az keyvault certificate download --vault-name vault -n cert-name -f cert.pem && \
       openssl x509 -in cert.pem -inform PEM  -noout -sha1 -fingerprint

# Download a certificate as DER and check its fingerprint in openssl.
az keyvault certificate download --vault-name vault -n cert-name -f cert.crt -e DER && \
       openssl x509 -in cert.crt -inform DER  -noout -sha1 -fingerprint        
```

```
# *kv-secret.sync
# by default, a k8s secret is not configured, and the secret value within the application pod does not automatically refresh when the secret value (version) in the key vault is updated

# mitigation to ensure secret sync: secret delete, pod delete/recreate
# logs: Please provide the secrets-store container logs from the node driver during a repro with the mitigation applied, and if possible, include the GMT timestamps for when the key was added to the KV and when the mitigation was performed.
# logs 2: k logs -n kube-system aks-secrets-store-csi-driver-t99tz -c secrets-store

az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider
{
  "config": {
    "enableSecretRotation": "false",
    "rotationPollInterval": "2m"
  },
  "enabled": true,
  "identity": {
    "clientId": "f265d535-386d-45d7-be37-ea2e48706917",
    "objectId": "92b6f6c3-031f-4219-b042-911e40ab2ff1",
    "resourceId": "/subscriptions/$subId/resourcegroups/$noderg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-akssecretstore"
  }
}

# portal, Key Vault / Objects / Secrets: Choose the secret you need, then you can view its version or add a new version.
az keyvault secret show --vault-name $keyvaultName -n ExampleSecret --query "{Version:id, Created:attributes.created}"
{
  "Created": "2025-08-05T19:51:22+00:00",
  "Version": "https://keyvault12944.vault.azure.net/secrets/ExampleSecret/6fbede6a0862412eb2261c2291121f47"
}

kubectl describe po 
    Mounts:
      /mnt/secrets-store from secrets-store01-inline (ro)
Volumes:
  secrets-store01-inline:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            secrets-store.csi.k8s.io
    FSType:
    ReadOnly:          true
    VolumeAttributes:      secretProviderClass=azure-kvname-user-msi
    
k exec -it busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store
ExampleSecret
k exec -it busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret # View secret value in plain text
    
k get secret # returns no rows

k describe secretproviderclass
Name:         azure-kvname-user-msi
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  secrets-store.csi.x-k8s.io/v1
Kind:         SecretProviderClass
Metadata:
  Creation Timestamp:  2025-08-05T19:51:47Z
  Generation:          1
  Resource Version:    2165
  UID:                 093d4363-f8b8-48b9-82e3-01388b1ce696
Spec:
  Parameters:
    Cloud Name:
    Keyvault Name:  keyvault12944
    Objects:        array:
  - |
    objectName: ExampleSecret
    objectType: secret              # object types: secret, key, or cert
    objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty

    Tenant Id:                  redactedt-1111-1111-1111-111111111111
    Use Pod Identity:           false
    Use VM Managed Identity:    true
    User Assigned Identity ID:  f265d535-386d-45d7-be37-ea2e48706917
  Provider:                     azure
Events:                         <none>

k describe po -n kube-system -l app=secrets-store-csi-driver | grep Image
    Image:         mcr.microsoft.com/oss/kubernetes-csi/csi-node-driver-registrar:v2.13.0
    Image:         mcr.microsoft.com/oss/v2/kubernetes-csi/secrets-store/driver:v1.5.1
    Image:         mcr.microsoft.com/oss/kubernetes-csi/livenessprobe:v2.15.0
    
k describe po -n kube-system -l app=secrets-store-provider-azure | grep Image
    Image:         mcr.microsoft.com/oss/v2/azure/secrets-store/provider-azure:v1.7.0
```

- https://secrets-store-csi-driver.sigs.k8s.io/known-limitations#mounted-content-and-kubernetes-secret-not-updated
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-akv-secrets-provider#additional-configuration-options


```
# *kv-secret.sync.app=secrets-store-csi-driver (present on every node)
```
- faq: The CSI driver sends GET requests to the Key Vault to retrieve the most recent version of a secret.
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-key-vault-csi-secrets-store-csi-driver: error: failed to get objectType:secret.. curl -X GET 'https://<key-vault-name>.vault.azure.net/secrets/<secret-name>..

```
# *kv-secret.sync.pod-mnt/secrets-store aka auto rotation

az aks addon update -g $rgname -n $clustername --addon azure-keyvault-secrets-provider --enable-secret-rotation # --rotation-poll-interval 1m
az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider #     "enableSecretRotation": "true",    "rotationPollInterval": "2m"

az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value "MyAKSExampleSecret$(date +%Y%m%d%H%M%S)" # you can also update the secret value directly in the portal
sleep 120; k exec -it busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret # has updated secret value


  secrets-store:
      --enable-secret-rotation=true
      --rotation-poll-interval=2m
```

- https://secrets-store-csi-driver.sigs.k8s.io/known-limitations#mounted-content-and-kubernetes-secret-not-updated: Enable Secret autorotation feature has been released in..
- https://secrets-store-csi-driver.sigs.k8s.io/topics/secret-auto-rotation: When the secret/key is updated in external secrets store after the initial pod deployment, the updated secret will be periodically updated in the pod mount and the Kubernetes Secret.
- https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/configurations/enable-auto-rotation-secrets/: The CSI driver does not restart the application pods. It only handles updating the pod mount and Kubernetes secret similar to how Kubernetes handles updates to Kubernetes secret mounted as volumes.
- faq: when a new secret reference (e.g., key4) is added to a SecretProviderClass, the CSI Driver does not immediately sync the new secret to the Kubernetes secret object. Instead, it waits for the next polling interval to detect and apply the change.
  - https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options: Once you enable auto-rotation for Azure Key Vault Secrets Provider, it updates the pod mount and the Kubernetes secret defined in the secretObjects field of SecretProviderClass. It does so by polling for changes periodically, based on the rotation poll interval you defined. The default rotation poll interval is two minutes. - When a secret updates in an external secrets store after initial pod deployment, the Kubernetes Secret and the pod mount periodically update depending on how the application consumes the secret data.
- faq: the Azure Key Vault CSI Driver only queries the secrets explicitly defined in the SecretProviderClass associated with the pod being mounted on a node. It does not query all secrets in the Key Vault or across the cluster
  - https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options: Once you enable auto-rotation for Azure Key Vault Secrets Provider, it updates the pod mount and the Kubernetes secret defined in the secretObjects field of SecretProviderClass. It does so by polling for changes periodically, based on the rotation poll interval you defined.
  - https://learn.microsoft.com/en-us/azure/aks/aksarc/secrets-store-csi-driver: The Kubernetes Secrets Store CSI driver integrates secrets stores with Kubernetes using a Container Storage Interface (CSI) volume. The data is then mounted in the container's file system.
  - https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver: 
- faq: it's one GET call per keyvault object defined in secret provider class. If you have 10 objects in secret provider class and 5 pods using it in that node, then it'll result in 5 * 10 = 100 calls. This is only for pods on the same node as the driver. The driver needs to mount the secrets in pod, so it's a node local process.

```
# *kv-secret.sync.pod-mnt/secrets-store aka auto rotation.secret2 has been added to the existing SecretProviderClass
# When ExampleSecret2 is added to an existing SecretProviderClass, the secret is immediately available in a new pod as expected (although after the polling interval rather than immediately, if the pod is getting secret from a k8s secret))

echo $rgname, $clustername, $keyvaultName, $userAssignedIdentityID
kubectl cluster-info | grep control
az aks addon update -g $rgname -n $clustername --addon azure-keyvault-secrets-provider --enable-secret-rotation --rotation-poll-interval 10m # using a longer interval for testing purposes
az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider
az keyvault update -n $keyvaultName --public-network-access Enabled
az keyvault secret set --vault-name $keyvaultName -n ExampleSecret2 --value MyAKSExampleSecret2

userAssignedIdentityID=$(az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
tenantId=$(az aks show -g $rgname -n $clustername --query identity.tenantId -o tsv)
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

kubectl delete po --all
kubectl delete secretproviderclass --all
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
        - |
          objectName: ExampleSecret2
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
kubectl get po -w
k exec -it busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store
k exec -it busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret2



sleep 120
k exec -it busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store
k exec -it busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret2
```

```
# kv-secret.sync.k8s-secret
# SecretProviderClass: use secretObjects to create a Kubernetes secret
# pod: apply volumes and containers.volumeMounts, including for environment variables

# failed: the secret was not automatically created because there is no pod referencing it
az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value "MyAKSExampleSecret$(date +%Y%m%d%H%M%S)" # you can also update the secret value directly in the portal
kubectl delete po --all
kubectl delete secret --all # example-k8s-secret
k delete secretproviderclass --all
cat << EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "$userAssignedIdentityID"
    keyvaultName: "$keyvaultName"
    cloudName: ""
    tenantId: "$tenantId"
    objects: |
      array:
        - |
          objectName: ExampleSecret
          objectType: secret
          objectVersion: ""
  secretObjects:
    - secretName: example-k8s-secret
      type: Opaque
      data:
        - key: example-key
          objectName: ExampleSecret
EOF
kubectl get secret -w
```

```
# success: The secret is created by the secret store driver when the first pod that references it starts on the node.
# az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value "MyAKSExampleSecret$(date +%Y%m%d%H%M%S)" # you can also update the secret value directly in the portal
kubectl delete po --all
kubectl delete secret --all # example-k8s-secret
k delete secretproviderclass --all
cat << EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "$userAssignedIdentityID"
    keyvaultName: "$keyvaultName"
    cloudName: ""
    tenantId: "$tenantId"
    objects: |
      array:
        - |
          objectName: ExampleSecret
          objectType: secret
          objectVersion: ""
  secretObjects:
    - secretName: example-k8s-secret
      type: Opaque
      data:
        - key: example-key
          objectName: ExampleSecret
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-secret-env
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command: ["/bin/sh", "-c", "env && sleep 10000"]
      env:
        - name: EXAMPLE_SECRET
          valueFrom:
            secretKeyRef:
              name: example-k8s-secret
              key: example-key
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
          secretProviderClass: azure-kvname-user-msi
EOF
kubectl get secret
kubectl get po -w 
kubectl get secret example-k8s-secret -o jsonpath="{.data.example-key}" | base64 --decode
kubectl exec -it busybox-secret-env -- printenv # EXAMPLE_SECRET=MyAKSExampleSecret20250805143710

NAME                 TYPE     DATA   AGE
example-k8s-secret   Opaque   1      0s
NAME                      READY   STATUS    RESTARTS   AGE
busybox-secret-env        1/1     Running   0          4s
^CMyAKSExampleSecret20250805143710
EXAMPLE_SECRET=MyAKSExampleSecret20250805143710
```

- * https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options#sync-mounted-content-with-a-kubernetes-secret: Your secrets sync after you start a pod to mount them. When you delete the pods that consume the secrets, your Kubernetes secret is also deleted.
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options#set-an-environment-variable-to-reference-kubernetes-secrets
- faq when a new secretObjects is added to the secret provider class, and when a pod retrieves this from a k8s secret: if a new pod is created and if they added a new Kubernetes secret in the secretObjects it will be created by the driver automatically! Only existing Kubernetes secret won't get updated until poll interval

```
# success: When a new secretObject is added to the secret provider class, just like the initial secret, the local secret store driver creates the new secret immediately when it is first referenced by a pod created on that node.
az keyvault secret set --vault-name $keyvaultName -n ExampleSecret2 --value "MyAKSExampleSecret$(date +%Y%m%d%H%M%S)" # you can also update the secret value directly in the portal
kubectl delete po --all
# kubectl delete secret --all # example-k8s-secret
k delete secretproviderclass --all
cat << EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "$userAssignedIdentityID"
    keyvaultName: "$keyvaultName"
    cloudName: ""
    tenantId: "$tenantId"
    objects: |
      array:
        - |
          objectName: ExampleSecret
          objectType: secret
          objectVersion: ""
        - |
          objectName: ExampleSecret2
          objectType: secret
          objectVersion: ""          
  secretObjects:
    - secretName: example-k8s-secret
      type: Opaque
      data:
        - key: example-key
          objectName: ExampleSecret
    - secretName: example-k8s-secret2
      type: Opaque
      data:
        - key: example-key2
          objectName: ExampleSecret2
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-secret-env
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command: ["/bin/sh", "-c", "env && sleep 10000"]
      env:
        - name: EXAMPLE_SECRET
          valueFrom:
            secretKeyRef:
              name: example-k8s-secret
              key: example-key
        - name: EXAMPLE_SECRET2
          valueFrom:
            secretKeyRef:
              name: example-k8s-secret2
              key: example-key2
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
          secretProviderClass: azure-kvname-user-msi
EOF
kubectl get secret
kubectl get po
kubectl get secret example-k8s-secret -o jsonpath="{.data.example-key}" | base64 --decode
kubectl get secret example-k8s-secret -o jsonpath="{.data.example-key2}" | base64 --decode
kubectl exec -it busybox-secret-env -- printenv # EXAMPLE_SECRET=MyAKSExampleSecret20250805143710, EXAMPLE_SECRET2=MyAKSExampleSecret2
```


```
# success: when a secret value in secretObjects is updated, the new value is typically available right away both in the secret and in the pod.
kubectl get secret # no output until the polling interval has passed

az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value "MyAKSExampleSecret$(date +%Y%m%d%H%M%S)" # you can also update the secret value directly in the portal
kubectl delete po --all
# kubectl delete secret --all # example-k8s-secret
# kubectl delete secretproviderclass --all
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-secret-env
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command: ["/bin/sh", "-c", "env && sleep 10000"]
      env:
        - name: EXAMPLE_SECRET
          valueFrom:
            secretKeyRef:
              name: example-k8s-secret
              key: example-key
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
          secretProviderClass: azure-kvname-user-msi
EOF
kubectl get secret
kubectl get po -w 
kubectl get secret example-k8s-secret -o jsonpath="{.data.example-key}" | base64 --decode
kubectl exec -it busybox-secret-env -- printenv # EXAMPLE_SECRET=MyAKSExampleSecret20250805143710
```
- faq about updating secret values (versions) in key vault, and when a pod retrieves this from a k8s secret: The new pod will get the new key immediately in the volume mounted file but the Kubernetes secret will only be updated at the poll interval. If they want the Kubernetes secret to have the latest key, they need to delete it before creating the pod. The new Kubernetes secret that will be created when the pod is deployed will contain all keys that are defined in the secret provider class. This is by design. i.e. if a new pod is created and if they added a new Kubernetes secret in the secretObjects it will be created by the driver automatically! Only existing Kubernetes secret won't get updated until poll interval



```
# kv-secret.sync.k8s-secret.err.ContainerCreating / 403 Forbidden
# mitigate: az keyvault update -n $keyvaultName --public-network-access Enabled

k get secret
No resources found in default namespace.
k get po
NAME                      READY   STATUS              RESTARTS   AGE
busybox-secret-env        0/1     ContainerCreating   0          27s
k describe po
  Warning  FailedMount  3s (x7 over 35s)  kubelet            MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secret-env, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:secret, objectName:ExampleSecret, objectVersion:: GET https://keyvault12944.vault.azure.net/secrets/ExampleSecret/
--------------------------------------------------------------------------------
RESPONSE 403: 403 Forbidden
ERROR CODE: Forbidden
--------------------------------------------------------------------------------
{
  "error": {
    "code": "Forbidden",
    "message": "Public network access is disabled and request is not from a trusted service nor via an approved private link.\r\nCaller: appid=f265d535-386d-45d7-be37-111111111111;oid=92b6f6c3-031f-4219-b042-111111111111;iss=https://sts.windows.net/redactt-1111-1111-1111-111111111111/;xms_mirid=/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rgkv_akssecretstore_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-85712729-vmss;xms_az_rid=/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rgkv_akssecretstore_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-85712729-vmss\r\nVault: keyvault12944;location=swedencentral",
    "innererror": {
      "code": "ForbiddenByConnection"
    }
  }
}

az keyvault update -n $keyvaultName --public-network-access Enabled
k get secret
NAME                 TYPE     DATA   AGE
example-k8s-secret   Opaque   1      2m9s
k get po
NAME                      READY   STATUS    RESTARTS   AGE
busybox-secret-env        1/1     Running   0          4m16s
```
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-key-vault-csi-secrets-store-csi-driver#cause-2-the-provider-pod-cant-access-the-key-vault-instance


```
tbd
# kv-secret.sync.k8s-secret.err.CreateContainerConfigError / k8s secret does not exist
# mitigate: If a new pod enters a CreateContainerConfigError state because the (new secretObjects) secret cannot be found, wait for the rotation-poll-interval to pass. After this interval, the same pod will automatically transition to the Running state. The pod shows a CreateContainerConfigError with 'secret "example-k8s-secret" not found' in the pod description, but after the polling interval, it automatically transitions to a Running state.

```

```
tbd
# kv-secret.sync.k8s-secret.err.CreateContainerConfigError / existing k8s secret (does not have the correct secret value) 
# mitigate: Delete the secret if it already exists. This allows the local secret store driver to create it right away, instead of waiting for the polling interval to update the secret value from the latest version.
```

```
# secret.corruption.tls
# the key vault contains two files: crt and key. The same two files are located in the /var/lib/kubelet/pods path.
```

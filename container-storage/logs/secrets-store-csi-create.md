The following code creates a cluster with the Key Vault addon using the steps mentioned in [this Microsoft Azure documentation](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver), and utilizes the user-assigned managed identity that was created during addon enablement, as indicated in [this documentation](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access#access-with-a-user-assigned-managed-identity).

```
# Replace the below with appropriate values.
rgname=resourceGroupName
clustername=clusterName
keyvaultName=keyvaultName
keyvaultResourceGroupName=keyvaultResourceGroupName
```

```
az aks create -g $rgname -n $clustername --enable-addons azure-keyvault-secrets-provider
# (for existing cluster) az aks enable-addons --addons azure-keyvault-secrets-provider -g $rgname -n $clustername

az keyvault create -g $keyvaultResourceGroupName -n $keyvaultName --retention-days 7 --public-network-access Enabled  --enable-rbac-authorization false # Test.
az keyvault secret set --vault-name $keyvaultName -n ExampleSecret --value MyAKSExampleSecret

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

kubectl api-versions | grep secrets-store

secrets-store.csi.x-k8s.io/v1
secrets-store.csi.x-k8s.io/v1alpha1

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
# Sample describes.

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

```

- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
- https://secrets-store-csi-driver.sigs.k8s.io/known-limitations
- https://github.com/kubernetes-sigs/secrets-store-csi-driver/issues

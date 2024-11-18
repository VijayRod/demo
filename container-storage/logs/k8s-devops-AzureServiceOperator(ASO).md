```
# https://azure.github.io/azure-service-operator/: Installation
# az ad sp create-for-rbac -n azure-service-operator1118

k get all -n azureserviceoperator-system
NAME                                                           READY   STATUS    RESTARTS        AGE
pod/azureserviceoperator-controller-manager-84c6466d9b-rqq5z   1/1     Running   1 (9m18s ago)   9m37s

NAME                                                              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/azureserviceoperator-controller-manager-metrics-service   ClusterIP   10.0.95.190   <none>        8443/TCP   9m38s
service/azureserviceoperator-webhook-service                      ClusterIP   10.0.21.152   <none>        443/TCP    9m38s

NAME                                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/azureserviceoperator-controller-manager   1/1     1            1           9m38s

NAME                                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/azureserviceoperator-controller-manager-84c6466d9b   1         1         1       9m38s

k api-resources | grep resources.
resourcegroups                                              resources.azure.com/v1api20200601                 true         ResourceGroup

# cleanup
az ad sp delete --id $appId # az ad sp list --show-mine -otable
```

```
cat << EOF | kubectl apply -f -
apiVersion: resources.azure.com/v1api20200601
kind: ResourceGroup
metadata:
  name: aso-sample-rg
  namespace: default
spec:
  location: westcentralus
EOF

kubectl describe resourcegroups/aso-sample-rg -n default
  Type    Reason               Age                    From                     Message
  ----    ------               ----                   ----                     -------
  Normal  CredentialFrom       5m12s (x2 over 5m12s)  resources_resourcegroup  Using credential from "default/aso-credential"
  Normal  BeginCreateOrUpdate  5m10s                  resources_resourcegroup  Successfully sent resource to Azure with ID "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/aso-sample-rg"

k logs -n azureserviceoperator-system -l app.kubernetes.io/name=azure-service-operator
I1118 18:43:44.572799       1 azure_generic_arm_reconciler_instance.go:422] "Resource successfully created/updated" logger="controllers.resources_resourcegroup" name="aso-sample-rg" namespace="default" azureName="aso-sample-rg" resourceID="/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/aso-sample-rg"
I1118 18:43:44.573104       1 recorder.go:104] "Successfully sent resource to Azure with ID \"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/aso-sample-rg\"" logger="events" type="Normal" object={"kind":"ResourceGroup","namespace":"default","name":"aso-sample-rg","uid":"63ac6209-f24a-4895-b099-7e1ef9269198","apiVersion":"resources.azure.com/v1api20200601storage","resourceVersion":"44929"} reason="BeginCreateOrUpdate"
I1118 18:43:45.034823       1 common.go:68] "updated resource in etcd" logger="controllers.resources_resourcegroup" name="aso-sample-rg" namespace="default" kind="&TypeMeta{Kind:ResourceGroup,APIVersion:resources.azure.com/v1api20200601storage,}" resourceVersion="44943" generation=1 uid="63ac6209-f24a-4895-b099-7e1ef9269198" ownerReferences=null creationTimestamp="2024-11-18 18:43:41 +0000 UTC" deletionTimestamp="0001-01-01 00:00:00 +0000 UTC" finalizers=["serviceoperator.azure.com/finalizer"] annotations={"serviceoperator.azure.com/latest-reconciled-generation":"1","serviceoperator.azure.com/operator-namespace":"azureserviceoperator-system","serviceoperator.azure.com/resource-id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/aso-sample-rg"} conditions="[Condition [Ready], Status = \"True\", ObservedGeneration = 1, Severity = \"\", Reason = \"Succeeded\", Message = \"\", LastTransitionTime = \"2024-11-18 18:43:45 +0000 UTC\"]" owner="Group: \"\", Kind: \"\", Name: \"\", ARMID: \"\""

az group list -otable
Name                                                                 Location       Status
-------------------------------------------------------------------  -------------  ---------
aso-sample-rg                                                        westcentralus  Succeeded
```

- https://azure.github.io/azure-service-operator/
- https://github.com/Azure/azure-service-operator

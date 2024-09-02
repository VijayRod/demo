```
az aks create -g $rg -n akskeda --enable-keda
kubectl get po -n kube-system --show-labels | grep keda
```
- https://learn.microsoft.com/en-us/azure/aks/keda-deploy-add-on-cli
<br>

- Scale applications based on Azure Log Analytics query result
<br>
tbd tcpdump did not have requests to http requests to loganalytics likely due to inactive scaledobject

```
spName="mysp$RANDOM"
spPassword=$(az ad sp create-for-rbac --name $spName --query password -o tsv)
sleep 30
appId=$(az ad sp list --display-name $spName --query "[].appId" -o tsv)
objectId=$(az ad sp list --display-name $spName --query "[].id" -o tsv)
tenantId=$(az account show --query tenantId -otsv)
echo $tenantId $appId $spPassword

az monitor log-analytics workspace create -g $rg -n laworkspace
az monitor log-analytics workspace show -g $rg -n laworkspace --query id -otsv

servicebus="servicebus$RANDOM"
az servicebus namespace create -g $rg -n $servicebus --sku Basic
az servicebus namespace show -g $rg -n $servicebus --query serviceBusEndpoint -otsv
echo $servicebus

https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#update-an-existing-aks-cluster
https://learn.microsoft.com/en-us/azure/aks/keda-deploy-add-on-cli#before-you-begin
az aks update -g $rg -n akskeda  --enable-oidc-issuer --enable-workload-identity
kubectl rollout restart deployment keda-operator -n kube-system
kubectl describe po -n kube-system -l app.kubernetes.io/name=keda-operator | grep Environment -A 15 # | grep AZURE_

# Update the values in the following
https://github.com/kedacore/sample-dotnet-worker-servicebus-queue/blob/main/deploy/workload-identity/deploy-app-with-workload-identity.yaml
cat << EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: order-processor-sa
  labels:
    azure.workload.identity/use: "true"
  annotations:
    azure.workload.identity/client-id: <azure-ad-app-id>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-processor
  labels:
    app: order-processor
    azure.workload.identity/use: "true"
spec:
  selector:
    matchLabels:
      app: order-processor
  template:
    metadata:
      labels:
        app: order-processor
    spec:
      serviceAccountName: order-processor-sa
      containers:
      - name: order-processor
        image: ghcr.io/kedacore/sample-dotnet-worker-servicebus-queue:latest
        env:
        - name: KEDA_SERVICEBUS_AUTH_MODE
          value: WorkloadIdentity
        - name: KEDA_SERVICEBUS_HOST_NAME
          value: <namespace-name>.servicebus.windows.net
        - name: KEDA_SERVICEBUS_QUEUE_NAME
          value: orders
EOF

# Update the values in the following
https://github.com/kedacore/sample-dotnet-worker-servicebus-queue/blob/main/deploy/workload-identity/deploy-app-autoscaling.yaml
https://keda.sh/docs/2.0/scalers/azure-log-analytics/
kubectl delete so order-scaler
cat << EOF | kubectl create -f -
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: trigger-auth-service-bus-orders
spec:
  podIdentity:
    provider: azure-workload
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-scaler
spec:
  scaleTargetRef:
    name: order-processor
  # minReplicaCount: 0 Change to define how many minimum replicas you want
  maxReplicaCount: 10
  triggers:
  - type: azure-log-analytics
    metadata:
      tenantId: "AZURE_AD_TENANT_ID"
      clientId: "SERVICE_PRINCIPAL_CLIENT_ID"
      clientSecret: "SERVICE_PRINCIPAL_PASSWORD"
      workspaceId: "LOG_ANALYTICS_WORKSPACE_ID"
      query: |
        Perf
        | limit 01
      threshold: "1900000000"
EOF
kubectl get so order-scaler # -oyaml # READY=True

kubectl get po -n kube-system -l app.kubernetes.io/name=keda-operator
kubectl dumpy capture deploy keda-operator -n kube-system
kubectl dumpy get -n kube-system

kubectl dumpy get -n kube-system dumpy-58266286
kubectl dumpy export -n kube-system dumpy-58266286 /tmp/tcpdump
kubectl dumpy stop -n kube-system dumpy-58266286
ls /tmp/tcpdump/dumpy*
```

To create a daemon set with a (shared) static persistent volume and ensure the pods are on different nodes for monitoring cache consistency across nodes, use the following for an existing file share and Kubernetes secret.

```
# Replace the below with appropriate values.
rgname=
clustername=aks
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
# Retrieve the node resource group name for the cluster.
nodeResourceGroupName=$(az aks show --resource-group $rgname --name $clustername --query nodeResourceGroup -o tsv)
```

```
# To create the kubernetes static persistent volume, persistent volume claim, and pod.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: file.csi.azure.com
  name: azurefile
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: azurefile-premium
  csi:
    driver: file.csi.azure.com
    readOnly: false
    volumeHandle: id123456  # make sure this volumeid is unique for every identical share in the cluster
    volumeAttributes:
      resourceGroup: $nodeResourceGroupName  # optional, only set this when storage account is not in the same resource group as node
      shareName: $shareName
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - uid=0
    - gid=0
    - mfsymlinks
    - cache=strict
    - nosharesock
    - nobrl
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azurefile-premium
  volumeName: azurefile
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: volume
          mountPath: /mnt/azure
      terminationGracePeriodSeconds: 30
      volumes:
      - name: volume
        persistentVolumeClaim:
          claimName: azurefile
EOF
```

```
# kubectl get po -owide
NAME                          READY   STATUS              RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
fluentd-elasticsearch-rh2np   1/1     Running             0          6m27s   10.244.1.4    aks-nodepool1-51397738-vmss00000d   <none>           <none>
fluentd-elasticsearch-srr5j   1/1     Running             0          10m     10.244.0.20   aks-nodepool1-51397738-vmss00000b   <none>           <none>

# To create and list a file in the file share
kubectl exec -it fluentd-elasticsearch-rh2np -- touch /mnt/azure/myfile$(date -Iseconds)
kubectl exec -it fluentd-elasticsearch-rh2np -- ls /mnt/azure
kubectl exec -it fluentd-elasticsearch-srr5j -- ls /mnt/azure
az storage file list --share-name $shareName -otable
```

# To cleanup
kubectl delete ds fluentd-elasticsearch
kubectl delete pvc azurefile
kubectl delete pv azurefile

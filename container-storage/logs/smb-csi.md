Here are steps to create a Samba server with a StatefulSet in Linux using https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md. You can file any issues at https://github.com/kubernetes-csi/csi-driver-smb/issues. This is generally used with an on-prem SMB server.

```
# Replace the below with appropriate values.
rgname=
clustername=akssamba
```

```
# Create the cluster and retrieve the credentials.
az aks create -g $rgname -n $clustername
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

# Create the secret with the smb-server resources. 
# https://github.com/kubernetes-csi/csi-driver-smb/tree/master/deploy/example/smb-provisioner
kubectl create secret generic smbcreds --from-literal username=USERNAME --from-literal password="PASSWORD"
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/smb-provisioner/smb-server-networkdisk.yaml

# Create the storage class for the smb.csi.k8s.io provisioner, and a sample stateful set.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/storageclass-smb.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/statefulset.yaml
```

```
# Retrieve resources.
kubectl get sc smb
kubectl get pvc | grep smb
kubectl get po | grep smb

# Here is a sample output below.
TBD
```

```
# Execute into the container.
kubectl exec -it statefulset-smb-0 -- df -h

# Here is a sample output below.
TBD
```

```
# Retrieve logs from the SMB server pod.
kubectl logs app=smb-server

# Here is a sample output below.
TBD
```

```
# Cleanup.
kubectl delete statefulset statefulset-smb
kubectl delete svc smb-server
kubectl delete deploy smb-server
kubectl delete pvc pvc-networkdisk-smbshare
kubectl delete sc smb
kubectl delete secret smbcreds
```

```
helm repo add netapp-trident https://netapp.github.io/trident-helm-chart   
helm install trident netapp-trident/trident-operator --version 23.04.0  --create-namespace --namespace trident
kubectl describe torc trident | tail
```

```
    Trident Image:        docker.io/netapp/trident:23.04.0
  Message:                Trident installed
  Namespace:              trident
  Status:                 Installed
  Version:                v23.04.0
Events:
  Type    Reason      Age   From                        Message
  ----    ------      ----  ----                        -------
  Normal  Installing  68s   trident-operator.netapp.io  Installing Trident
  Normal  Installed   32s   trident-operator.netapp.io  Trident installed
  
kubectl get all -n trident --show-labels
NAME                                     READY   STATUS    RESTARTS   AGE    LABELS
pod/trident-controller-ff5775c95-jcw8k   6/6     Running   0          107s   app=controller.csi.trident.netapp.io,pod-template-hash=ff5775c95
pod/trident-node-linux-t79rf             2/2     Running   0          107s   app=node.csi.trident.netapp.io,controller-revision-hash=7544f99447,pod-template-generation=1
pod/trident-operator-7bb845946f-qzwxs    1/1     Running   0          2m6s   app=operator.trident.netapp.io,name=trident-operator,pod-template-hash=7bb845946f
NAME                  TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)              AGE    LABELS
service/trident-csi   ClusterIP   10.0.5.194   <none>        34571/TCP,9220/TCP   108s   app=controller.csi.trident.netapp.io,k8s_version=v1.26.6,trident_version=v23.04.0
NAME                                DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE    LABELS
daemonset.apps/trident-node-linux   1         1         1       1            1           <none>          108s   app=node.csi.trident.netapp.io,k8s_version=v1.26.6,kubectl.kubernetes.io/default-container=trident-main,trident_version=v23.04.0
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/trident-controller   1/1     1            1           108s   app=controller.csi.trident.netapp.io,k8s_version=v1.26.6,kubectl.kubernetes.io/default-container=trident-main,trident_version=v23.04.0
deployment.apps/trident-operator     1/1     1            1           2m8s   app.kubernetes.io/managed-by=Helm,app=operator.trident.netapp.io
NAME                                           DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/trident-controller-ff5775c95   1         1         1       108s   app=controller.csi.trident.netapp.io,pod-template-hash=ff5775c95
replicaset.apps/trident-operator-7bb845946f    1         1         1       2m8s   app=operator.trident.netapp.io,name=trident-operator,pod-template-hash=7bb845946f
  
kubectl describe po -n trident -l app=node.csi.trident.netapp.io

kubectl logs -n trident -l app=node.csi.trident.netapp.io
time="2023-09-28T23:56:21Z" level=info msg="Updated Trident controller with node registration." logLayer=csi_frontend node=aks-nodepool1-20742417-vmss000000 requestID=d6adb3dd-d193-47f5-8b83-cf1066a22259 requestSource=Internal workflow="plugin=activate"
time="2023-09-28T23:56:21Z" level=info msg="Listening for GRPC connections." name=/plugin/csi.sock net=unix

kubectl get torc trident
NAME      AGE
trident   17m

kubectl get torc trident -oyaml
apiVersion: trident.netapp.io/v1
kind: TridentOrchestrator
metadata:
  name: trident
spec:
...
status:
  currentInstallationParams:
    IPv6: "false"
    autosupportHostname: ""
    autosupportImage: docker.io/netapp/trident-autosupport:23.04
    autosupportProxy: ""
    autosupportSerialNumber: ""
    debug: "false"
    disableAuditLog: "true"
    enableForceDetach: "false"
    httpRequestTimeout: 90s
    imagePullPolicy: IfNotPresent
    imagePullSecrets: []
    imageRegistry: ""
    k8sTimeout: "30"
    kubeletDir: /var/lib/kubelet
    logFormat: text
    logLayers: ""
    logLevel: info
    logWorkflows: ""
    probePort: "17546"
    silenceAutosupport: "false"
    tridentImage: docker.io/netapp/trident:23.04.0
  message: Trident installed
  namespace: trident
  status: Installed
  version: v23.04.0
  ```
  
- https://netapp-trident.readthedocs.io/en/stable-v21.07/introduction.html: Trident is a fully supported open source project maintained by NetApp. ...using industry-standard interfaces, such as the Container Storage Interface (CSI).
- https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-nfs#install-astra-trident-using-helm: To dynamically provision NFS volumes, you need to install Astra Trident. Astra Trident is NetApp's dynamic storage provisioner that is purpose-built for Kubernetes.

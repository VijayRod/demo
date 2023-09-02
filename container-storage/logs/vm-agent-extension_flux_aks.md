`microsoft.flux`

```
rg=rgflux
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

az k8s-configuration flux create -g $rg -c aks -t managedClusters --name cluster-config -u https://github.com/Azure/gitops-flux2-kustomize-helm-mt --branch main --ns cluster-config
```

```
az k8s-configuration flux list -g $rg -c aks -t managedClusters -otable

Namespace       Name            Scope    ProvisioningState    ComplianceState    StatusUpdatedAt                   SourceUpdatedAt
--------------  --------------  -------  -------------------  -----------------  --------------------------------  -------------------------
cluster-config  cluster-config  cluster  Succeeded            Non-Compliant      2023-09-01T19:06:56.551000+00:00  2023-09-01T19:06:42+00:00
        
az k8s-configuration flux show -g $rg -c aks -t managedClusters --name cluster-config -otable
        
Namespace       Name            Scope    ProvisioningState    ComplianceState    StatusUpdatedAt                   SourceUpdatedAt
--------------  --------------  -------  -------------------  -----------------  --------------------------------  -------------------------
cluster-config  cluster-config  cluster  Succeeded            Non-Compliant      2023-09-01T19:06:56.551000+00:00  2023-09-01T19:06:42+00:00

kubectl get all -n flux-system

NAME                                           READY   STATUS    RESTARTS   AGE
pod/fluxconfig-agent-8648bbcb4f-jxsrp          2/2     Running   0          6m39s
pod/fluxconfig-controller-849899697b-qssgk     2/2     Running   0          6m39s
pod/helm-controller-f67ffb9dc-zxzmm            1/1     Running   0          6m39s
pod/kustomize-controller-59976978cf-wq926      1/1     Running   0          6m39s
pod/notification-controller-6cdf477d65-z2zlg   1/1     Running   0          6m39s
pod/source-controller-5bbb8c84dc-pj9jf         1/1     Running   0          6m39s
NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/notification-controller   ClusterIP   10.0.207.104   <none>        80/TCP    6m40s
service/source-controller         ClusterIP   10.0.198.147   <none>        80/TCP    6m40s
service/webhook-receiver          ClusterIP   10.0.102.20    <none>        80/TCP    6m40s
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fluxconfig-agent          1/1     1            1           6m40s
deployment.apps/fluxconfig-controller     1/1     1            1           6m40s
deployment.apps/helm-controller           1/1     1            1           6m40s
deployment.apps/kustomize-controller      1/1     1            1           6m40s
deployment.apps/notification-controller   1/1     1            1           6m40s
deployment.apps/source-controller         1/1     1            1           6m40s
NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/fluxconfig-agent-8648bbcb4f          1         1         1       6m41s
replicaset.apps/fluxconfig-controller-849899697b     1         1         1       6m41s
replicaset.apps/helm-controller-f67ffb9dc            1         1         1       6m41s
replicaset.apps/kustomize-controller-59976978cf      1         1         1       6m40s
replicaset.apps/notification-controller-6cdf477d65   1         1         1       6m40s
replicaset.apps/source-controller-5bbb8c84dc         1         1         1       6m41s

kubectl get po -n kube-system --show-labels | grep ext

extension-agent-79f88c7d65-sscss      2/2     Running   0          9m2s   app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=79f88c7d65
extension-operator-8fc67cf49-wmdsh    2/2     Running   0          9m2s   app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=8fc67cf49

kubectl get crd | grep flux

alerts.notification.toolkit.fluxcd.io            2023-09-01T19:05:25Z
buckets.source.toolkit.fluxcd.io                 2023-09-01T19:05:25Z
fluxconfigs.clusterconfig.azure.com              2023-09-01T19:05:25Z
fluxconfigsyncstatuses.clusterconfig.azure.com   2023-09-01T19:05:25Z
gitrepositories.source.toolkit.fluxcd.io         2023-09-01T19:05:25Z
helmcharts.source.toolkit.fluxcd.io              2023-09-01T19:05:25Z
helmreleases.helm.toolkit.fluxcd.io              2023-09-01T19:05:25Z
helmrepositories.source.toolkit.fluxcd.io        2023-09-01T19:05:25Z
imagepolicies.image.toolkit.fluxcd.io            2023-09-01T19:05:25Z
imagerepositories.image.toolkit.fluxcd.io        2023-09-01T19:05:25Z
imageupdateautomations.image.toolkit.fluxcd.io   2023-09-01T19:05:25Z
kustomizations.kustomize.toolkit.fluxcd.io       2023-09-01T19:05:25Z
ocirepositories.source.toolkit.fluxcd.io         2023-09-01T19:05:25Z
providers.notification.toolkit.fluxcd.io         2023-09-01T19:05:25Z
receivers.notification.toolkit.fluxcd.io         2023-09-01T19:05:25Z

az k8s-configuration flux delete -g $rg -c aks -t managedClusters --name cluster-config -y

- https://fluxcd.io/flux/installation/bootstrap/azure-devops/
- https://github.com/Azure/arc-k8s-demo
- https://github.com/Azure/gitops-flux2-kustomize-helm-mt
- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions-release#flux-gitops
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli
```

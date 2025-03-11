## azureml.app.aks

```
# aks-extension.azureml
rg=rgml
az group create -n $rg -l eastus2
az aks create -g $rg -n aks -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az k8s-extension create --name mllab --extension-type Microsoft.AzureML.Kubernetes --config enableTraining=True enableInference=True inferenceRouterServiceType=LoadBalancer allowInsecureConnections=True InferenceRouterHA=False --cluster-type managedClusters --cluster-name aks -g $rg --scope cluster

az k8s-extension show --name mllab --cluster-type connectedClusters --cluster-name aks -g $rg
kubectl get pods -n azureml
```

- https://learn.microsoft.com/en-us/azure/machine-learning/how-to-deploy-kubernetes-extension?view=azureml-api-2&tabs=deploy-extension-with-cli
- https://aka.ms/arcmltsg
  - https://learn.microsoft.com/en-us/azure/machine-learning/how-to-troubleshoot-kubernetes-extension?view=azureml-api-2

```
# aks-extension.azureml.resources

kubectl get all -n azureml
NAME                                                         READY   STATUS      RESTARTS   AGE
pod/aml-operator-6f99cc458c-zpwsw                            2/2     Running     0          163m
pod/amlarc-identity-controller-cb86645b9-qhmhc               2/2     Running     0          163m
pod/amlarc-identity-proxy-5dd64f65f4-ds8t2                   2/2     Running     0          163m
pod/azureml-fe-v2-5868d64648-6jk9c                           4/4     Running     0          163m
pod/azureml-ingress-nginx-controller-7db4bf4cc7-qnm9c        1/1     Running     0          163m
pod/gateway-7d4c4f7d77-5spfc                                 2/2     Running     0          163m
pod/healthcheck                                              0/1     Completed   0          164m
pod/inference-operator-controller-manager-58f676cdcd-77p5r   2/2     Running     0          163m
pod/metrics-controller-manager-5df854d9d6-4xk5s              2/2     Running     0          163m
pod/mllab-kube-state-metrics-766cd6dcc-m692j                 1/1     Running     0          163m
pod/mllab-prometheus-operator-8ffbc49bb-wqd2q                1/1     Running     0          163m
pod/prometheus-prom-prometheus-0                             2/2     Running     0          163m
pod/volcano-admission-76695cb547-mch2n                       1/1     Running     0          163m
pod/volcano-controllers-7fb464574c-6ghkk                     1/1     Running     0          163m
pod/volcano-scheduler-754747f8d8-cb6dz                       1/1     Running     0          163m

NAME                                                 TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                        AGE
service/amlarc-headless-svc                          ClusterIP      None           <none>          8080/TCP                       163m
service/amlarc-identity-proxy-service                ClusterIP      10.0.177.215   <none>          443/TCP                        163m
service/amlarc-identity-webhook-service              ClusterIP      10.0.85.54     <none>          443/TCP                        163m
service/azureml-fe                                   LoadBalancer   10.0.99.146    128.85.227.40   80:32373/TCP,443:30986/TCP     163m
service/azureml-fe-int-http                          ClusterIP      10.0.58.146    <none>          9001/TCP                       163m
service/azureml-ingress-nginx-controller             ClusterIP      10.0.113.70    <none>          80/TCP,443/TCP                 163m
service/azureml-ingress-nginx-controller-admission   ClusterIP      10.0.220.91    <none>          443/TCP                        163m
service/gateway                                      ClusterIP      10.0.183.37    <none>          5004/TCP                       163m
service/kubelet                                      ClusterIP      None           <none>          10250/TCP,10255/TCP,4194/TCP   163m
service/mllab-kube-state-metrics                     ClusterIP      10.0.13.230    <none>          8080/TCP
              163m
service/prom-prometheus                              ClusterIP      10.0.240.108   <none>          9090/TCP
              163m
service/prometheus-operated                          ClusterIP      None           <none>          9090/TCP
              163m
service/prometheus-operator                          ClusterIP      None           <none>          8080/TCP
              163m
service/volcano-admission-service                    ClusterIP      10.0.33.65     <none>          443/TCP
              163m
service/volcano-scheduler-service                    ClusterIP      10.0.59.104    <none>          8080/TCP
              163m

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/aml-operator                            1/1     1            1           163m
deployment.apps/amlarc-identity-controller              1/1     1            1           163m
deployment.apps/amlarc-identity-proxy                   1/1     1            1           163m
deployment.apps/azureml-fe-v2                           1/1     1            1           163m
deployment.apps/azureml-ingress-nginx-controller        1/1     1            1           163m
deployment.apps/gateway                                 1/1     1            1           163m
deployment.apps/inference-operator-controller-manager   1/1     1            1           163m
deployment.apps/metrics-controller-manager              1/1     1            1           163m
deployment.apps/mllab-kube-state-metrics                1/1     1            1           163m
deployment.apps/mllab-prometheus-operator               1/1     1            1           163m
deployment.apps/volcano-admission                       1/1     1            1           163m
deployment.apps/volcano-controllers                     1/1     1            1           163m
deployment.apps/volcano-scheduler                       1/1     1            1           163m

NAME                                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/aml-operator-6f99cc458c                            1         1         1       163m
replicaset.apps/amlarc-identity-controller-cb86645b9               1         1         1       163m
replicaset.apps/amlarc-identity-proxy-5dd64f65f4                   1         1         1       163m
replicaset.apps/azureml-fe-v2-5868d64648                           1         1         1       163m
replicaset.apps/azureml-ingress-nginx-controller-7db4bf4cc7        1         1         1       163m
replicaset.apps/gateway-7d4c4f7d77                                 1         1         1       163m
replicaset.apps/inference-operator-controller-manager-58f676cdcd   1         1         1       163m
replicaset.apps/metrics-controller-manager-5df854d9d6              1         1         1       163m
replicaset.apps/mllab-kube-state-metrics-766cd6dcc                 1         1         1       163m
replicaset.apps/mllab-prometheus-operator-8ffbc49bb                1         1         1       163m
replicaset.apps/volcano-admission-76695cb547                       1         1         1       163m
replicaset.apps/volcano-controllers-7fb464574c                     1         1         1       163m
replicaset.apps/volcano-scheduler-754747f8d8                       1         1         1       163m

NAME                                          READY   AGE
statefulset.apps/prometheus-prom-prometheus   1/1     163m
```

```
kubectl get all -n azureml --show-labels
NAME                                                         READY   STATUS      RESTARTS   AGE    LABELS
pod/aml-operator-6f99cc458c-zpwsw                            2/2     Running     0          164m   app=aml-operator,control-plane=controller-manager,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=6f99cc458c
pod/amlarc-identity-controller-cb86645b9-qhmhc               2/2     Running     0          164m   amlarc-component=identity,amlarc-identity-component=identity-controller,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=identity-controller,pod-template-hash=cb86645b9
pod/amlarc-identity-proxy-5dd64f65f4-ds8t2                   2/2     Running     0          164m   amlarc-component=identity,amlarc-identity-component=identity-proxy,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=identity-proxy,pod-template-hash=5dd64f65f4
pod/azureml-fe-v2-5868d64648-6jk9c                           4/4     Running     0          164m   azuremlappname=azureml-fe,azuremlappversion=v2,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=azureml-fe,pod-template-hash=5868d64648
pod/azureml-ingress-nginx-controller-7db4bf4cc7-qnm9c        1/1     Running     0          164m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azureml-ingress-nginx,app.kubernetes.io/name=azureml-ingress-nginx,ml.azure.com/amlarc-system=true,pod-template-hash=7db4bf4cc7
pod/gateway-7d4c4f7d77-5spfc                                 2/2     Running     0          164m   app=gateway,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=7d4c4f7d77
pod/healthcheck                                              0/1     Completed   0          165m   app=healthcheck,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system
pod/inference-operator-controller-manager-58f676cdcd-77p5r   2/2     Running     0          164m   control-plane=inference-operator-controller-manager,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=inference-operator,pod-template-hash=58f676cdcd
pod/metrics-controller-manager-5df854d9d6-4xk5s              2/2     Running     0          164m   amlarc-controller=metrics-controller,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=metrics-controller,pod-template-hash=5df854d9d6
pod/mllab-kube-state-metrics-766cd6dcc-m692j                 1/1     Running     0          164m   app.kubernetes.io/instance=mllab,app.kubernetes.io/name=kube-state-metrics,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=766cd6dcc
pod/mllab-prometheus-operator-8ffbc49bb-wqd2q                1/1     Running     0          164m   app.kubernetes.io/component=controller,app.kubernetes.io/name=prometheus-operator,app.kubernetes.io/version=0.50.0,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=prometheus-operator,pod-template-hash=8ffbc49bb
pod/prometheus-prom-prometheus-0                             2/2     Running     0          164m   app.kubernetes.io/instance=prom-prometheus,app.kubernetes.io/managed-by=prometheus-operator,app.kubernetes.io/name=prometheus,app.kubernetes.io/version=2.21.0,app=prometheus,apps.kubernetes.io/pod-index=0,controller-revision-hash=prometheus-prom-prometheus-697bd79474,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=prometheus,operator.prometheus.io/name=prom-prometheus,operator.prometheus.io/shard=0,prometheus=prom-prometheus,statefulset.kubernetes.io/pod-name=prometheus-prom-prometheus-0
pod/volcano-admission-76695cb547-mch2n                       1/1     Running     0          164m   app=volcano-admission,ml.azure.com/amlarc-system=true,pod-template-hash=76695cb547
pod/volcano-controllers-7fb464574c-6ghkk                     1/1     Running     0          164m   app=volcano-controller,ml.azure.com/amlarc-system=true,pod-template-hash=7fb464574c
pod/volcano-scheduler-754747f8d8-cb6dz                       1/1     Running     0          164m   app=volcano-scheduler,ml.azure.com/amlarc-system=true,pod-template-hash=754747f8d8

NAME                                                 TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)
              AGE    LABELS
service/amlarc-headless-svc                          ClusterIP      None           <none>          8080/TCP
              164m   app.kubernetes.io/managed-by=Helm
service/amlarc-identity-proxy-service                ClusterIP      10.0.177.215   <none>          443/TCP
              164m   amlarc-component=identity,app.kubernetes.io/managed-by=Helm
service/amlarc-identity-webhook-service              ClusterIP      10.0.85.54     <none>          443/TCP
              164m   amlarc-component=identity,app.kubernetes.io/managed-by=Helm
service/azureml-fe                                   LoadBalancer   10.0.99.146    128.85.227.40   80:32373/TCP,443:30986/TCP     164m   app.kubernetes.io/managed-by=Helm,azuremlappname=azureml-fe
service/azureml-fe-int-http                          ClusterIP      10.0.58.146    <none>          9001/TCP
              164m   app.kubernetes.io/managed-by=Helm,azuremlappname=azureml-fe
service/azureml-ingress-nginx-controller             ClusterIP      10.0.113.70    <none>          80/TCP,443/TCP                 164m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azureml-ingress-nginx,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=azureml-ingress-nginx,app.kubernetes.io/version=1.1.1,helm.sh/chart=ingress-nginx-4.0.15
service/azureml-ingress-nginx-controller-admission   ClusterIP      10.0.220.91    <none>          443/TCP
              164m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azureml-ingress-nginx,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=azureml-ingress-nginx,app.kubernetes.io/version=1.1.1,helm.sh/chart=ingress-nginx-4.0.15
service/gateway                                      ClusterIP      10.0.183.37    <none>          5004/TCP
              164m   app.kubernetes.io/managed-by=Helm,app=gateway
service/kubelet                                      ClusterIP      None           <none>          10250/TCP,10255/TCP,4194/TCP   164m   app.kubernetes.io/managed-by=prometheus-operator,app.kubernetes.io/name=kubelet,k8s-app=kubelet
service/mllab-kube-state-metrics                     ClusterIP      10.0.13.230    <none>          8080/TCP
              164m   app.kubernetes.io/instance=mllab,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=kube-state-metrics,ml.azure.com/billing-category=azureml-system
service/prom-prometheus                              ClusterIP      10.0.240.108   <none>          9090/TCP
              164m   app.kubernetes.io/managed-by=Helm,app=mllab-prometheus,heritage=Helm,release=mllab,self-monitor=true
service/prometheus-operated                          ClusterIP      None           <none>          9090/TCP
              164m   operated-prometheus=true
service/prometheus-operator                          ClusterIP      None           <none>          8080/TCP
              164m   app.kubernetes.io/component=controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prometheus-operator,app.kubernetes.io/version=0.50.0
service/volcano-admission-service                    ClusterIP      10.0.33.65     <none>          443/TCP
              164m   app.kubernetes.io/managed-by=Helm,app=volcano-admission
service/volcano-scheduler-service                    ClusterIP      10.0.59.104    <none>          8080/TCP
              164m   app.kubernetes.io/managed-by=Helm

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/aml-operator                            1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,app=aml-operator,control-plane=controller-manager,ml.azure.com/amlarc-system=true
deployment.apps/amlarc-identity-controller              1/1     1            1           164m   amlarc-component=identity,app.kubernetes.io/managed-by=Helm,ml.azure.com/amlarc-system=true
deployment.apps/amlarc-identity-proxy                   1/1     1            1           164m   amlarc-component=identity,app.kubernetes.io/managed-by=Helm,ml.azure.com/amlarc-system=true
deployment.apps/azureml-fe-v2                           1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,azuremlappname=azureml-fe,ml.azure.com/amlarc-system=true
deployment.apps/azureml-ingress-nginx-controller        1/1     1            1           164m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azureml-ingress-nginx,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=azureml-ingress-nginx,app.kubernetes.io/version=1.1.1,helm.sh/chart=ingress-nginx-4.0.15,ml.azure.com/amlarc-system=true
deployment.apps/gateway                                 1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,ml.azure.com/amlarc-system=true
deployment.apps/inference-operator-controller-manager   1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,control-plane=inference-operator-controller-manager,ml.azure.com/amlarc-system=true
deployment.apps/metrics-controller-manager              1/1     1            1           164m   amlarc-controller=metrics-controller,app.kubernetes.io/managed-by=Helm,ml.azure.com/amlarc-system=true
deployment.apps/mllab-kube-state-metrics                1/1     1            1           164m   app.kubernetes.io/instance=mllab,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=kube-state-metrics,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system
deployment.apps/mllab-prometheus-operator               1/1     1            1           164m   app.kubernetes.io/component=controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prometheus-operator,app.kubernetes.io/version=0.50.0,ml.azure.com/amlarc-system=true
deployment.apps/volcano-admission                       1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,app=volcano-admission,ml.azure.com/amlarc-system=true
deployment.apps/volcano-controllers                     1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,app=volcano-controller,ml.azure.com/amlarc-system=true
deployment.apps/volcano-scheduler                       1/1     1            1           164m   app.kubernetes.io/managed-by=Helm,app=volcano-scheduler,ml.azure.com/amlarc-system=true

NAME                                                               DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/aml-operator-6f99cc458c                            1         1         1       164m   app=aml-operator,control-plane=controller-manager,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=6f99cc458c
replicaset.apps/amlarc-identity-controller-cb86645b9               1         1         1       164m   amlarc-component=identity,amlarc-identity-component=identity-controller,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=identity-controller,pod-template-hash=cb86645b9
replicaset.apps/amlarc-identity-proxy-5dd64f65f4                   1         1         1       164m   amlarc-component=identity,amlarc-identity-component=identity-proxy,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=identity-proxy,pod-template-hash=5dd64f65f4
replicaset.apps/azureml-fe-v2-5868d64648                           1         1         1       164m   azuremlappname=azureml-fe,azuremlappversion=v2,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=azureml-fe,pod-template-hash=5868d64648
replicaset.apps/azureml-ingress-nginx-controller-7db4bf4cc7        1         1         1       164m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azureml-ingress-nginx,app.kubernetes.io/name=azureml-ingress-nginx,ml.azure.com/amlarc-system=true,pod-template-hash=7db4bf4cc7
replicaset.apps/gateway-7d4c4f7d77                                 1         1         1       164m   app=gateway,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=7d4c4f7d77
replicaset.apps/inference-operator-controller-manager-58f676cdcd   1         1         1       164m   control-plane=inference-operator-controller-manager,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=inference-operator,pod-template-hash=58f676cdcd
replicaset.apps/metrics-controller-manager-5df854d9d6              1         1         1       164m   amlarc-controller=metrics-controller,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=metrics-controller,pod-template-hash=5df854d9d6
replicaset.apps/mllab-kube-state-metrics-766cd6dcc                 1         1         1       164m   app.kubernetes.io/instance=mllab,app.kubernetes.io/name=kube-state-metrics,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,pod-template-hash=766cd6dcc
replicaset.apps/mllab-prometheus-operator-8ffbc49bb                1         1         1       164m   app.kubernetes.io/component=controller,app.kubernetes.io/name=prometheus-operator,app.kubernetes.io/version=0.50.0,ml.azure.com/amlarc-system=true,ml.azure.com/billing-category=azureml-system,ml.azure.com/infra-app=prometheus-operator,pod-template-hash=8ffbc49bb
replicaset.apps/volcano-admission-76695cb547                       1         1         1       164m   app=volcano-admission,ml.azure.com/amlarc-system=true,pod-template-hash=76695cb547
replicaset.apps/volcano-controllers-7fb464574c                     1         1         1       164m   app=volcano-controller,ml.azure.com/amlarc-system=true,pod-template-hash=7fb464574c
replicaset.apps/volcano-scheduler-754747f8d8                       1         1         1       164m   app=volcano-scheduler,ml.azure.com/amlarc-system=true,pod-template-hash=754747f8d8

NAME                                          READY   AGE    LABELS
statefulset.apps/prometheus-prom-prometheus   1/1     164m   app.kubernetes.io/managed-by=Helm,app=mllab-prometheus,heritage=Helm,ml.azure.com/amlarc-system=true,operator.prometheus.io/name=prom-prometheus,operator.prometheus.io/shard=0,release=mllab
```

```
helm list -n azureml
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                       APP VERSION
mllab   azureml         1               2025-03-07 18:57:21.26230553 +0000 UTC  deployed        amlarc-extension-1.1.71     1.16.0

helm uninstall mllab -n azureml # **Heads up: helm uninstall deletes the associated pods, deployments, etc., leaving just the namespace object with its secrets
```

```
# aks-extension.azureml.error.ExtensionTypeRegistrationGetFailed
az k8s-extension create
(ExtensionTypeRegistrationGetFailed) Extension type microsoft.azureml.kubernetes is not registered in region swedencentral. Extension is available in eastus2, northeurope, westeurope, southcentralus, westus2, centralus, francecentral, eastus, koreacentral, japaneast, westus, australiaeast, eastasia, uksouth, northcentralus, canadacentral, southeastasia, uaenorth, eastus2euap, westcentralus, westus3, ukwest, germanywestcentral, southafricanorth, canadaeast, southindia, brazilsouth, centralindia, chinaeast2, usgovvirginia. Please try to install in these regions.
```

## azureml.workspace

```
rg=rg
az group create -n $rg -l $loc
az ml workspace create -g $rg -n workspace
```

```
az ml workspace show -g $rg -n workspace --query id -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.MachineLearningServices/workspaces/workspace
```

- https://learn.microsoft.com/en-us/azure/machine-learning/how-to-configure-cli?view=azureml-api-2&tabs=public#set-up

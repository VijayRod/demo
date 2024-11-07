TBD (InvalidImageName)

```
rgname=testshack4
loc=swedencentral
clustername=akstls
acr="acr$RANDOM"

az group create -g $rgname -l $loc
az aks create -g $rgname -n $clustername
az aks get-credentials -g $rgname -n $clustername

# https://learn.microsoft.com/en-us/azure/aks/ingress-basic

NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

az acr create -g $rgname -n $acr --sku basic
az aks update -g $rgname -n $clustername --attach-acr $acr

# https://learn.microsoft.com/en-us/azure/aks/ingress-tls#use-tls-with-lets-encrypt-certificates

REGISTRY_NAME=$acr
CERT_MANAGER_REGISTRY=quay.io
CERT_MANAGER_TAG=v1.8.0
CERT_MANAGER_IMAGE_CONTROLLER=jetstack/cert-manager-controller
CERT_MANAGER_IMAGE_WEBHOOK=jetstack/cert-manager-webhook
CERT_MANAGER_IMAGE_CAINJECTOR=jetstack/cert-manager-cainjector
az acr import --name $REGISTRY_NAME --source $CERT_MANAGER_REGISTRY/$CERT_MANAGER_IMAGE_CONTROLLER:$CERT_MANAGER_TAG --image $CERT_MANAGER_IMAGE_CONTROLLER:$CERT_MANAGER_TAG
az acr import --name $REGISTRY_NAME --source $CERT_MANAGER_REGISTRY/$CERT_MANAGER_IMAGE_WEBHOOK:$CERT_MANAGER_TAG --image $CERT_MANAGER_IMAGE_WEBHOOK:$CERT_MANAGER_TAG
az acr import --name $REGISTRY_NAME --source $CERT_MANAGER_REGISTRY/$CERT_MANAGER_IMAGE_CAINJECTOR:$CERT_MANAGER_TAG --image $CERT_MANAGER_IMAGE_CAINJECTOR:$CERT_MANAGER_TAG

nodeRg=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -o tsv)
ip=$(az network public-ip create -g $nodeRg --name myAKSPublicIP --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv)
DNS_LABEL="dns$RANDOM"
NAMESPACE="ingress-basic"
STATIC_IP=$ip
helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$DNS_LABEL \
  --set controller.service.loadBalancerIP=$STATIC_IP \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
  
kubectl -n ingress-basic get services -o wide ingress-nginx-controller

# Set variable for ACR location to use for pulling images
ACR_URL=$(az acr show -g $rgname -n $acr --query id -otsv)
# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace ingress-basic \
  --version=$CERT_MANAGER_TAG \
  --set installCRDs=true \
  --set nodeSelector."kubernetes\.io/os"=linux \
  --set image.repository=$ACR_URL/$CERT_MANAGER_IMAGE_CONTROLLER \
  --set image.tag=$CERT_MANAGER_TAG \
  --set webhook.image.repository=$ACR_URL/$CERT_MANAGER_IMAGE_WEBHOOK \
  --set webhook.image.tag=$CERT_MANAGER_TAG \
  --set cainjector.image.repository=$ACR_URL/$CERT_MANAGER_IMAGE_CAINJECTOR \
  --set cainjector.image.tag=$CERT_MANAGER_TAG
```

TBD (InvalidImageName)
```
# kubectl get all -n ingress-basic
NAME                                            READY   STATUS             RESTARTS   AGE
pod/cert-manager-54467b9fdc-89wdn               0/1     InvalidImageName   0          20s
pod/cert-manager-cainjector-66c7bfbc7d-2gn9m    0/1     InvalidImageName   0          19m
pod/cert-manager-webhook-bfbf68589-67jqs        0/1     InvalidImageName   0          19m
pod/ingress-nginx-controller-5ff6bb675f-4lhrz   1/1     Running            0          166m
NAME                                         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)
   AGE
service/cert-manager                         ClusterIP      10.0.251.55    <none>         9402/TCP
   19m
service/cert-manager-webhook                 ClusterIP      10.0.160.231   <none>         443/TCP
   19m
service/ingress-nginx-controller             LoadBalancer   10.0.157.41    20.240.61.16   80:32222/TCP,443:30740/TCP   166m
service/ingress-nginx-controller-admission   ClusterIP      10.0.231.112   <none>         443/TCP
   166m
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager               0/1     1            0           19m
deployment.apps/cert-manager-cainjector    0/1     1            0           19m
deployment.apps/cert-manager-webhook       0/1     1            0           19m
deployment.apps/ingress-nginx-controller   1/1     1            1           166m
NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/cert-manager-54467b9fdc               1         1         0       19m
replicaset.apps/cert-manager-cainjector-66c7bfbc7d    1         1         0       19m
replicaset.apps/cert-manager-webhook-bfbf68589        1         1         0       19m
replicaset.apps/ingress-nginx-controller-5ff6bb675f   1         1         1       166m
NAME                                     COMPLETIONS   DURATION   AGE
job.batch/cert-manager-startupapicheck   0/1           19m        19m
```

- https://learn.microsoft.com/en-us/azure/aks/ingress-tls#install-cert-manager
- https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/
- https://cert-manager.io/docs/troubleshooting/acme/

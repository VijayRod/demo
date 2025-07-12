> ## httpproxy.k8s.access-api

```
# httpproxy.k8s.access-api
```
- https://kubernetes.io/docs/tasks/extend-kubernetes/http-proxy-access-api/

> ## httpproxy.k8s.aks.basic

```
# httpproxy.k8s.aks.basic

az aks create -g $rg -n aks -s $vmsize \ # only applies during creation, not for updates
  --http-proxy-config httpProxy=http://proxy.pretendhub.com:3128 \
                      httpsProxy=http://proxy.pretendhub.com:3128 \
                      noProxy='1.1.1.1,google.com'

root@aks-nodepool1-31060421-vmss000004:/# env | grep -i proxy
no_proxy=127.0.0.1,google.com,10.0.0.0/16,169.254.169.254,aks-rg2-efec8e-ohsy464e.hcp.swedencentral.azmk8s.io,localhost,1.1.1.1,konnectivity,10.224.0.0/12,168.63.129.16,10.244.0.0/16
https_proxy=https://proxy.pretendhub.com:8080/
NO_PROXY=127.0.0.1,google.com,10.0.0.0/16,169.254.169.254,aks-rg2-efec8e-ohsy464e.hcp.swedencentral.azmk8s.io,localhost,1.1.1.1,konnectivity,10.224.0.0/12,168.63.129.16,10.244.0.0/16
HTTPS_PROXY=https://proxy.pretendhub.com:8080/
HTTP_PROXY=http://proxy.pretendhub.com:8080/
http_proxy=http://proxy.pretendhub.com:8080/

root@aks-nodepool1-31060421-vmss000004:/# iptables-save | grep "1.1.1.1" # no results found
```

- https://learn.microsoft.com/en-us/azure/aks/http-proxy?tabs=use-azure-cli
- https://github.com/Azure/AKS/issues/205: AKS in VNET behind company HTTP proxy

```
cd /tmp
rm aks-proxy-config.json
cat << EOF > aks-proxy-config.json
{
  "httpProxy": "http://proxy.pretendhub.com:8080/", 
  "httpsProxy": "https://proxy.pretendhub.com:8080/", 
  "noProxy": [
    "1.1.1.1",
    "google.com"
  ]
}
EOF
cat aks-proxy-config.json
az aks update -g $rg -n aks --http-proxy-config aks-proxy-config.json
az aks show -g $rg -n aks --query httpProxyConfig
az aks get-credentials -g $rg -n aks --overwrite-existing; kubectl get no

# httpProxyConfig
{
  "effectiveNoProxy": [
    "127.0.0.1",
    "google.com",
    "10.0.0.0/16",
    "169.254.169.254",
    "aks-rg2-efec8e-ohsy464e.hcp.swedencentral.azmk8s.io",
    "localhost",
    "1.1.1.1",
    "konnectivity",
    "10.224.0.0/12",
    "168.63.129.16",
    "10.244.0.0/16"
  ],
  "httpProxy": "http://proxy.pretendhub.com:8080/",
  "httpsProxy": "https://proxy.pretendhub.com:8080/",
  "noProxy": [
    "1.1.1.1",
    "google.com"
  ],
  "trustedCa": null
}

root@aks-nodepool1-31060421-vmss000002:/# curl example.com -I
curl: (5) Could not resolve proxy: proxy.pretendhub.com

root@aks-nodepool1-31060421-vmss000002:/# curl google.com -I
HTTP/1.1 301 Moved Permanently

az aks show -g $rg -n aks --query networkProfile
  "podCidr": "10.244.0.0/16",
  "podCidrs": [
    "10.244.0.0/16"
  ],
  "podLinkLocalAccess": "IMDS",
  "serviceCidr": "10.0.0.0/16",
  "serviceCidrs": [
    "10.0.0.0/16"
  ],
  
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv); echo $noderg
subnetId=$(az network vnet subnet show -g $noderg --vnet-name aks-vnet-92427521 -n aks-subnet --query id -otsv); echo $subnetId
az network vnet subnet show --id $subnetId --query addressPrefix # 10.224.0.0/16

k delete po nginx
k run nginx --image=nginx
kubectl get po -owide -w

k describe po nginx
Containers:
  nginx:
    Environment:
      HTTP_PROXY:   http://proxy.pretendhub.com:8080/
      http_proxy:   http://proxy.pretendhub.com:8080/
      HTTPS_PROXY:  https://proxy.pretendhub.com:8080/
      https_proxy:  https://proxy.pretendhub.com:8080/
      NO_PROXY:     localhost,aks-rg-efec8e-xlodk0w7.hcp.swedencentral.azmk8s.io,169.254.169.254,10.0.0.0/16,168.63.129.16,127.0.0.1,10.244.0.0/16,konnectivity,10.224.0.0/12
      no_proxy:     localhost,aks-rg-efec8e-xlodk0w7.hcp.swedencentral.azmk8s.io,169.254.169.254,10.0.0.0/16,168.63.129.16,127.0.0.1,10.244.0.0/16,konnectivity,10.224.0.0/12
      
# an unrelated failure scenario shows pod creation with proxy configuration in kubelet logs
root@aks-nodepool1-10466718-vmss000006:/# cat /var/log/syslog | grep http_proxy | head -n 1
Jun 16 20:26:12 aks-nodepool1-10466718-vmss000006 kubelet[3724]: E0616 20:26:12.891791    3724 kuberuntime_manager.go:1274] "Unhandled Error" err="container &Container{Name:app,Image:busybox,Command:[sleep 3600],Args:[],WorkingDir:,Ports:[]ContainerPort{},Env:[]EnvVar{EnvVar{Name:HTTP_PROXY,Value:http://myproxy.server.com:8080/,ValueFrom:nil,},EnvVar{Name:http_proxy,Value:http://myproxy.server.com:8080/,ValueFrom:nil,},EnvVar{Name:HTTPS_PROXY,Value:https://myproxy.server.com:8080/,ValueFrom:nil,},EnvVar{Name:https_proxy,Value:https://myproxy.server.com:8080/,ValueFrom:nil,},EnvVar{Name:NO_PROXY,Value:localhost,aks-rg-efec8e-xlodk0w7.hcp.swedencentral.azmk8s.io,169.254.169.254,10.0.0.0/16,168.63.129.16,127.0.0.1,10.244.0.0/16,konnectivity,10.224.0.0/12,ValueFrom:nil,},EnvVar{Name:no_proxy,Value:localhost,aks-rg-efec8e-xlodk0w7.hcp.swedencentral.azmk8s.io,169.254.169.254,10.0.0.0/16,168.63.129.16,127.0.0.1,10.244.0.0/16,konnectivity,10.224.0.0/12,ValueFrom:nil,},},Resources:ResourceRequirements{Limits:ResourceList{},Requests:ResourceList{},Claims:[]ResourceClaim{},},VolumeMounts:[]VolumeMount{VolumeMount{Name:workdir,ReadOnly:false,MountPath:/mnt/data,SubPath:redacted,MountPropagation:nil,SubPathExpr:,RecursiveReadOnly:nil,},VolumeMount{Name:kube-api-access-wkn2n,ReadOnly:true,MountPath:/var/run/secrets/kubernetes.io/serviceaccount,SubPath:,MountPropagation:nil,SubPathExpr:,RecursiveReadOnly:nil,},},LivenessProbe:nil,ReadinessProbe:nil,Lifecycle:nil,TerminationMessagePath:/dev/termination-log,ImagePullPolicy:Always,SecurityContext:nil,Stdin:false,StdinOnce:false,TTY:false,EnvFrom:[]EnvFromSource{},TerminationMessagePolicy:File,VolumeDevices:[]VolumeDevice{},StartupProbe:nil,ResizePolicy:[]ContainerResizePolicy{},RestartPolicy:nil,} start failed in pod subpath-emptydir-demo_default(889326fa-da21-41e9-acc9-7596a3b64ff8): CreateContainerConfigError: failed to prepare subPath for volumeMount \"workdir\" of container \"app\"" logger="UnhandledError"
```

```
# httpproxy.k8s.aks.trustedCA.placeholder
# generate a dummy trustedCA value if this is only for cluster update testing

cd /tmp
rm aks-proxy-config.json
cat << EOF > aks-proxy-config.json
{
  "httpProxy": "http://myproxy.server.com:8080/", 
  "httpsProxy": "https://myproxy.server.com:8080/", 
  "noProxy": [
    "localhost",
    "127.0.0.1"
  ],
  "trustedCA": "LS0tLS1CRUdJT..LS0tLS0K"
}
EOF
cat aks-proxy-config.json
az aks update -g $rg -n aks --http-proxy-config aks-proxy-config.json
az aks show -g $rg -n aks --query httpProxyConfig

# httpProxyConfig
{
  "effectiveNoProxy": [
..
  ],
  "httpProxy": "http://myproxy.server.com:8080/",
  "httpsProxy": "https://myproxy.server.com:8080/",
  "noProxy": [
    "localhost",
    "127.0.0.1"
  ],
  "trustedCa": "LS0tLS1CRUdJT..LS0tLS0K"
}
```

```
# httpproxy.k8s.aks.cni.kubenet
# The route table rules do not change after setting up httpProxy, httpsProxy, or noProxy

rg=rgkube
az aks create -g $rg -n aks --network-plugin kubenet -s $vmsize -c 2
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv); echo $noderg

az network route-table route list -g $noderg --route-table-name aks-agentpool-28794932-routetable -otable
```

```
# httpproxy.k8s.istio
```
- https://istio.io/latest/docs/tasks/traffic-management/egress/http-proxy/#configure-traffic-to-external-https-proxy

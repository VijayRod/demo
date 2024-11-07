## tls-k8s-certificate

```
# kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
No resources found
```

## tls-k8s-certificate.spec.cluster

```
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl config view --raw -o jsonpath="{.clusters[?(@.name == 'aks')].cluster.certificate-authority-data}" | base64 -d | openssl x509 -text | grep -A2 Validity # Swap out the cluster name
        Validity
            Not Before: Nov  7 20:17:16 2024 GMT
            Not After : Nov  7 20:27:16 2054 GMT
# "Not Before" timestamp indicates when the cluster was created, and the certificate remains valid for a period of one year.
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#check-cluster-certificate-expiration-date
- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation

## tls-k8s-certificate.spec.cluster.apiserver
```
fqdn="aksls-rg-efec8e-52bbay1e.hcp.swedencentral.azmk8s.io"
curl https://$fqdn -k -v 2>&1 | grep expire
*  expire date: Nov  7 20:27:16 2026 GMT # i.e. one year after the cluster was initially set up
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#check-api-server-certificate-expiration-date
  
## tls-k8s-certificate.spec.cluster.node.tls

```
root@aks-nodepool1-26220731-vmss000000:/# ps auxw | grep kubelet
root        2683  2.0  1.5 1633396 128108 ?      Ssl  08:42   8:42 /usr/local/bin/kubelet ...--bootstrap-kubeconfig /var/lib/kubelet/bootstrap-kubeconfig ...--rotate-certificates=true

root@aks-nodepool1-78682173-vmss000000:/# cat /var/lib/kubelet/bootstrap-kubeconfig
apiVersion: v1
kind: Config
clusters:
- name: localcluster
  cluster:
    certificate-authority: /etc/kubernetes/certs/ca.crt
    server: https://aks-rg-efec8e-hcb4rckk.hcp.swedencentral.azmk8s.io:443
users:
- name: kubelet-bootstrap
  user:
    token: "03w2km.redacted"
contexts:
- context:
    cluster: localcluster
    user: kubelet-bootstrap
  name: bootstrap-context
current-context: bootstrap-context

root@aks-nodepool1-78682173-vmss000000:/# cat /host/var/lib/kubelet/bootstrap-kubeconfig
cat: /host/var/lib/kubelet/bootstrap-kubeconfig: No such file or directory
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#how-to-check-whether-current-agent-node-pool-is-tls-bootstrapping-enabled

## tls-k8s-certificate.spec.cluster.node.tls.rotation.auto

```
root@aks-nodepool1-26220731-vmss000000:/# ps auxw | grep kubelet
root        2683  2.0  1.5 1633396 128108 ?      Ssl  08:42   8:42 /usr/local/bin/kubelet ...--bootstrap-kubeconfig /var/lib/kubelet/bootstrap-kubeconfig ...--rotate-certificates=true
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#certificate-auto-rotation

## tls-k8s-certificate.spec.cluster.node.tls.rotation.manual

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#manually-rotate-your-cluster-certificates

## tls-k8s-certificate.spec.cluster.node.type.vmas

```
root@aks-nodepool1-57299033-vmss000000:/# openssl x509 -in /etc/kubernetes/certs/apiserver.crt -noout -enddate
notAfter=Nov  7 20:27:16 2026 GMT # i.e. one year after the cluster was initially set up
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#check-vmas-agent-node-certificate-expiration-date

## tls-k8s-certificate.spec.cluster.node.type.vmss

```
root@aks-nodepool1-57299033-vmss000000:/# openssl x509 -in  /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate
notAfter=Nov  7 18:24:00 2025 GMT # i.e. one year after the cluster was initially set up
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#check-certificate-expiration-for-the-virtual-machine-scale-set-agent-node

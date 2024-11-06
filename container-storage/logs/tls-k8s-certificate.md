## tls-k8s-certificate

```
# kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
No resources found
```

## tls-k8s-certificate.spec.cluster.tls

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

## tls-k8s-certificate.spec.cluster.tls.rotation.auto

```
root@aks-nodepool1-26220731-vmss000000:/# ps auxw | grep kubelet
root        2683  2.0  1.5 1633396 128108 ?      Ssl  08:42   8:42 /usr/local/bin/kubelet ...--bootstrap-kubeconfig /var/lib/kubelet/bootstrap-kubeconfig ...--rotate-certificates=true
```

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#certificate-auto-rotation

## tls-k8s-certificate.spec.cluster.tls.rotation.manual

- https://learn.microsoft.com/en-us/azure/aks/certificate-rotation#manually-rotate-your-cluster-certificates

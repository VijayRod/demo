```
mkdir /tmp/tls; cd /tmp/tls

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificate-signing-request
## service's DNS name, pod's DNS name, service's cluster IP, pod's IP
cat <<EOF | cfssl genkey - | cfssljson -bare server
{
  "hosts": [
    "my-svc.my-namespac.default.svc.cluster.local",
    "my-svc.my-namespac.default.pod.cluster.local",
    "10.0.106.173",
    "10.244.1.6"
  ],
  "CN": "my-pod.default.pod.cluster.local",
  "key": {
    "algo": "ecdsa",
    "size": 256
  }
}
EOF
ls server.csr server-key.pem

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificatesigningrequest-object-to-send-to-the-kubernetes-api
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: my-svc.my-namespace
spec:
  request: $(cat server.csr | base64 | tr -d '\n')
  signerName: example.com/serving
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF
## k describe csr my-svc.my-namespace
## k get csr my-svc.my-namespace -oyaml

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#get-the-certificate-signing-request-approved
kubectl certificate approve my-svc.my-namespace

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#sign-the-certificate-signing-request
cat <<EOF | cfssl gencert -initca - | cfssljson -bare ca
{
  "CN": "My Example Signer",
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
EOF
ls ca.pem ca-key.pem

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#issue-a-certificate
cat <<EOF > server-signing-config.json
{
    "signing": {
        "default": {
            "usages": [
                "digital signature",
                "key encipherment",
                "server auth"
            ],
            "expiry": "876000h",
            "ca_constraint": {
                "is_ca": false
            }
        }
    }
}
EOF
ls server-signing-config.json

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#upload-the-signed-certificate
kubectl get csr my-svc.my-namespace -o jsonpath='{.spec.request}' | \
  base64 --decode | \
  cfssl sign -ca ca.pem -ca-key ca-key.pem -config server-signing-config.json - | \
  cfssljson -bare ca-signed-server
kubectl get csr my-svc.my-namespace -o json | \
  jq '.status.certificate = "'$(base64 ca-signed-server.pem | tr -d '\n')'"' | \
  kubectl replace --raw /apis/certificates.k8s.io/v1/certificatesigningrequests/my-svc.my-namespace/status -f -
## kubectl get csr my-svc.my-namespace -o jsonpath='{.status.certificate}'

# https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#download-the-certificate-and-use-it
kubectl get csr my-svc.my-namespace -o jsonpath='{.status.certificate}' \
    | base64 --decode > server.crt
kubectl create configmap example-serving-ca --from-file ca.crt=ca.pem
```

```
# To cleanup
kubectl delete configmap example-serving-ca
kubectl delete csr my-svc.my-namespace
ls
cd /tmp/; rmdir /tmp/tls --ignore-fail-on-non-empty
```
 
- https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
- https://github.com/MicrosoftDocs/azure-docs/issues/46769

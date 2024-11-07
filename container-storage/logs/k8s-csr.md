```
k api-resources
certificatesigningrequests          csr                 certificates.k8s.io/v1                 false        CertificateSigningRequest

kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
No resources found

kubectl get csr mutateme.default.svc -o yaml
status:
  conditions:
  - lastTransitionTime: "2023-08-04T21:17:37Z"
    lastUpdateTime: "2023-08-04T21:17:38Z"
    message: This CSR was approved by kubectl certificate approve.
    reason: KubectlApprove
    status: "True"
    type: Approved
  - lastTransitionTime: "2023-08-04T21:17:37Z"
    lastUpdateTime: "2023-08-04T21:17:37Z"
    message: 'invalid usage for client certificate: server auth'
    reason: SignerValidationFailure
    status: "True"
    type: Failed
```

- https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
- https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/: certificates.k8s.io API

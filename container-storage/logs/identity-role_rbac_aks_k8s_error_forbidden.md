```
E1121 19:13:53.033199       1 reflector.go:138] pkg/mod/k8s.io/client-go@v0.20.0-beta.1/tools/cache/reflector.go:167: Failed to watch *v1beta1.AzureApplicationGatewayRewrite: failed to list *v1beta1.AzureApplicationGatewayRewrite: azureapplicationgatewayrewrites.appgw.ingress.azure.io is forbidden: User "system:serviceaccount:kube-system:ingress-appgw-sa" cannot list resource "azureapplicationgatewayrewrites" in API group "appgw.ingress.azure.io" at the cluster scope

kubectl auth  can-i get azureapplicationgatewayrewrites --as system:serviceaccount:kube-system:ingress-appgw-sa
no
```

- TBD https://stackoverflow.com/questions/59375922/serviceaccount-cannot-list-resource-pods-in-namespace-though-it-has-role-with
- TBD https://stackoverflow.com/questions/67151953/forbidden-resource-in-api-group-at-the-cluster-scope
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/user-cannot-get-cluster-resources

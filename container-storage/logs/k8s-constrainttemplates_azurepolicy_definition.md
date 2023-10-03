```
kubectl get constrainttemplates | grep k8sazure

kubectl describe constrainttemplates k8sazurev1blockdefault | grep azure-policy-definition-id
# kubectl describe k8sazurev1blockdefault | grep azure-policy-definition-id

Annotations:  azure-policy-definition-id-1: /providers/Microsoft.Authorization/policyDefinitions/9f061a12-e40d-4183-a00e-171812443373
```

- https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions/Azure%20Government/Kubernetes
- https://learn.microsoft.com/en-us/azure/aks/policy-reference
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes#assign-a-policy-definition
- https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies#kubernetes

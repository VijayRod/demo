```
kubectl api-resources | grep hook
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
mutatingwebhookconfigurations                           admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                         admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration

kubectl get mutatingwebhookconfigurations
NAME                               WEBHOOKS   AGE
aks-node-mutating-webhook          1          2d13h
aks-webhook-admission-controller   1          2d13h

kubectl get validatingwebhookconfigurations
NAME                          WEBHOOKS   AGE
aks-node-validating-webhook   1          2d13h
```

- https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/
- https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/
- https://learn.microsoft.com/en-us/azure/aks/faq: admission controllers
- https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/aks-triage-controllers

```
# Webhooks.Rules

kubectl describe mutatingwebhookconfiguration
Kind:         MutatingWebhookConfiguration
Webhooks:
  Name:            aks-node-mutating-webhook.azmk8s.io
  Rules:
...

kubectl describe validatingwebhookconfiguration
Kind:         ValidatingWebhookConfiguration
Webhooks:
  Name:            aks-node-validating-webhook.azmk8s.io
  Rules:
...
```

- https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#matching-requests-rules

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
- https://kubernetes.io/docs/reference/access-authn-authz/webhook/
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

```
# webhook.disable
```

- https://discuss.elastic.co/t/can-i-disable-the-webhook/226113: the easiest way to disable the webhook is to remove its configuration from Kubernetes: kubectl delete validatingwebhookconfiguration. If you want to re-enable it later, just reapply ECK yaml manifests.
- https://www.elastic.co/guide/en/cloud-on-k8s/1.2/k8s-disable-webhook.html: kubectl delete validatingwebhookconfigurations

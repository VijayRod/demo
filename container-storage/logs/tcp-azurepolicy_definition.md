```
# PublicURL
# https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
{
  "properties": {
    "policyRule": {
      "if": {
        "field": "type",
        "in": [
          "Microsoft.Kubernetes/connectedClusters",
          "Microsoft.ContainerService/managedClusters"
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "templateInfo": {
            "sourceType": "PublicURL",
            "url": "https://store.policy.core.windows.net/kubernetes/block-default-namespace/v1/template.yaml"
...
"id": "/providers/Microsoft.Authorization/policyDefinitions/9f061a12-e40d-4183-a00e-171812443373",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "9f061a12-e40d-4183-a00e-171812443373"

curl -kv https://store.policy.core.windows.net/kubernetes/block-default-namespace/v1/template.yaml
*   Trying RedactedIp:443...
* TCP_NODELAY set
* Connected to store.policy.core.windows.net (RedactedIp) port 443 (#0)
...
<
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sazurev1blockdefault
spec:
  crd:
...
```

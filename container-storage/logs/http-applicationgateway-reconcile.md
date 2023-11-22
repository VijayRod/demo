```
# cache: Config has NOT changed
I1121 19:42:08.811787       1 reflector.go:381] pkg/mod/k8s.io/client-go@v0.20.0-beta.1/tools/cache/reflector.go:167: forcing resync
I1121 19:42:08.811794       1 reflector.go:381] pkg/mod/k8s.io/client-go@v0.20.0-beta.1/tools/cache/reflector.go:167: forcing resync
I1121 19:42:31.370574       1 mutate_aks.go:94] [mutate_aks] Found IPs: map[/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg2_aks_swedencentral/providers/Microsoft.Network/applicationGateways/myApplicationGateway/frontendIPConfigurations/appGatewayFrontendIP:20.240.171.53]
I1121 19:42:31.371352       1 mutate_app_gateway.go:70] Existing App Gateway config: {
-- Existing App Gwy Config --    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg2_aks_swedencentral/providers/Microsoft.Network/applicationGateways/myApplicationGateway",
-- Existing App Gwy Config --    "location": "swedencentral",
...
I1121 19:42:41.962404       1 mutate_app_gateway.go:153] cache: Config has NOT changed! No need to connect to ARM.
I1121 19:42:41.962423       1 controller.go:152] Completed last event loop run in: 249.974349ms

# cache: Updated with latest applied config
-- App Gwy config --}
1 mutate_app_gateway.go:177] BEGIN AppGateway deployment
1 client.go:206] OperationID='redacto-1111-1111-1111-111111111111'
1 reflector.go:381] pkg/mod/k8s.io/client-go@v0.21.2/tools/cache/reflector.go:167: forcing resync
1 mutate_app_gateway.go:185] Applied generated Application Gateway configuration
1 mutate_app_gateway.go:200] cache: Updated with latest applied config.
1 mutate_app_gateway.go:204] END AppGateway deployment
1 controller.go:151] Completed last event loop run in: 43.878711659s
```

- https://azure.github.io/application-gateway-kubernetes-ingress/features/agic-reconcile/: reconcilePeriodSeconds: 30

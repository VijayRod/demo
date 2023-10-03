```
# curl $(az network public-ip show -g myResourceGroupAG -n myAGPublicIPAddress --query [ipAddress] --output tsv)
Hello World from host myVM1!

# az network application-gateway show-backend-health -g myResourceGroupAG -n myAppGateway
# az network application-gateway show-backend-health -g myResourceGroupAG -n myAppGateway | grep health\"
{
  "backendAddressPools": [
    {
      "backendAddressPool": {
        "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/myResourceGroupAG/providers/Microsoft.Network/applicationGateways/myAppGateway/backendAddressPools/appGatewayBackendPool",
        "resourceGroup": "myResourceGroupAG"
      },
      "backendHttpSettingsCollection": [
        {
          "backendHttpSettings": {
            "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/myResourceGroupAG/providers/Microsoft.Network/applicationGateways/myAppGateway/backendHttpSettingsCollection/appGatewayBackendHttpSettings",
            "resourceGroup": "myResourceGroupAG"
          },
          "servers": [
            {
              "address": "10.21.1.4",
              "health": "Healthy",
              "healthProbeLog": "Success. Received 200 status code"
            },
            {
              "address": "10.21.1.5",
              "health": "Healthy",
              "healthProbeLog": "Success. Received 200 status code"
            }
          ]
        }
      ]
    }
  ]
}

# nslookup $(az network public-ip show -g myResourceGroupAG -n myAGPublicIPAddress --query [ipAddress] --output tsv)
** server can't find redactedn4.redactedn3.62.168.in-addr.arpa: NXDOMAIN
```

- https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-cli
- https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-faq
- https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-backend-health-troubleshooting
- https://learn.microsoft.com/en-us/azure/architecture/web-apps/spring-apps/guides/spring-cloud-reverse-proxy: a common reverse proxy service like Azure Application Gateway

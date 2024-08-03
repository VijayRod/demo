```
# curl $(az network public-ip show -g myResourceGroupAG -n myAGPublicIPAddress --query [ipAddress] --output tsv)
Hello World from host myVM1!

# az network application-gateway start -g $rg -n appgw
# az network application-gateway show-backend-health -g myResourceGroupAG -n myAppGateway

# nslookup $(az network public-ip show -g myResourceGroupAG -n myAGPublicIPAddress --query [ipAddress] --output tsv)
** server can't find redactedn4.redactedn3.62.168.in-addr.arpa: NXDOMAIN
```

- https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-cli for the descriptions
- https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-faq
- https://learn.microsoft.com/en-us/azure/architecture/web-apps/spring-apps/guides/spring-cloud-reverse-proxy: a common reverse proxy service like Azure Application Gateway

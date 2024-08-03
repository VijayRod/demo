You can find the sample at http-applicationgateway-aks_agic_sample_aspnetapp.md.

- https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-probe-overview#source-ip-address
  If the server in the backend pool is a private endpoint, the source IP address will be from your application gateway subnet's address space.
  The monitoring behavior works by making an HTTP GET request to the IP addresses or FQDN configured in the backend pool. For default probes if the backend http settings are configured for HTTPS, the probe uses HTTPS to test health of the backend servers.

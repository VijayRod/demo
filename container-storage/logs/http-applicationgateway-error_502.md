Intermittent 502 Bad Gateway errors may be linked to the size of the VM hosting the destination application. Consider increasing it, for example from Standard_D4s_v5 to Standard_D8s_v3. To expedite error reproduction, run a performance benchmark test simultaneously on the VM hosting the destination application.

```
# Terminal 1 (SSH into a node)
# Run a performance benchmark test using fio

# Terminal 2 (client)
# Set the Application Gateway IP address
ip=$(az network public-ip show -n pip-agw -g repro-502 --query ipAddress -o tsv)
cd /tmp/repro-502/jmeter; jmeter -n -t repro-502.jmx -f -l results.log -Jbackend_protocol=https -Jip_address=$ip

# Terminal 3 (client)
# Monitor for 502 errors
while true; do date; cat /tmp/repro-502/jmeter/results.log | grep -e ,502,B -e Conn; sleep 5; done
# while true; do date; echo 502 - $(cat /tmp/repro-502/jmeter/results.log | grep -e ',502,Bad Gateway,' | wc -l); sleep 5; done
# while true; do date; echo NOK - $(cat /tmp/repro-502/jmeter/results.log | grep -v OK | wc -l); sleep 5; done

# Destination VM capture shows TCP reset just before the 502 Bad Gateway (occurrence time Monday, December 4, 2023 19:10:24.032) returned by the application gateway to the client. The logs also indicate a 5-second gap between the last packet and the reset
# In the below, 10.10.1.250 is the LB frontend IP, which is also seen in (kubectl get svc -n ingress-nginx -oyaml).spec.loadBalancerIP, or in (kubectl get ing -A).Address or in (kubectl get ing -oyaml -A).status.loadBalancer.ingress.ip. Additionally, it is the application gateway backend IP address. 10.10.0.4 is the Application gateway instance private IP address
tcp.stream eq 2399 # tcp.connection.rst
375635	2023-12-04 19:10:17.687851	10.10.0.4	10.10.1.250	TCP	66	36304 → 443 [ACK] Seq=2556 Ack=4772 Win=64512 Len=0 TSval=3229505999 TSecr=1506175652
382431	2023-12-04 19:10:22.705978	10.10.0.4	10.10.1.250	TCP	60	36304 → 443 [RST, ACK] Seq=2556 Ack=1 Win=0 Len=0
```

- https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-troubleshooting-502

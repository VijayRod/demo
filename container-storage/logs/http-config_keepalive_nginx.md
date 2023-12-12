```
# The keepalive_timeout setting in Nginx is specifically for HTTP keepalive,
# distinct from TCP socket keepalive (tcp_keepalive). This parameter governs
# the maximum duration for HTTP keepalive, allowing the reuse of the same
# TCP connection for multiple HTTP requests. The default is 75s, permitting
# the connection to remain active, whether idle or busy, for at least 75 seconds
# before Nginx gracefully terminates it.

# Adjusting the keepalive_timeout option. You can experiment with values like 3s or 0s, but be cautious, as setting it too low may lead to increased loads on the ingress controller due to more frequent connection closures.

kubectl run nginx --image=nginx
sleep 10
kubectl exec -it nginx -- bash

# root@nginx
apt-get update && apt-get install vim -y # vi
ls /etc/nginx/conf.d/ # default.conf
cat /etc/nginx/conf.d/default.conf | grep time
vi /etc/nginx/conf.d/default.conf
```

- https://www.baeldung.com/linux/nginx-timeouts
- https://www.nginx.com/blog/10-tips-for-10x-application-performance/
- https://stackoverflow.com/questions/46419976/default-value-of-nginx-keepalive
- https://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout
- https://stackoverflow.com/questions/10550558/nginx-tcp-websockets-timeout-keepalive-config

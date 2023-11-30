```
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
- https://www.nginx.com/resources/wiki/start/topics/examples/full/: Full Example Configuration
- https://stackoverflow.com/questions/37695036/cannot-use-vim-vi-nano-yum-inside-docker-container
- https://wiki.nginx.org/Configuration
- https://stackoverflow.com/questions/46419976/default-value-of-nginx-keepalive
- https://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout
- https://stackoverflow.com/questions/10550558/nginx-tcp-websockets-timeout-keepalive-config

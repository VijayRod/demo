```
# tcp.keepalive
# TCP keepalive (so_keepalive), distinct from HTTP keepalive_timeout, prevents firewalls and similar entities from terminating the connection by regularly sending "empty" TCP packets. This ensures the connection remains active, allowing for normal operation. The default value is 0, indicating that no keepalive packets are sent.

# Consider setting the option on the client side; if the client is a Linux VM,

sysctl -a | grep keepalive # 
cat /proc/sys/net/ipv4/tcp_keepalive_time # 7200
echo 3 > /proc/sys/net/ipv4/tcp_keepalive_time
sysctl -p # load
sysctl -a | grep keepalive # net.ipv4.tcp_keepalive_time = 3

cat /proc/sys/net/ipv4/tcp_keepalive_intvl # 75
echo 3 > /proc/sys/net/ipv4/tcp_keepalive_intvl
sysctl -p
sysctl -a | grep keepalive # net.ipv4.tcp_keepalive_intvl = 3
```

- https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/overview.html
- https://github.com/kubernetes/ingress-nginx/issues/5558: Setting so_keepalive for gRPC streaming. need to use a custom template
- https://github.com/nviennot/nginx-tcp-keepalive: Nginx TCP keepalive module. tcp_keepalive
- https://unix.stackexchange.com/questions/519501/default-tcp-keepalive-settings
- https://www.looklinux.com/how-to-configure-tcp-keepalive-setting-in-linux/
- https://blog.cloudflare.com/when-tcp-sockets-refuse-to-die/
- https://codearcana.com/posts/2015/08/28/tcp-keepalive-is-a-lie.html
- https://tech.instacart.com/the-vanishing-thread-and-postgresql-tcp-connection-parameters-93afc0e1208c

```
# tcp.keepalive.istio

k get envoyfilters -A
```
https://my.f5.com/manage/s/article/K00026550: K00026550: Istio Ingress Gateway TCP keepalive
https://github.com/istio/istio/issues/28879: Istio ingress gateway TCP keepalive setting for downstream connection

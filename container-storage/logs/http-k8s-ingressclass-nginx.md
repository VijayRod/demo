```
# To create a basic nginx ingress controller without customizing the defaults
NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
```

```
# kubectl get ingressclass
NAME      CONTROLLER                             PARAMETERS   AGE
nginx     k8s.io/ingress-nginx                   <none>       8s

# kubectl get all -n ingress-basic
NAME                                           READY   STATUS    RESTARTS   AGE
pod/ingress-nginx-controller-7687f9d45-g5r5r   1/1     Running   0          68s
NAME                                         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)  AGE
service/ingress-nginx-controller             LoadBalancer   10.0.81.148    4.225.30.24   80:30207/TCP,443:30295/TCP   68s
service/ingress-nginx-controller-admission   ClusterIP      10.0.125.215   <none>        443/TCP  68s
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           68s
NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-7687f9d45   1         1         1       68s

# kubectl describe po -n ingress-basic ingress-nginx-controller-7687f9d45-g5r5r | grep image
  Normal  Pulled     106s  kubelet                   Successfully pulled image "registry.k8s.io/ingress-nginx/controller:v1.8.1@sha256:e5redacted" in 10.474047001s (10.474057201s including waiting)
  
# kubectl exec -it -n ingress-basic ingress-nginx-controller-7687f9d45-g5r5r -- nginx -v
nginx version: nginx/1.21.6

# kubectl exec -it -n ingress-basic ingress-nginx-controller-7687f9d45-zhtmj -- nginx -V
nginx version: nginx/1.21.6
built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r10)
built with OpenSSL 3.1.1 30 May 2023
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --modules-path=/etc/nginx/modules --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-compat --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_addition_module --with-http_geoip_module --with-http_gzip_static_module --with-http_sub_module --with-http_v2_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-threads --with-http_secure_link_module --with-http_gunzip_module --with-file-aio --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --without-http_uwsgi_module --without-http_scgi_module --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wno-deprecated-declarations -fno-strict-aliasing -D_FORTIFY_SOURCE=2 --param=ssp-buffer-size=4 -DTCP_FASTOPEN=23 -fPIC -I/root/.hunter/_Base/d45d77d/aab92d8/3b7ee27/Install/include -Wno-cast-function-type -m64 -mtune=generic' --with-ld-opt='-fPIE -fPIC -pie -Wl,-z,relro -Wl,-z,now -L/root/.hunter/_Base/d45d77d/aab92d8/3b7ee27/Install/lib' --user=www-data --group=www-data --add-module=/tmp/build/ngx_devel_kit-0.3.1 --add-module=/tmp/build/set-misc-nginx-module-0.33 --add-module=/tmp/build/headers-more-nginx-module-0.33 --add-module=/tmp/build/ngx_http_substitutions_filter_module-b8a71eacc7f986ba091282ab8b1bbbc6ae1807e0 --add-module=/tmp/build/lua-nginx-module-0.10.21 --add-module=/tmp/build/stream-lua-nginx-module-0.0.11 --add-module=/tmp/build/lua-upstream-nginx-module-8aa93ead98ba2060d4efd594ae33a35d153589bf --add-module=/tmp/build/nginx_ajp_module-fcbb2ccca4901d317ecd7a9dabb3fec9378ff40f --add-dynamic-module=/tmp/build/nginx-http-auth-digest-1.0.0 --add-dynamic-module=/tmp/build/nginx-opentracing-0.19.0/opentracing --add-dynamic-module=/tmp/build/ModSecurity-nginx-1.0.3 --add-dynamic-module=/tmp/build/ngx_http_geoip2_module-a26c6beed77e81553686852dceb6c7fdacc5970d --add-dynamic-module=/tmp/build/ngx_brotli
```

```
# curl 4.225.30.24
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

```
# To cleanup
helm uninstall -n ingress-basic ingress-nginx
kubectl delete ns ingress-basic; kubectl delete ingressclass nginx
```

- https://learn.microsoft.com/en-us/azure/aks/ingress-basic
- https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
- https://github.com/kubernetes/ingress-nginx#supported-versions-table
- https://github.com/kubernetes/ingress-nginx/blob/main/docs/troubleshooting.md
- https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
- https://kubernetes.github.io/ingress-nginx/
- https://github.com/kubernetes/ingress-nginx/releases: registry.k8s.io/ingress-nginx/controller
- https://docs.nginx.com/nginx-ingress-controller/troubleshooting/troubleshoot-common/

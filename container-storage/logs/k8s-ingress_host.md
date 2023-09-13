```
kubectl delete ingress minimal-ingress
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "foo.bar.com"
    http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
kubectl get ingress
```

```
NAME              CLASS   HOSTS         ADDRESS        PORTS   AGE
minimal-ingress   nginx   foo.bar.com   20.91.172.64   80      4m11s

curl http://foo.bar.com --resolve foo.bar.com:80:20.91.172.64 -k -I
HTTP/1.1 200 OK

curl 20.91.172.64 -I
HTTP/1.1 404 Not Found
```

- https://kubernetes.io/docs/concepts/services-networking/ingress/#hostname-wildcards
- https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting

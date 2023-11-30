```
# To install
apt-get update
apt-get install nginx
```

```
# nginx -v
nginx version: nginx/1.18.0 (Ubuntu)

# curl -I 127.0.0.1
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Thu, 03 Aug 2023 07:12:40 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Thu, 03 Aug 2023 07:10:38 GMT
Connection: keep-alive
ETag: "64cb52ee-264"
Accept-Ranges: bytes
```

```
kubectl delete po nginx
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --type=LoadBalancer ##--name=public-svc
# kubectl expose po nginx --port=80 # curl ip
# kubectl expose po nginx --port=8080 --target-port=80 # curl ip:8080

kubectl delete deploy nginx
kubectl create deploy nginx --image=nginx --port=80 --replicas=2
kubectl scale deploy nginx --replicas=3
kubectl expose deploy nginx --type=LoadBalancer

kubectl delete po nginx nginx2
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
---
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx2
  name: nginx2
spec:
  containers:
  - image: nginx
    name: nginx2
    ports:
    - containerPort: 80
      hostPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
sleep 5
kubectl get po nginx nginx2 -owide
kubectl exec -it nginx2 -- bash # apt-get update && apt-get install curl iproute2 -y # curl -I 10.244.0.8 # ss -anlp
```

- https://nginx.org/en/docs/#introduction

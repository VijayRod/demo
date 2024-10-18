```
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: apiproxy
  namespace: default
spec:
  externalName: google.com
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  sessionAffinity: None
  type: ExternalName
EOF
```

```
# kubectl exec -it nginx -- curl apiproxy.default.svc.cluster.local | grep DOC
<!DOCTYPE html>
```

- https://kubernetes.io/docs/concepts/services-networking/service/#externalname

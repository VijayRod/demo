```
cat > /tmp/scratch.json << EOF
lol
EOF
cat /tmp/scratch.json # lol

cat << EOF | kubectl create -f -
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
EOF
```

- TBD https://tecadmin.net/write-append-multiple-lines-to-file-linux/

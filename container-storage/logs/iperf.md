```
# apt update -y && apt install iperf3 -y && iperf3 -h
```
- https://blog.aks.azure.com/2025/07/25/network-perf-aks: iperf3 was run as a container within Kubernetes pods in the host network namespace on selected nodes to generate single or multiple TCP streams simulating application traffic

```
kubectl delete po -all
kubectl run iperf-server --image=networkstatic/iperf3 --port=5201 --command -- iperf3 -s
kubectl get po -owide; kubectl get no
kubectl run iperf-client --image=networkstatic/iperf3 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-58827206-vmss00000n"}}}' --command -- sleep 3600 # --dry-run client -oyaml
kubectl get po -owide
kubectl exec -it iperf-client -- iperf3 -c 10.244.1.105 -u -b 10M -t 60
kubectl exec -it iperf-client -- iperf3 -c 8.8.8.8 -p 80 -u -b 10M -t 10
# kubectl exec -it iperf-client -- /bin/sh

...
[  5]  57.00-58.00  sec  1.19 MBytes  10.0 Mbits/sec  894
[  5]  58.00-59.00  sec  1.19 MBytes  10.0 Mbits/sec  895
[  5]  59.00-60.00  sec  1.19 MBytes  10.0 Mbits/sec  894
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-60.00  sec  71.5 MBytes  10.0 Mbits/sec  0.000 ms  0/53648 (0%)  sender
[  5]   0.00-60.00  sec  71.5 MBytes  10.0 Mbits/sec  0.283 ms  0/53648 (0%)  receiver
```

```
tbd
k delete deploy traefik
kubectl create deploy traefik --image=traefik:v2.10
k get po -owide -w
k delete svc traefik-udp
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: traefik-udp
  # namespace: traefik
spec:
  selector:
    app: traefik
  ports:
  - name: udp
    port: 9000
    protocol: UDP
    targetPort: 9000
  type: ClusterIP
EOF
k get svc
k logs -l app=traefik
kubectl exec -it iperf-client -- iperf3 -c 10.0.196.83 -p 9000 -u -b 10M -t 60
```

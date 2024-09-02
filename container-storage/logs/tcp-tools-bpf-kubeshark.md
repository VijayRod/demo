```
cd /tmp
sh <(curl -Ls https://kubeshark.co/install)
kubeshark tap # Start packet capture utilizing the Kubernetes configuration file at /root/.kube/config
```

```
2023-10-18T20:13:26Z INF versionCheck.go:23 > Checking for a newer version...
2023-10-18T20:13:26Z INF tapRunner.go:49 > Using Docker: registry=docker.io/kubeshark tag=
2023-10-18T20:13:26Z INF tapRunner.go:60 > Kubeshark will store the traffic up to a limit (per node). Oldest TCP/UDP streams will be removed once the limit is reached. limit=500Mi
2023-10-18T20:13:26Z INF common.go:69 > Using kubeconfig: path=/root/.kube/config
2023-10-18T20:13:26Z INF tapRunner.go:78 > Telemetry enabled=true notice="Telemetry can be disabled by setting the flag: --telemetry-enabled=false"
2023-10-18T20:13:26Z INF tapRunner.go:80 > Targeting pods in: namespaces=[""]
2023-10-18T20:13:27Z INF tapRunner.go:147 > Targeted pod: nginx
2023-10-18T20:13:27Z INF tapRunner.go:147 > Targeted pod: azure-ip-masq-agent-8xpnj
...
2023-10-18T20:13:33Z INF tapRunner.go:107 > Installed the Helm release: kubeshark
2023-10-18T20:13:33Z INF tapRunner.go:269 > Added: pod=kubeshark-front
2023-10-18T20:13:33Z INF tapRunner.go:178 > Added: pod=kubeshark-hub
2023-10-18T20:13:45Z INF proxy.go:31 > Starting proxy... namespace=default proxy-host=127.0.0.1 service=kubeshark-front src-port=8899
2023-10-18T20:13:46Z INF tapRunner.go:433 > Kubeshark is available at: url=http://127.0.0.1:8899
```

```
kubectl get po -l app.kubernetes.io/name=kubeshark --show-labels
NAME                                READY   STATUS    RESTARTS   AGE     LABELS
kubeshark-front-8468478598-xgdh8    1/1     Running   0          3m19s   app.kubernetes.io/instance=kubeshark,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=kubeshark,app.kubernetes.io/version=51.0.0,app.kubeshark.co/app=front,helm.sh/chart=kubeshark-51.0.0,pod-template-hash=8468478598
kubeshark-hub-5d6c878d6-qsxcq       1/1     Running   0          3m19s   app.kubernetes.io/instance=kubeshark,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=kubeshark,app.kubernetes.io/version=51.0.0,app.kubeshark.co/app=hub,helm.sh/chart=kubeshark-51.0.0,pod-template-hash=5d6c878d6
kubeshark-worker-daemon-set-fqtcb   2/2     Running   0          3m19s   app.kubernetes.io/instance=kubeshark,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=kubeshark,app.kubernetes.io/version=51.0.0,app.kubeshark.co/app=worker,controller-revision-hash=6f5f8f7c9b,helm.sh/chart=kubeshark-51.0.0,pod-template-generation=1
```

- https://kubeshark.co/
- https://docs.kubeshark.co/en/introduction: Think Wireshark re-invented for Kubernetes (K8s). Kubeshark employs various packet capture technologies (e.g. eBPF, AF_XDP, PF_RING)...

- https://www.kali.org/tools/hping3/

```
apt update -y && apt install hping3 -y && hping3 -v
hping3 -R -p 80 -s 12345 --flood <target_ip> # not required for the target port 80 to be open since DDoS checks are just before reaching the port

kubectl delete po nginx
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --port=8080 --target-port=80
kubectl get po -owide -w

# root@aks-nodepool1-22302342-vmss000001:/# curl 10.244.0.36 -I # HTTP/1.1 200 OK

hping3 -R -p 80 -s 12345 --flood 10.244.0.36
```

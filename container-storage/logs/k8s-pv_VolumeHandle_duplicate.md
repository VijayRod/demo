Create two statically provisioned persistent volumes with the same volumeHandle disk resource URI, two persistent volume claims, and two pods in the same node, all with different names. Note that the volume handle must be unique; therefore, this configuration is unsupported.

```
kubectl patch pvc pvc-azuredisk4 -p '{"spec":{"resources":{"requests":{"storage":"21Gi"}}}}' --type=merge

kubectl get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS        CLAIM                    STORAGECLASS   REASON   AGE
pv-azuredisk3   20Gi       RWO            Retain           Bound         default/pvc-azuredisk3   managed-csi             32m
pv-azuredisk4   22Gi       RWO            Retain           Bound         default/pvc-azuredisk4   managed-csi             32m

kubectl get po -A -owide | grep azuredisk | grep 000000
```

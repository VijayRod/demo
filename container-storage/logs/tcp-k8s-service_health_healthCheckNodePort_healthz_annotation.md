```
# To add the annotation to ingress-nginx with helm
helm install... --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

# kubectl describe svc -n ingress-basic ingress-nginx-controller
Name:                     ingress-nginx-controller
Namespace:                ingress-basic
Annotations:              meta.helm.sh/release-name: ingress-nginx
                          meta.helm.sh/release-namespace: ingress-basic
                          service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
```
                          
- https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#custom-load-balancer-health-probe
- https://github.com/Azure/AKS/issues/2903#issuecomment-1109731444
- https://github.com/Azure/AKS/issues/2907#issuecomment-1109759262
- https://github.com/Azure/AKS/releases/tag/2022-09-11: For Kubernetes 1.24+ the services of type LoadBalancer...
- https://learn.microsoft.com/en-us/answers/questions/1008699/aks-1-24-ingress-not-exposed

```
# kubectl get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       9s

# kubectl get deploy -l app=ingress-azure
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
ingress-azure-1691807058   1/1     1            1           35m

# kubectl get rs -l app=ingress-azure
NAME                                  DESIRED   CURRENT   READY   AGE
ingress-azure-1691807058-7d8546d8d5   1         1         1       35m

# kubectl describe po -l app=ingress-azure
Name:             ingress-azure-1691811650-d6b56f45d-9hzfq
Namespace:        default
Priority:         0
Service Account:  ingress-azure-1691811650
  Normal   Pulling    5s (x2 over 7s)  kubelet            Pulling image "mcr.microsoft.com/azure-application-gateway/kubernetes-ingress:1.7.2"
                             
# kubectl logs -l app=ingress-azure
I0812 03:46:14.188099       1 reflector.go:255] Listing and watching *v1.Ingress from pkg/mod/k8s.io/client-go@v0.20.0-beta.1/tools/cache/reflector.go:167
I0812 03:46:14.287410       1 context.go:251] Initial cache sync done
I0812 03:46:14.287473       1 context.go:252] k8s context run finished
I0812 03:46:14.287616       1 worker.go:39] Worker started
I0812 03:46:14.422870       1 mutate_app_gateway.go:166] BEGIN AppGateway deployment
I0812 03:46:14.998401       1 client.go:220] OperationID='4c0651d6-2fcb-4512-8d6b-80ff7126525e'
I0812 03:46:21.140572       1 mutate_app_gateway.go:174] Applied generated Application Gateway configuration
I0812 03:46:21.140602       1 mutate_app_gateway.go:189] cache: Updated with latest applied config.
I0812 03:46:21.141472       1 mutate_app_gateway.go:193] END AppGateway deployment
I0812 03:46:21.141503       1 controller.go:152] Completed last event loop run in: 6.853785849s
```

- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-expose-service-over-http-https
- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new
- https://azure.github.io/application-gateway-kubernetes-ingress/troubleshootings/
- https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/: AKS Application Gateway Ingress Controller is an ingress controller that configures the Azure Application Gateway.

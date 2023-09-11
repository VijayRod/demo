Applications can utilize either the DeploymentInformer or the SharedInformer. The SharedInformer is typically the preferred choice. However, application developers should assess which option aligns best with their specific requirements.

- https://pkg.go.dev/k8s.io/client-go/informers/apps/v1#DeploymentInformer
- https://github.com/kubernetes/client-go/blob/master/tools/cache/shared_informer.go: SharedInformer
- https://github.com/kubernetes/community/blob/master/sig-scalability/configs-and-limits/faq.md

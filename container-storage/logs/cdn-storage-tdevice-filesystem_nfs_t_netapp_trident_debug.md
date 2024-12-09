```
kubectl get torc trident -oyaml
spec:
... # No "debug" key after installation in the spec section
status:
  currentInstallationParams:
    debug: "false"

kubectl patch torc trident --type=merge -p '{"spec":{"debug":true}}' # Enable debug. Optionally specify namespace with -n

kubectl get torc trident -oyaml
spec:
  debug: true
status:
  currentInstallationParams:
    debug: "false"
```

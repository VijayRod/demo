```
# kubectl describe pvc
status:
  conditions:
  - lastProbeTime: null
    message: Waiting for user to (re-)start a pod to finish file system resize of
      volume on node.
    type: FileSystemResizePending
```
    
- https://stackoverflow.com/questions/57904305/why-the-kubernetes-pvc-resize-cant-work-with-filesystem

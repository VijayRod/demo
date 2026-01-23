Quick reference guide for allowed read-only kubectl commands, whitelisted flags, usage examples, and security restrictions (secrets blocked, control plane protection).

```
       public static readonly string HelpCommandOutput = @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    KUBECTL RAW COMMAND - HELP                                ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ This accepts kubectl commands (read-only) entered by the user.               ║
║ Commands can optionally start with 'kubectl' or 'k' prefix.                  ║
║                                                                              ║
║ Allowed commands (only WHITELISTED flags permitted):                         ║
║                                                                              ║
║  • get        - Retrieve resources. 'get pods -A' allowed (table format).   ║
║                 -owide/json/yaml NOT allowed with -A for namespaced resources║
║                 Allowed filters: -l (label selector), --field-selector       ║
║                                                                              ║
║  • describe   - Show resource details. Requires -n for namespaced resources.║
║                                                                              ║
║  • logs       - View container logs. Limited to --tail=5000 max.            ║
║                 Automatically adds: '-l kubernetes.azure.com/managedby=aks  ║
║                 --tail=5000' if not specified.                               ║
║                                                                              ║
║  • top        - Display resource usage (CPU/memory).                       ║
║                 ✓ top nodes, top pods, top pods -n ns  ✗ top pods -A       ║
║                                                                              ║
║  • cluster-info - Show cluster endpoint info. 'dump' is blocked.            ║
║                                                                              ║
║  • api-resources - List available resource types.                           ║
║                                                                              ║
║  • api-versions  - List available API versions.                             ║
║                                                                              ║
║  • explain       - Show resource documentation.                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Output formats (-o): json, yaml, wide, name, jsonpath, custom-columns       ║
║ json/yaml/jsonpath/custom-columns NOT allowed with -A for namespace-scoped  ║
║ types. Cluster-scoped resources (nodes, namespaces) allow -A -ojson.        ║
║ File-based formats (go-template-file, jsonpath-file, etc.) NOT allowed.     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ ⚠️  CONTROL PLANE PROTECTION:                              ║
║  • wide/json/yaml/jsonpath NOT allowed with -A for namespace-scoped types  ║
║  • 'top pods -A' is blocked - use 'top pods -n <namespace>' instead        ║
║  • Events: auto-sorted by lastTimestamp (--sort-by added automatically)     ║
║  • Use -l <selector> or --field-selector to filter results                  ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Examples:                                                                    ║
║  • get pods -n kube-system                                                   ║
║  • get pods -A                           (table format across namespaces)   ║
║  • get pods -n kube-system -owide        (wide output for one namespace)    ║
║  • get pods -l app=myapp -n default                                         ║
║  • get pods --field-selector spec.nodeName=aks-nodepool1-12345678-vmss00000 ║
║  • describe node <node-name>                                                ║
║  • describe pod <pod-name> -n <namespace>                                   ║
║  • logs -l app=myapp -n <namespace>                                         ║
║  • top nodes                                                                 ║
║  • top pods                              (uses default namespace)           ║
║  • top pods -n kube-system                                                  ║
║  • api-resources --verbs=get                                                ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Restrictions:                                                                ║
║  • SECRETS: get/describe secrets is NOT allowed                             ║
║  • --all-namespaces blocked for: endpoints, events, ingress, jobs,          ║
║    cronjobs, networkpolicy, pvc, services (namespace-scoped heavy resources)║
║  • Shell operators not allowed (; && || | ` $ > < # \\ etc)                  ║
║  • Only WHITELISTED flags are allowed per command                           ║
║  • Maximum command length: 500 characters                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
";
```

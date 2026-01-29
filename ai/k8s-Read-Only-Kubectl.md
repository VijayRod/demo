Read‑only kubectl with whitelisted commands and flags; limited output formats; up to 5 pipes (grep/awk/head/tail/sort/uniq/cut). Secrets, watch, and file access blocked.

```
        public static readonly string HelpCommandOutput = @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    KUBECTL RAW COMMAND - HELP                                ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ This accepts kubectl commands (read-only) entered by the user.               ║
║ Commands can optionally start with 'kubectl' or 'k' prefix.                  ║
║                                                                              ║
║ Allowed commands (only WHITELISTED flags permitted):                         ║
║  • get        - Retrieve resources. Consider using -l (label) selector or    ║
║                 --field-selector. -A with -owide/json/yaml NOT allowed for   ║
║  • describe   - Show resource details. Requires -n for namespaced resources  ║
║  • logs*      - View container logs of AKS-managed pods                      ║
║  • top*       - Display resource usage. ✗ top pods -A  ✓ top pods -n ns     ║
║  • cluster-info - Show cluster endpoint info. 'dump' command blocked         ║
║  • api-resources - List available resource types                             ║
║  • api-versions  - List available API versions                               ║
║  • explain       - Show resource documentation                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Output Formats (-o flag):                                                    ║
║  Allowed: json, yaml, wide, name, jsonpath, custom-columns                   ║
║  ⚠️  RESTRICTION: json/yaml/jsonpath/custom-columns NOT allowed with -A for  ║
║      namespace-scoped resources. Use -n <namespace> instead.                 ║
║  Cluster-scoped (nodes, namespaces) allow -A -ojson/yaml                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔧 PIPE COMMANDS (filter kubectl output):                                    ║
║  NOTE: All piped commands (grep, awk, head, tail, wc, sort, uniq, cut) are   ║
║        fully implemented in C# with their whitelisted flags.                 ║
║  You can pipe kubectl output to these commands (max 5 pipes):                ║
║                                                                              ║
║  grep*    - Filter lines matching pattern                                    ║
║    Flags: -i (ignore case), -v (invert), -w (word), -x (line),              ║
║           -F (fixed string), -c (count), -n (line numbers), -o (only match), ║
║           -m N (max matches), -e PATTERN (multi-pattern),                    ║
║           -A/-B/-C N (context lines, max 20)                                 ║
║    Example: get pods | grep -i error | grep -v completed                     ║
║                                                                              ║
║  awk*     - Extract columns                                                  ║
║    Format: awk '{print $1, $3}' or awk -F: '{print $1}'                      ║
║    Supports: column extraction ($1, $2, $NF), -F delimiter, NR>N skip lines  ║
║    Example: get pods | awk '{print $1, $3}' | grep -v NAME                   ║
║                                                                              ║
║  head     - Show first N lines (max 1000)                                    ║
║    Flags: -n N or -N                                                         ║
║    Example: get events | head -50                                            ║
║                                                                              ║
║  tail     - Show last N lines (max 1000)                                     ║
║    Flags: -n N or -N                                                         ║
║    Example: logs mypod -n ns | tail -100                                     ║
║                                                                              ║
║  wc       - Count lines (-l), words (-w), or chars/bytes (-c)                ║
║    Example: get pods | grep Running | wc -l                                  ║
║                                                                              ║
║  sort     - Sort lines                                                       ║
║    Flags: -n (numeric), -r (reverse), -u (unique), -k N (key column)         ║
║    Example: get pods | awk '{print $3}' | sort | uniq -c                     ║
║                                                                              ║
║  uniq     - Remove consecutive duplicates                                    ║
║    Flags: -c (count), -d (only duplicates), -u (only unique)                 ║
║    Example: get pods -A | awk '{print $1}' | sort | uniq                     ║
║                                                                              ║
║  cut      - Extract fields                                                   ║
║    Flags: -d DELIM (delimiter), -f FIELDS (field numbers)                    ║
║    Example: get pods | cut -d' ' -f1                                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Examples:                                                                    ║
║  • get pods -n kube-system                                                   ║
║  • get pods -n kube-system -o wide                                           ║
║  • get pods -A                           (table format across namespaces)   ║
║  • get pods -l app=myapp -n default      (with label selector)               ║
║  • get pods --field-selector=status.phase=Running -n kube-system             ║
║  • get pods -o jsonpath='{.items[*].metadata.name}' -n kube-system           ║
║  • describe pod <pod-name> -n <namespace>                                    ║
║  • top nodes                                                                  ║
║  • top pods -n kube-system --sort-by=cpu                                     ║
║  • logs -l app=nginx | tail -100 | grep error                                ║
║  • get pods -A | grep -i pending                                             ║
║  • get pods | awk '{print $1,$3}' | head -20                                 ║
║  • get events | grep Warning | head -50                                      ║
║  • get pods -A | awk '{print $1}' | sort | uniq -c | sort -rn | head -10     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Restrictions (* see details):                                                ║
║  • SECRETS: get/describe secrets is NOT allowed                              ║
║  • Shell operators (;&&||`$><#\\) not allowed                                ║
║  • Pipe | to grep, awk, head, tail, wc, sort, uniq, cut IS allowed (max 5 pipes) ║
║  • File input (-f/--filename) not allowed                                    ║
║  • Watch mode (-w/--watch) not allowed                                       ║
║  • --all-namespaces: Blocked for endpoints, events, ingress, jobs, cronjobs, ║
║                      networkpolicy, pvc, services (namespace-scoped types)   ║
║  • LOGS*: -l kubernetes.azure.com/managedby=aks applied when not specified;  ║
║           --tail=10000 auto-applied when no tail flag present                ║
║  • TOP*: 'top pods -A' not allowed (metrics-server protection)               ║
║  • GREP: max 2 greps, pattern ≤200 chars, -A/-B/-C ≤20 lines                 ║
║  • AWK: safe subset only (column extraction, no BEGIN/END/conditions)        ║
║  • Maximum command length: 500 characters                                    ║
║  • Only WHITELISTED flags are allowed per command                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
"; 
```

## k8s-node-conditions_NodeProblemDetector

```
# See the section on k8s-node-cordon.drain.app.draino
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector
- https://github.com/kubernetes/node-problem-detector: enabled by default in AKS as part of the AKS Linux Extension. node-problem-detector uses Event and NodeCondition to report problems to apiserver
  - https://docs.google.com/document/d/1cs1kqLziG-Ww145yN6vvlKguPbQQ0psrSBnEqpy0pzE/edit?tab=t.0#heading=h.ky5thzvo7t76: Motivation
  - https://github.com/kubernetes/node-problem-detector?#remedy-systems
    
## k8s-node-conditions_NodeProblemDetector.conditions

```
kubectl describe no # Conditions
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#node-conditions
- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#check-the-node-conditions-and-events
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#node-conditions
- https://kubernetes.io/docs/reference/node/node-status/#condition
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-nodes-by-condition

## k8s-node-conditions_NodeProblemDetector.debug

```
# npd.init
aks-nodepool1-14317786-vmss000000:/# cat /var/log/syslog | grep node-prob
Mar  7 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.150241    8082 custom_plugin_monitor.go:80] Finish parsing custom plugin monitor config file /etc/node-problem-detector.d/custom-plugin-monitor/custom-scheduledevents-consolidated-condition-monitor.json: {Plugin:custom PluginGlobalConfig:{InvokeIntervalString:0xc00057df50 TimeoutString:0xc00057df60 InvokeInterval:2s Timeout:25s MaxOutputLength:0xc000117c00 Concurrency:0xc000117c08 EnableMessageChangeBasedConditionUpdate:0xc000117c10 SkipInitialStatus:0x2fe67f2} Source:custom-scheduledevents-consolidated-condition-plugin-monitor DefaultConditions:[{Type:VMEventScheduled Status: Transition:0001-01-01 00:00:00 +0000 UTC Reason:NoVMEventScheduled Message:VM has no scheduled event}] Rules:[0xc0005ff960] EnableMetricsReporting:0xc000117c11}
...
Mar  7 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.209517    8082 custom_plugin_monitor.go:303] Initialize condition generated: []
Mar  7 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.210080    8082 custom_plugin_monitor.go:303] Initialize condition generated: [{Type:KubeletProblem Status:False Transition:2025-03-07 18:50:52.210065404 +0000 UTC m=+0.093155949 Reason:KubeletIsUp Message:kubelet service is up}]
...
Mar  7 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.257659    8082 problem_detector.go:77] Problem detector started
Mar  7 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.258163    8082 custom_plugin_monitor.go:303] Initialize condition generated: []
```

```
# npd.init.configuration

grep -r "reason" /etc/node-problem-detector.d/
/etc/node-problem-detector.d/system-log-monitor/kernel-monitor.json:                    "reason": "FilesystemIsReadOnly",
/etc/node-problem-detector.d/custom-plugin-monitor/custom-node-not-ready-monitor.json:      "reason": "NodeNotReadyDetected",
..

grep -r "not_ready" /etc/node-problem-detector.d/
grep -r "npd:check" /etc/node-problem-detector.d/

ls /var/log/azure/Microsoft.AKS.Compute.AKS.Linux.AKSNode
cat extension.log | tail
2025/04/29 18:11:21 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] JSON config: {"runtimeSettings": [{"handlerSettings": {"publicSettings": {"disable-uu": "true", "enable-uu": "false", "node-exporter-tls": "false"}, "protectedSettings": null, "protectedSettingsCertThumbprint": null}}]}
2025/04/29 18:11:22 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-problem-detector verified to be installed
2025/04/29 18:11:22 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] Systemctl daemon-reload was successful
2025/04/29 18:11:22 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-problem-detector was successfully enabled
2025/04/29 18:11:22 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-problem-detector start was successful
2025/04/29 18:11:23 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-exporter verified to be installed
2025/04/29 18:11:23 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] Systemctl daemon-reload was successful
2025/04/29 18:11:24 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-exporter was successfully enabled
2025/04/29 18:11:24 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] node-exporter start was successful
2025/04/29 18:11:24 [Microsoft.AKS.Compute.AKS.Linux.AKSNode-1.0.0.0] Enable,success,0,Successfully enabled Compute.
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/monitor-node-health/#overwrite-the-configuration: you can use a ConfigMap to overwrite the configuration

```
# npd.init.node-problem-detector.service

ps -aux | grep node-prob # when the monitors are up and running
root        8044  0.0  0.0   2892  1780 ?        Ss   18:50   0:00 /bin/sh /usr/local/bin/node-problem-detector-startup.sh
root        8082  0.2  0.9 1975708 77396 ?       Sl   18:50   0:26 /usr/local/bin/node-problem-detector --config.system-log-monitor=/etc/node-problem-detector.d/system-log-monitor/node-problem-detector-conf.json,/etc/node-problem-detector.d/system-log-monitor/kernel-monitor.json,/etc/node-problem-detector.d/system-log-monitor/systemd-monitor.json --config.custom-plugin-monitor=/etc/node-problem-detector.d/custom-plugin-monitor/custom-scheduledevents-consolidated-condition-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/dns-problem-monitor.json,/etc/node-prolem-detector.d/custom-plugin-monitor/irqbalance-problem-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-scheduledevents-consolidated-plugin-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-fs-corruption-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/systemd-monitor-counter.json,/etc/node-problem-detector.d/custom-plugin-monitor/network-problem-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/uu-problem-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-kubelet-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/kernel-monitor-counter.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-scheduledevents-consolidated-preempt-plugin-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-egress-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-runtime-monitor.json,/etc/node-problem-detector.d/custom-plugin-monitor/custom-kubelet-serving-monitor.json --config.system-stats-monitor=/etc/node-problem-detector.d/system-stats-monitor/system-stats-monitor.json --prometheus-address 0.0.0.0 --apiserver-override https://aks-rgml-efec8e-11111111.hcp.eastus2.azmk8s.io:443?inClusterConfig=false&auth=/var/lib/kubelet/kubeconfig --hostname-override aks-nodepool1-14317786-vmss000000 --logtostderr
root      228734  0.0  0.0   7764  3604 ?        S    20:12   0:00 /bin/bash /etc/node-problem-detector.d/plugin/check_scheduledevent_consolidated.sh
root      228736  0.0  0.0   7764  3484 ?        S    20:12   0:00 /bin/bash /etc/node-problem-detector.d/plugin/check_preempt.sh
root      228740  0.0  0.0   7764  3524 ?        R    20:12   0:00 /bin/bash /etc/node-problem-detector.d/plugin/check_scheduledevent.sh -t Preempt -m 24
root      228742  0.0  0.0   7764  1564 ?        S    20:12   0:00 /bin/bash /etc/node-problem-detector.d/plugin/check_scheduledevent.sh -t Preempt -m 24
root      228745  0.0  0.0   7764  1648 ?        S    20:12   0:00 /bin/bash /etc/node-problem-detector.d/plugin/check_scheduledevent_consolidated.sh

ps -aux | grep node-prob # usually
root        8044  0.0  0.0   2892  1780 ?        Ss   18:50   0:00 /bin/sh /usr/local/bin/node-problem-detector-startup.sh
root        8082  0.2  0.9 1975708 80656 ?       Sl   18:50   0:27 /usr/local/bin/

systemctl status node-problem-detector.service
? node-problem-detector.service - Node Problem Detector
     Loaded: loaded (/etc/systemd/system/node-problem-detector.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2025-03-07 18:50:52 UTC; 3h 28min ago
       Docs: https://github.com/kubernetes/node-problem-detector
   Main PID: 8044 (node-problem-de)
      Tasks: 10 (limit: 9516)
     Memory: 40.9M
        CPU: 15min 46.093s
     CGroup: /system.slice/node-problem-detector.service
             +-8044 /bin/sh /usr/local/bin/node-problem-detector-startup.sh
             +-8082 /usr/local/bin/node-problem-detector --config.system-log-monitor=/etc/node-problem-detector.d/s>
Mar 07 18:50:52 aks-nodepool1-14317786-vmss000000 node-problem-detector-startup.sh[8082]: I0307 18:50:52.259312...

systemctl restart node-problem-detector.service

cat /usr/local/bin/node-problem-detector-startup.sh # script file
```

```
# npd.custom-plugin-monitor

ls /etc/node-problem-detector.d/
custom-plugin-monitor  plugin  public-settings.json  system-log-monitor  system-stats-monitor

ls /etc/node-problem-detector.d/custom-plugin-monitor/
custom-egress-monitor.json
custom-fs-corruption-monitor.json
custom-kubelet-monitor.json
custom-kubelet-serving-monitor.json
custom-runtime-monitor.json
custom-scheduledevents-consolidated-condition-monitor.json
custom-scheduledevents-consolidated-plugin-monitor.json
custom-scheduledevents-consolidated-preempt-plugin-monitor.json
dns-problem-monitor.json
irqbalance-problem-monitor.json
kernel-monitor-counter.json
network-problem-monitor.json
systemd-monitor-counter.json
uu-problem-monitor.json

cat /etc/node-problem-detector.d/custom-plugin-monitor/custom-egress-monitor.json
{
  "plugin": "custom",
  "pluginConfig": {
    "invoke_interval": "30m",
    "timeout": "120s",
    "max_output_length": 1000,
    "concurrency": 1,
    "enable_message_change_based_condition_update": false
  },
  "source": "node-egress-monitor",
  "metricsReporting": true,
  "conditions": [],
  "rules": [
    {
      "type": "temporary",
      "reason": "EgressBlocked",
      "path": "/etc/node-problem-detector.d/plugin/check_egress.sh",
      "timeout": "120s"
    }
  ]
}

cat /etc/node-problem-detector.d/plugin/check_egress.sh

grep -r "reason" /etc/node-problem-detector.d/ | grep /custom-plugin
```

```
# npd.system-log-monitor

grep -r "reason" /etc/node-problem-detector.d/ | grep /system-log
```

## k8s-node-conditions_NodeProblemDetector.events

```
kubectl describe no # Events
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#events
- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#check-the-node-conditions-and-events

## k8s-node-conditions_NodeProblemDetector.events.EgressBlocked

```
curl -m 5 -I https://mcr.microsoft.com
curl -m 5 -I https://management.azure.com
curl -m 5 -I https://login.microsoftonline.com
curl -m 5 -I https://packages.microsoft.com
curl -m 5 -I https://acs-mirror.azureedge.net
```

- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules

```
# See the section on IMDS

curl -m 5 -I https://packages.microsoft.com
HTTP/2 200
date: Tue, 04 Feb 2025 18:11:49 GMT
content-type: text/html
content-length: 2711
last-modified: Mon, 03 Feb 2025 01:23:59 GMT
etag: "67a01aaf-a97"
strict-transport-security: max-age=31536000; includeSubDomains
x-content-type-options: nosniff
x-azure-ref: 20250204T141149Z-r15774cf85dn94vbhC1LONxrx000000002d00000000017pf
x-cache: TCP_HIT
cache-control: public, max-age=15552000
x-fd-int-roxy-purgeid: 66950501
accept-ranges: bytes
```

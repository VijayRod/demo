```
# vmagent
# \var\log\waagent.log
INFO Daemon Azure Linux Agent Version:2.2.46
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux/linux-azure-guest-agent
- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/agent-linux
- https://github.com/Azure/WALinuxAgent/wiki/FAQ: The daemon is responsible for ensuring the extension handler is always running. If the extension handler process dies, the daemon will automatically restart it.

```
# vmagent.ExtensionHandler aka ExtHandler
# \var\log\waagent.log
INFO ExtHandler Agent WALinuxAgent-2.2.46 is running as the goal state agent
INFO ExtHandler Fetching full goal state from the WireServer [incarnation 1]
INFO ExtHandler ExtHandler Downloading artifacts profile blob
WARNING ExtHandler ExtHandler Fetch failed: [HttpError] [HTTP Failed] GET https://md-<storage>.z41.blob.storage.azure.net/$system/<vmname>.<guid>.vmSettings -- IOError timed out -- 6 attempts made
```

- https://github.com/Azure/WALinuxAgent/wiki/FAQ: The extension handler is responsible for managing extensions and reporting VM status. Extension Handler is auto-upgraded by default as new releases roll out...
- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux/linux-vm-extension-status-not-reported
- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/features-linux?tabs=azure-cli#network-access

```
# vmagent.ExtensionHandler.linux
```
- https://github.com/Azure/azure-linux-extensions

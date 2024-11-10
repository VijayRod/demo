```
wget https://github.com/NetApp/trident/releases/download/v23.07.1/trident-installer-23.07.1.tar.gz
tar -xf trident-installer-23.07.1.tar.gz
cd trident-installer
```

```
cd /tmp/trident-installer
./tridentctl help
./tridentctl uninstall -n trident 
./tridentctl install -n trident -d # debug
```

- https://docs.netapp.com/us-en/trident/trident-get-started/kubernetes-deploy-tridentctl.html#install-astra-trident-using-tridentctl: Step 1: Download the Trident installer package
- https://docs.netapp.com/us-en/trident/trident-get-started/kubernetes-deploy.html#choose-your-installation-mode: Using tridentctl
- https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-nfs#install-astra-trident-using-helm: Trident can be installed using the Trident operator (manually or using Helm) or tridentctl.
- https://netapp-trident.readthedocs.io/en/stable-v21.07/reference/tridentctl.html

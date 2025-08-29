```
# type C:\AzureData\CustomDataSetupScript.log | findstr "CSEScriptsPackage"
2023-08-10T16:49:46.2875730+00:00: CSEScriptsPackageUrl is https://acs-mirror.azureedge.net/aks/windows/cse/
2023-08-10T16:49:46.2875730+00:00: WindowsCSEScriptsPackage is aks-windows-cse-scripts-v0.0.25.zip
```

- https://github.com/Azure/AgentBaker/tree/master/staging/cse/windows: This repository contains a list of fixes for various versions of CSE (aks-windows-cse-scripts) in AKS Windows.
- https://github.com/Azure/AgentBaker/tree/master/vhdbuilder/release-notes/AKSWindows
- https://github.com/Azure/AgentBaker/blob/official/v20230727/parts/windows/kuberneteswindowssetup.ps1#L220: This is where the WindowsCSEScriptsPackage is located.
  - For existing Windows node pools, a simple reimage won't suffice to update the WindowsCSEScriptsPackage value. Instead, you must either create a new agent pool or update the node image of the existing agent pools. Alternatively, you can confirm its functionality by creating a new cluster.
  - https://github.com/Azure/AgentBaker/pulls?q=bump+Windows+CSE
- https://github.com/Azure/AKS/releases: This is an informational message stating "AKS Windows 2022 image has been updated to".

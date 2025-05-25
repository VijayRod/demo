> ## cve

- https://www.cve.org/CVERecord?id=CVE-2023-24540
- https://nvd.nist.gov/vuln/detail/CVE-2023-24540
- https://avd.aquasec.com/nvd/2024/cve-2024-5535/
- https://www.cve.org/ResourcesSupport/FAQs: The U.S. National Vulnerability Database (NVD) provides fix and other information for records on the CVE List.
- https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-24540
- https://ubuntu.com/security/CVE-2024-37891#status # Includes information on Ubuntu versions that have been patched for this issue, for example, 22.04 LTS

> ## cve.aks

```
# cve.aks
Do you have a list of the managed container images and their associated (fixed) critical CVEs?
Most of these issues are really old and should have been fixed already. It’s clear something’s off with the tool. We need to figure out how to get an accurate scan to eliminate any false positives. If 95% of this list are false positives, we can just focus on the ones that haven't been fixed.
Can they use Trivy to check image vulnerabilities? I think there will be fewer false positives.
What are the CRITICAL & HIGH CVEs with these images?
Could you have the report include the following details: - CVE   |   container/image name   |   container/image version   |   impact (critical/high/medium/...)
```

- https://github.com/Azure/AKS/issues?q=is%3Aissue%20cve%20
- https://github.com/Azure/AKS/issues?q=is%3Aissue+is%3Aopen+cve
- https://learn.microsoft.com/en-us/azure/aks/concepts-vulnerability-management#how-vulnerabilities-are-updated
- https://github.com/Azure/AKS/releases
- https://releases.aks.azure.com/: AKS Security Patch
- https://github.com/Azure/AgentBaker/tree/master/vhdbuilder/release-notes/security-patch
- https://learn.microsoft.com/en-us/azure/architecture/guide/devsecops/devsecops-on-aks#best-practice--secure-your-container-images: Trivy is an example of an open-source tool that you can use to analyze security vulnerabilities within your container images.

```
# cve.aks.node.container.image

## list cached images
crictl image | grep nvidia
mcr.microsoft.com/oss/nvidia/k8s-device-plugin                                        v0.14.5                    60ecb60a72516       108MB
```
- https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2204containerd/latest-image-list.json
- https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2204containerd/latest.txt

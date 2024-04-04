![The benefits of AKS for GPU tasks](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/555626iD7CB610B35852CDB/image-size/medium?v=v2&px=400)

## The benefits of AKS for GPU tasks

## Table of Contents

- AKS KAITO (AI toolchain operator) add-on
- AI Conversational Diagnostics in the Azure portal
- Multi-instance GPU (MIG) aka GPU partitioning
- Node Auto Provisioning (NAP) aka Karpenter
- More

## AKS KAITO (AI toolchain operator) add-on 
- https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator

## AI Conversational Diagnostics in the Azure portal
- https://techcommunity.microsoft.com/t5/apps-on-azure-blog/announcing-conversational-diagnostics-preview-on-azure/ba-p/4087092

## Multi-instance GPU (MIG) aka GPU partitioning
- https://learn.microsoft.com/en-us/azure/aks/gpu-multi-instance?tabs=azure-cli
- https://www.the-aks-checklist.com/: When required use multi-instance partioning GPU on AKS Clusters

## Node Auto Provisioning (NAP) aka Karpenter
- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#sku-selectors-with-well-known-labels
- https://karpenter.sh/docs/concepts/nodepools/
- https://github.com/aws/karpenter-provider-aws/blob/main/pkg/apis/crds/karpenter.sh_nodepools.yaml
- https://github.com/aws/karpenter-provider-aws/blob/main/test/suites/scale/deprovisioning_test.go, WhenUnderutilized

## NVIDIA device plugin operator
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#options-for-using-nvidia-gpus
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#use-nvidia-gpu-operator-with-aks
- https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file
- https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.5/nvidia-device-plugin.yml
- https://techcommunity.microsoft.com/t5/azure-high-performance-computing/running-gpu-accelerated-workloads-with-nvidia-gpu-operator-on/ba-p/4061318

### Use the AKS GPU image
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#use-the-aks-gpu-image-preview

## GPU-optimized VM/VMSS sizes in Azure
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#supported-gpu-enabled-vms

## Linux and Windows node pools to support GPU workloads
- https://techcommunity.microsoft.com/t5/containers/windows-gpus-for-aks/ba-p/4089292

## Monitor GPUs
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#confirm-that-gpus-are-schedulable

## More
- Azure AI Studio - https://ai.azure.com/ ([link2](https://azure.microsoft.com/en-us/products/ai-studio))
- Azure OpenAI service - https://azure.microsoft.com/en-us/products/ai-services/openai-service
- AKS and Azure Machine Learning - https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#next-steps
- New tools in Azure AI - https://azure.microsoft.com/en-us/blog/announcing-new-tools-in-azure-ai-to-help-you-build-more-secure-and-trustworthy-generative-ai-applications/
- Empowering cloud-native development and AI innovation - https://cloudblogs.microsoft.com/opensource/2024/03/18/see-how-azure-is-empowering-cloud-native-development-and-ai-innovation-with-kubernetes-at-kubecon-europe-2024/

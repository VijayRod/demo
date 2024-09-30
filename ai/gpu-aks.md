![The benefits of AKS for GPU tasks](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/555626iD7CB610B35852CDB/image-size/medium?v=v2&px=400)

## The benefits of AKS for GPU tasks

## Table of Contents

- KAITO (AI toolchain operator) add-on
- Reduce large image pull time with Artifact Streaming
- Node Auto Provisioning (NAP) aka Karpenter
- Multi-instance GPU (MIG) aka GPU partitioning
- Dynamic Resource Allocation
- AI Conversational Diagnostics in the Azure portal
- More

## KAITO (AI toolchain operator) add-on 
With the KAITO add-on for AKS, you can run cool machine learning stuff like big language models on AKS without spending too much or messing with lots of settings. The add-on uses the free and open-source KAITO project.
- https://azure.microsoft.com/en-us/updates/public-preview-kubernetes-ai-toolchain-operator-kaito-addon-for-aks/
- https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator
- https://github.com/Azure/kaito

## Reduce large image pull time with Artifact Streaming
When you run high performance compute workloads, you need to pull big images, and that can take a lot of time and slow down your deployments. With Artifact Streaming on AKS, you can stream container images from ACR to AKS. AKS only pulls what it needs to start the pod, so you can pull images and deploy your workloads faster. Artifact Streaming can make your pods ready over 15% faster, depending on the image size, and it works great for images <30GB.
- https://learn.microsoft.com/en-us/azure/aks/artifact-streaming
- https://github.com/Azure/AKS/issues/3928
- https://github.com/containerd/overlaybd

## Node Auto Provisioning (NAP) aka Karpenter
When you run workloads on AKS, you have to pick the right VM size for your node pool. But that can be hard when your workloads needs different CPU, memory, and other things. You don't want to waste time or money on the wrong VMs. That's where node autoprovisioning (NAP) comes in. It looks at what your pods need and finds the best VMs to run them. It's smart and efficient. NAP uses Karpenter, which is Open Source, and so is the AKS provider. NAP sets up and manages Karpenter for you on your AKS clusters.
- https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#sku-selectors-with-well-known-labels
- https://karpenter.sh/docs/concepts/nodepools/
- https://github.com/aws/karpenter-provider-aws/blob/main/pkg/apis/crds/karpenter.sh_nodepools.yaml
- https://github.com/aws/karpenter-provider-aws/blob/main/test/suites/scale/deprovisioning_test.go, WhenUnderutilized
  
## Multi-instance GPU (MIG) aka GPU partitioning
With the A100 GPU from Nvidia, you can split it into seven separate parts. Each part has its own SM and memory. You can use GPU instance profiles to choose how to divide the GPUs.
- https://learn.microsoft.com/en-us/azure/aks/gpu-multi-instance?tabs=azure-cli
- https://www.the-aks-checklist.com/: When required use multi-instance partioning GPU on AKS Clusters

## Dynamic Resource Allocation
With MIG, you have to choose some GPU devices that are pre-partitioned, but DRA lets you partition on the fly.
- https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/
- https://kubernetes.io/blog/2022/12/15/dynamic-resource-allocation/
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-node/3063-dynamic-resource-allocation/README.md

## AI Conversational Diagnostics in the Azure portal
Want to chat with OpenAI and fix your AKS clusters? Try Conversational Diagnostics. It's a cool feature that lets you have a friendly chat and get the right solutions, docs, and diagnostics for your cluster problems.
- https://techcommunity.microsoft.com/t5/apps-on-azure-blog/announcing-conversational-diagnostics-preview-on-azure/ba-p/4087092

## Copilot in the Azure portal
With Azure, you can do amazing things. And [Microsoft Copilot for Azure](https://learn.microsoft.com/en-us/azure/copilot/overview) is here to help. It's an AI tool that guides you through Azure
    
## NVIDIA device plugin operator
With the NVIDIA GPU Operator, you don't have to worry about installing and updating all the NVIDIA stuff you need for GPU provisioning, like drivers, NVIDIA device plugin for Kubernetes, and container runtime. The GPU Operator takes care of it for you, so you can skip the manual installation of the device plugin.
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#options-for-using-nvidia-gpus
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#use-nvidia-gpu-operator-with-aks
- https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file
- https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.5/nvidia-device-plugin.yml
- https://techcommunity.microsoft.com/t5/azure-high-performance-computing/running-gpu-accelerated-workloads-with-nvidia-gpu-operator-on/ba-p/4061318

### Use the AKS GPU image
With AKS, you get an AKS image that already has the NVIDIA device plugin for Kubernetes installed. You can only use the AKS GPU image with Ubuntu 18.04.
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#use-the-aks-gpu-image-preview
- https://github.com/Azure/AKS/releases/tag/2024-09-18: AKS will no longer support the GPU image (preview). recommended by AKS include the default experience with manual NVIDIA device plugin installation or the NVIDIA GPU Operator

## GPU-optimized VM/VMSS sizes in Azure
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#supported-gpu-enabled-vms

## Linux and Windows node pools to support GPU workloads
- https://techcommunity.microsoft.com/t5/containers/windows-gpus-for-aks/ba-p/4089292

## Monitor GPUs
Kubernetes upstream stopped using kubelet to get GPU metrics and switched to vendor GPU drivers instead. Container insights can work with GPU drivers like NVIDIA.
- https://kubernetes.io/blog/2020/12/16/third-party-device-metrics-reaches-ga/#nvidia-gpu-metrics-deprecated: The DisableAcceleratorMetrics feature (introduced in 1.19) is graduating to beta and will be enabled by default (With Kubernetes 1.20)
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-gpu-monitoring: Kubernetes is deprecating GPU metrics that are being reported by the kubelet, for Kubernetes version 1.20+. Container insights supports monitoring GPU clusters from the following GPU vendors.
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster#use-container-insights-to-monitor-gpu-usage
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#confirm-that-gpus-are-schedulable

## More
- How to schedule GPUs with Kubernetes - https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/
- Azure AI Studio - https://ai.azure.com/ ([link2](https://azure.microsoft.com/en-us/products/ai-studio))
- Azure OpenAI service - https://azure.microsoft.com/en-us/products/ai-services/openai-service
- AKS and Azure Machine Learning - https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#next-steps
- New tools in Azure AI - https://azure.microsoft.com/en-us/blog/announcing-new-tools-in-azure-ai-to-help-you-build-more-secure-and-trustworthy-generative-ai-applications/
- Empowering cloud-native development and AI innovation - https://cloudblogs.microsoft.com/opensource/2024/03/18/see-how-azure-is-empowering-cloud-native-development-and-ai-innovation-with-kubernetes-at-kubecon-europe-2024/
- How K8s and ML got better over time - https://github.com/ronaldpetty/timeline/blob/main/k8s_ml_history.md

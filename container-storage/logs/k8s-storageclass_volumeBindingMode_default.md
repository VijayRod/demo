```
# kubectl describe sc | grep -e Provisioner -e VolumeBind
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
```

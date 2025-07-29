#!/bin/bash
set -Eeuo pipefail

SSD_PCI_ID="REPLACE-WITH-SSD-PCI-ID"

# Unmount partitions if mounted
for part in /dev/nvme2n1p{1,2,3,4}; do
    umount "$part" 2>/dev/null || true
done

# Mark SSD to use vfio-pci
echo vfio-pci > "/sys/bus/pci/devices/$SSD_PCI_ID/driver_override"

# Unbind from its current driver (nvme)
if [ -e "/sys/bus/pci/devices/$SSD_PCI_ID/driver/unbind" ]; then
    echo "$SSD_PCI_ID" > "/sys/bus/pci/devices/$SSD_PCI_ID/driver/unbind"
fi

# Reprobe so kernel binds it to vfio-pci using the override
echo "$SSD_PCI_ID" > /sys/bus/pci/drivers_probe


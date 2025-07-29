#!/bin/bash

SSD_PCI_ID="REPLACE-WITH-SSD-PCI-ID"
SSD_ORIG_DRIVER="nvme"

# Unbind SSD from vfio-pci
if [ -e /sys/bus/pci/devices/$SSD_PCI_ID/driver/unbind ]; then
    echo "$SSD_PCI_ID" > /sys/bus/pci/devices/$SSD_PCI_ID/driver/unbind
fi
# Rebind SSD to original driver
if [ -e /sys/bus/pci/drivers/$SSD_ORIG_DRIVER/bind ]; then
    echo "$SSD_PCI_ID" > /sys/bus/pci/drivers/$SSD_ORIG_DRIVER/bind
fi
# Clean up vfio-pci ID registration (optional)
if [ -e /sys/bus/pci/drivers/vfio-pci/remove_id ]; then
    echo "c0a9 540a" > /sys/bus/pci/drivers/vfio-pci/remove_id
fi

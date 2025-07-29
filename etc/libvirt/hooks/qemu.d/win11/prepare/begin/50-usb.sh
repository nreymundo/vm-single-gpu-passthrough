#!/bin/bash
set -Eeuo pipefail

# Not really necessary if you're already loading it on startup but just in case.
modprobe vfio-pci || true

(REPLACE-WITH-USB-CONTROLLER-PCI-IDS)

for d in "${USB[@]}"; do
  # mark device to use vfio-pci
  echo vfio-pci > "/sys/bus/pci/devices/$d/driver_override"
  # unbind from current driver (xhci_hcd) if any
  if [ -e "/sys/bus/pci/devices/$d/driver/unbind" ]; then
    echo "$d" > "/sys/bus/pci/devices/$d/driver/unbind"
  fi
  # reprobe so kernel binds to vfio-pci using the override
  echo "$d" > /sys/bus/pci/drivers_probe
done

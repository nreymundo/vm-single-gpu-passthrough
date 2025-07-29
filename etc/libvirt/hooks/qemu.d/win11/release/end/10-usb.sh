#!/bin/bash
set -Eeuo pipefail

# Not really necessary if you're already loading it on startup but just in case.
(REPLACE-WITH-USB-CONTROLLER-PCI-IDS)

for d in "${USB[@]}"; do
  # If currently bound to vfio-pci, unbind it
  cur=$(basename "$(readlink -f "/sys/bus/pci/devices/$d/driver" 2>/dev/null || echo '')")
  if [ "$cur" = "vfio-pci" ]; then
    echo "$d" > /sys/bus/pci/drivers/vfio-pci/unbind
  fi

  # bind back to xhci_hcd via override + reprobe
  echo xhci_hcd > "/sys/bus/pci/devices/$d/driver_override"
  echo "$d" > /sys/bus/pci/drivers_probe

  # clear override so normal behavior resumes
  echo "" > "/sys/bus/pci/devices/$d/driver_override"
done

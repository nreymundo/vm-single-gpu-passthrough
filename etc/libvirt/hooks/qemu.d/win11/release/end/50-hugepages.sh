#!/bin/bash

# Target domain name (optional, if you want to match)
VM_NAME="$1"
ACTION="$2"

# Safety check
if [[ "$VM_NAME" != "win11" ]]; then
  echo "[INFO] Skipping hugepage cleanup for unrelated VM: $VM_NAME"
  exit 0
fi

# Free hugepages
echo 0 | sudo tee /proc/sys/vm/nr_hugepages > /dev/null
echo "[INFO] Hugepages released."

# Optional: Drop page cache (be cautious on production machines)
# echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
# echo "[INFO] Dropped filesystem caches."


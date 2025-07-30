#!/bin/bash

# Free hugepages
echo 0 | sudo tee /proc/sys/vm/nr_hugepages > /dev/null
echo "[INFO] Hugepages released."

# Optional: Drop page cache (be cautious on production machines)
# echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
# echo "[INFO] Dropped filesystem caches."


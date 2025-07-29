#!/bin/bash

# Isolate CPU cores from the host
# Host restricted to cores 0-15 except those used by VM
sudo systemctl set-property --runtime -- user.slice AllowedCPUs=0,2,4,6,8,10,12,14
sudo systemctl set-property --runtime -- system.slice AllowedCPUs=0,2,4,6,8,10,12,14
sudo systemctl set-property --runtime -- init.scope AllowedCPUs=0,2,4,6,8,10,12,14

# Set CPU governor to performance for all cores
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo performance | sudo tee "$CPUFREQ" > /dev/null
done

# Optional: Switch power profile (if using power-profiles-daemon)
if command -v powerprofilesctl &> /dev/null; then
  powerprofilesctl set performance
fi

echo "[INFO] CPU governor set to performance."


#!/bin/bash

# Release CPU cores back to the host
# Re-enable all 32 logical cores
sudo systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
sudo systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
sudo systemctl set-property --runtime -- init.scope AllowedCPUs=0-31

# Revert CPU governor to powersave
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo powersave | sudo tee "$CPUFREQ" > /dev/null
done

# Optional: Switch power profile back
if command -v powerprofilesctl &> /dev/null; then
  powerprofilesctl set power-saver
fi

echo "[INFO] CPU governor reverted to powersave."


# Single GPU Passthrough for Windows 11 VM

This repository contains a collection of scripts and configuration files to facilitate a single GPU passthrough setup for a Windows 11 virtual machine using Libvirt and QEMU/KVM.

## Features

*   **Automated GPU Passthrough**: Scripts to automatically detach the GPU from the host and attach it to the VM on startup, and vice-versa on shutdown.
*   **CPU Pinning and Governor Tuning**: Isolates VM CPUs from the host and sets the CPU governor to `performance` for the duration of the VM session.
*   **Huge Page Allocation**: Allocates huge pages for the VM for improved performance.
*   **Device Passthrough**: Includes scripts for passing through a dedicated SSD and USB controllers.
*   **Templated Configuration**: All scripts and the libvirt XML are templated and ready to be adapted to your hardware.

## Directory Structure

```
├── etc/
│   ├── libvirt/
│   │   └── hooks/
│   │       ├── qemu
│   │       └── qemu.d/
│   │           └── win11/
│   │               ├── prepare/
│   │               │   └── begin/
│   │               │       ├── 10-hugepages.sh
│   │               │       ├── 20-governor.sh
│   │               │       ├── 30-gpu.sh
│   │               │       ├── 40-ssd.sh
│   │               │       └── 50-usb.sh
│   │               └── release/
│   │                   └── end/
│   │                       ├── 10-usb.sh
│   │                       ├── 20-ssd.sh
│   │                       ├── 30-gpu.sh
│   │                       ├── 40-governor.sh
│   │                       └── 50-hugepages.sh
│   └── modules-load.d/
│       └── vfio.conf
└── virt-manager/
    └── sample.xml
```

*   `etc/libvirt/hooks/qemu`: The main hook script that executes the per-VM hooks.
*   `etc/libvirt/hooks/qemu.d/win11`: Contains the hooks for the `win11` VM.
    *   `prepare/begin`: Scripts that run before the VM starts.
    *   `release/end`: Scripts that run after the VM shuts down.
*   `etc/modules-load.d/vfio.conf`: Kernel modules to be loaded at boot.
*   `virt-manager/sample.xml`: A sample libvirt XML configuration for the VM.

## Prerequisites

*   A Linux distribution with KVM, QEMU, and Libvirt installed.
*   A CPU and motherboard with IOMMU support (Intel VT-d or AMD-Vi).
*   A dedicated GPU for the VM.
*   Sufficient RAM to allocate to the VM.

## Installation

1.  **Enable IOMMU**: Ensure that IOMMU is enabled in your BIOS/UEFI settings.
2.  **Kernel Modules**: Copy the `vfio.conf` file to `/etc/modules-load.d/` to ensure the necessary VFIO modules are loaded at boot.
3.  **Libvirt Hooks**:
    *   Copy the `qemu` hook script to `/etc/libvirt/hooks/`.
    *   Create the directory `/etc/libvirt/hooks/qemu.d/win11` and its subdirectories.
    *   Copy the scripts from `etc/libvirt/hooks/qemu.d/win11` to their corresponding locations.
    *   Make all the scripts executable: `chmod +x /etc/libvirt/hooks/qemu* -R`.
4.  **VM Configuration**:
    *   Copy the `sample.xml` to a location of your choice.
    *   Customize the `sample.xml` file to match your hardware and preferences.
    *   Define the VM in libvirt: `virsh define sample.xml`.

## Configuration

1.  **VM Name**: If you change the VM name from `win11`, you must also rename the directory in `/etc/libvirt/hooks/qemu.d/`.
2.  **PCI Addresses**: Replace the placeholder PCI addresses in the scripts with the actual addresses of your hardware. You can find these using `lspci`.
3.  **CPU Cores**: Adjust the `AllowedCPUs` in `20-governor.sh` and `40-governor.sh` to match your CPU core layout.
4.  **Huge Pages**: Modify the `TARGET_PAGES` in `10-hugepages.sh` to match the amount of RAM you want to allocate to the VM.
5.  **Libvirt XML**:
    *   Replace all instances of `REPLACE-WITH-*` with your own values.
    *   Generate a new UUID using `uuidgen`.
    *   Update the paths to your ISO and NVRAM files.
    *   Configure the CPU pinning to match your desired core allocation.

## Usage

The hooks are executed automatically by libvirt when you start or stop the `win11` VM.

*   **VM Start**: The scripts in `prepare/begin` are executed.
*   **VM Shutdown**: The scripts in `release/end` are executed.

## Disclaimer

This setup is complex and can lead to system instability if not configured correctly. Always back up your data before making any changes. Use these scripts at your own risk.

## Credits

The inspiration and most of the optimizations here come from the amazing guides in [asus-linux.org](https://asus-linux.org/). Used them on my Zephyrus laptop and figured I'd do the same on my desktop. 
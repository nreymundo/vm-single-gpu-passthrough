# Single GPU Passthrough for Windows 11 VM

This repository contains a collection of scripts and configuration files to facilitate a single GPU passthrough setup for a Windows 11 virtual machine using Libvirt and QEMU/KVM.

## Note and disclaimer

This setup is complex and can lead to system instability if not configured correctly. Always back up your data before making any changes. Use these scripts at your own risk.

This is very opinionated and not guaranteed to be the most efficient setup (like, at all). Or stable, I've locked myself out of my host system because the USB controllers never bound back properly while setting it up. 

TL;DR: Here be dragons. 

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
│   ├── modules-load.d/
│   │   └── vfio.conf
│   └── udev/
│       └── rules.d/
│           ├── 90-tpm-permissions.rules
│           └── 99-vfio-permissions.rules
└── virt-manager/
    └── sample.xml
```

*   `etc/libvirt/hooks/qemu`: The main hook script that executes the per-VM hooks.
*   `etc/libvirt/hooks/qemu.d/win11`: Contains the hooks for the `win11` VM.
    *   `prepare/begin`: Scripts that run before the VM starts.
    *   `release/end`: Scripts that run after the VM shuts down.
*   `etc/modules-load.d/vfio.conf`: Kernel modules to be loaded at boot.
*   `etc/udev/rules.d/`: Contains udev rules for device permissions.
    *   `90-tpm-permissions.rules`: Sets permissions for the TPM device.
    *   `99-vfio-permissions.rules`: Sets permissions for VFIO devices.
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

### Make Libvirt run as  a fixed user instead of a dynamic one

This can potentially have some security implications. Since this is just a gaming VM for every now and then I won't go into too much on that. 

1. Edit `/etc/libvirt/qemu.conf` and change these fields
```
user = "libvirt-qemu" 
group = "libvirt-qemu"
dynamic_ownership = 0
```

### Hardware TPM passthrough

You can use an emulated TPM and avoid a bit of configuration/headache but I wanted to make the VM look as 'real' as possible. 

1. Add this to your XML file. 
```xml
<tpm model="tpm-tis">
  <backend type="passthrough">
    <device path="/dev/tpm0"/>
  </backend>
</tpm>
```
2. We will use an udev rule to change ownership so that libvirt can use it. 
3. Add the user `libvirt-qemu` (or the user specified above) to the `tss` group. `sudo usermod -aG tss libvirt-qemu`. 
4. Copy the udev rule from this repo to the appropriate path.
5. Reload udev rules `sudo udevadm control --reload-rules`, trigger them `sudo udevadm trigger` and restart libvirt `sudo systemctl restart libvirtd`. 

### VFIO device permissions

Not necessary if you're using libvirt with the dynamic users (the default option). I had to change this for TPM passthrough instead of emulated so went down this rabbit hole. 

Just copy the udev rule from the folder in this repo to the same place. Reload/retrigger them and restart libvirt. 

## Usage

The hooks are executed automatically by libvirt when you start or stop the `win11` VM.

*   **VM Start**: The scripts in `prepare/begin` are executed.
*   **VM Shutdown**: The scripts in `release/end` are executed.

## Credits

The inspiration and most of the optimizations here come from the amazing guides in [asus-linux.org](https://asus-linux.org/). Used them on my Zephyrus laptop and figured I'd do the same on my desktop. 
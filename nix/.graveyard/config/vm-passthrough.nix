{ config, pkgs, ... }:

{
  # Enable virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;

  # Enable IOMMU
  boot.kernelParams = [
    "intel_iommu=on" # Use "amd_iommu=on" if you have an AMD CPU
    "iommu=pt"
    "pcie_aspm=off" # Disable PCIe power management
  ];

  # Load necessary kernel modules
  boot.kernelModules = [
    "kvm-intel"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];

  # Early loading of VFIO modules
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  # VFIO configuration
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1b81,10de:10f0  # Replace with your GPU's vendor:device IDs
  '';

  # Ensure the vfio-pci module is loaded before the NVIDIA module
  boot.blacklistedKernelModules = [
    "nvidia"
    "nouveau"
  ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    OVMF # Required for UEFI support in VMs
    pciutils # Provides lspci command
  ];

  # Optional: CPU pinning for better performance
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
      "/dev/rtc","/dev/hpet",
      "/dev/vfio/vfio", "/dev/vfio/1"
    ]
    namespaces = []
  '';
}

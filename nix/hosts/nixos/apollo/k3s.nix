{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true;
  };
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [
    docker
    runc
  ];

  # K3s services configuration
  services.k3s = {
    extraFlags = [
      # Wake-on-LAN related labels
      "--node-label=wol.mac-address=b4-2e-99-a6-54-36"
      "--node-label=power.management=wol"
      "--register-with-taints=power.management=wol:NoSchedule"

      # GPU-related labels
      "--node-label=nvidia.com/gpu=true"
      "--node-label=gpu.nvidia.com/count=1"
      "--node-label=gpu.nvidia.com/type=GTX1080Ti"
      "--node-label=gpu.nvidia.com/memory=11264MiB"

      # CPU-related labels
      "--node-label=cpu.architecture=x86_64"
      "--node-label=cpu.model=Intel-Core-i9-9900KS"
      "--node-label=cpu.cores=8"
      "--node-label=cpu.threads=16"
      "--node-label=cpu.max.frequency=5000MHz"
      "--node-label=cpu.features=avx"

      # Memory-related label
      "--node-label=memory.capacity=46.98GiB"

      # Storage-related label
      "--node-label=storage.capacity=864.04GiB"

      # Display-related labels
      "--node-label=display.count=2"
      "--node-label=display.1=2560x1440-144Hz"
      "--node-label=display.2=3840x2160-60Hz"

      # OS-related labels
      "--node-label=os.name=NixOS"
      "--node-label=os.version=24.11.20240923.30439d9"
    ];
  };

  # Containerd config for Nvidia GPU passthrough
  systemd.services."k3s-agent" = {
    serviceConfig = {
      ExecStartPre = ''
        mkdir -p /var/lib/rancher/k3s/agent/etc/containerd
        cat <<EOF > /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
        {{ template "base" . }}

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"
        EOF
      '';
    };
  };
}

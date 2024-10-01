{
  pkgs ? import <nixpkgs> { },
}:
let
  script = pkgs.writeShellScriptBin "generate-k3s-labels" ''
    # Function to sanitize strings for label values
    sanitize() {
      echo "$1" | tr -cd '[:alnum:]()-.\/_' | tr '[:upper:]' '[:lower:]'
    }

    # Get MAC address
    mac_address=$(${pkgs.iproute2}/bin/ip link show | grep -A 1 ': en' | grep 'link/ether' | awk '{print $2}' | head -n 1)

    # Get GPU info
    if ${pkgs.nvidia-cli}/bin/nvidia-smi &>/dev/null; then
      gpu_info=$(${pkgs.nvidia-cli}/bin/nvidia-smi --query-gpu=gpu_name,memory.total --format=csv,noheader)
      gpu_name=$(echo "$gpu_info" | cut -d',' -f1 | xargs)
      gpu_memory=$(echo "$gpu_info" | cut -d',' -f2 | xargs)
      gpu_count=1
    else
      gpu_name="none"
      gpu_memory="0"
      gpu_count=0
    fi

    # Get CPU info
    cpu_arch=$(${pkgs.util-linux}/bin/lscpu | grep "Architecture:" | awk '{print $2}')
    cpu_model=$(${pkgs.util-linux}/bin/lscpu | grep "Model name:" | sed -r 's/Model name:\s{1,}//g')
    cpu_cores=$(${pkgs.util-linux}/bin/lscpu | grep "^CPU(s):" | awk '{print $2}')
    cpu_threads=$(${pkgs.util-linux}/bin/lscpu | grep "Thread(s) per core:" | awk '{print $4}')
    cpu_max_freq=$(${pkgs.util-linux}/bin/lscpu | grep "CPU max MHz:" | awk '{printf "%.0f", $4}')
    cpu_features=$(${pkgs.util-linux}/bin/lscpu | grep "Flags:" | cut -d ':' -f 2 | tr -s ' ' '\n' | sort | uniq | grep -E 'avx|avx2|sse4_2' | tr '\n' ',' | sed 's/,$//')

    # Get memory info
    memory_total=$(${pkgs.procps}/bin/free -g | awk '/^Mem:/{print $2}')

    # Get storage info
    storage_total=$(${pkgs.coreutils}/bin/df -h / | awk '/\/$/ {print $2}' | sed 's/G//')

    # Get display info
    if [ -n "$DISPLAY" ]; then
      display_info=$(${pkgs.xorg.xrandr}/bin/xrandr | grep ' connected' | awk '{print $1 "=" $3}' | tr '\n' ',' | sed 's/,$//')
      display_count=$(echo "$display_info" | tr ',' '\n' | wc -l)
    else
      display_info="none"
      display_count=0
    fi

    # Get OS info
    os_name="NixOS"
    os_version=$(${pkgs.nixos-version}/bin/nixos-version)

    # Generate Nix configuration
    cat << EOF
    {
      services.k3s = {
        extraFlags = [
          # Wake-on-LAN related labels
          "--node-label=wol.mac-address=\''${mac_address}"
          # GPU-related labels
          "--node-label=nvidia.com/gpu=\''${gpu_count:+true}"
          "--node-label=gpu.nvidia.com/count=\''${gpu_count}"
          "--node-label=gpu.nvidia.com/type=\''${gpu_name}"
          "--node-label=gpu.nvidia.com/memory=\''${gpu_memory}"
          # CPU-related labels
          "--node-label=cpu.architecture=\''${cpu_arch}"
          "--node-label=cpu.model=\''${cpu_model}"
          "--node-label=cpu.cores=\''${cpu_cores}"
          "--node-label=cpu.threads=\''${cpu_threads}"
          "--node-label=cpu.max.frequency=\''${cpu_max_freq}MHz"
          "--node-label=cpu.features=\''${cpu_features}"
          # Memory-related label
          "--node-label=memory.capacity=\''${memory_total}GiB"
          # Storage-related label
          "--node-label=storage.capacity=\''${storage_total}GiB"
          # Display-related labels
          "--node-label=display.count=\''${display_count}"
          \''${display_count:+$(
            IFS=',' read -ra DISPLAYS <<< "$display_info"
            for i in "''${!DISPLAYS[@]}"; do
              echo "          \"--node-label=display.$((i+1))=\''${DISPLAYS[i]}\""
            done
          )}
          # OS-related label
          "--node-label=os.name=\''${os_name}"
          "--node-label=os.version=\''${os_version}"
        ];
      };
    }
    EOF
  '';
in
pkgs.symlinkJoin {
  name = "k3s-label-generator";
  paths = [ script ];
}

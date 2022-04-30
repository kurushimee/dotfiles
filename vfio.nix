{ config, pkgs, lib, ... }:
let
  ## Configuration
  my-iommu-group = [ "pci_0000_1f_00_0" "pci_0000_1f_00_1" ];

  memory = 12288;
  Hugepagesize = 2048;
  # $ grep Hugepagesize /proc/meminfo

  ## Scripts
  lsiommu = pkgs.writeShellScriptBin "lsiommu" ''
    shopt -s nullglob
    for g in /sys/kernel/iommu_groups/*; do
      echo "IOMMU Group ''${g##*/}:"
      for d in $g/devices/*; do
          echo -e "\t$(lspci -nns ''${d##*/})"
      done;
    done;
  '';

  allocHugepages = ''
    echo "Allocating hugepages..."
    HUGEPAGES=${builtins.toString (memory / (Hugepagesize / 1024))}
    echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
    ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
  
    TRIES=0
    while (( $ALLOC_PAGES != $HUGEPAGES && $TRIES < 10 ))
    do
        echo 1 > /proc/sys/vm/compact_memory            ## defrag ram
        echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
        ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
        echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES"
        let TRIES+=1
    done

    if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
    then
        echo "Not able to allocate all hugepages. Reverting..."
        echo 0 > /proc/sys/vm/nr_hugepages
        exit 1
    fi
  '';

  qemuEntrypoint = pkgs.writeShellScript "qemu" ''
    # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
    export PATH="$PATH:${pkgs.findutils}/bin:${pkgs.bash}/bin:${pkgs.util-linux}/bin"

    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    MISC="''${@:4}"

    BASEDIR="$(dirname $0)"

    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

    set -e # If a script exits with an error, we should as well.

    # check if it's a non-empty executable file
    if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
        eval \"$HOOKPATH\" "$@"
    elif [ -d "$HOOKPATH" ]; then
        while read file; do
            # check for null string
            if [ ! -z "$file" ]; then
              # Log the hook execution
              mkdir -p /var/log/libvirt/hooks
              script /var/log/libvirt/hooks/$GUEST_NAME-$HOOK_NAME-$STATE_NAME.log bash -c "$file $@"
            fi
        done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
    fi
  '';

  win11.hookPrepare = pkgs.writeShellScript "start.sh" ''
    export PATH="$PATH:${pkgs.kmod}/bin:${pkgs.systemd}/bin:${pkgs.libvirt}/bin"
    # Isolate host to core 0
    systemctl set-property --runtime -- user.slice AllowedCPUs=0
    systemctl set-property --runtime -- system.slice AllowedCPUs=0
    systemctl set-property --runtime -- init.scope AllowedCPUs=0

    # Stop display manager
    systemctl stop display-manager.service
  '';

  win11.hookRelease = pkgs.writeShellScript "stop.sh" ''
    export PATH="$PATH:${pkgs.kmod}/bin:${pkgs.systemd}/bin:${pkgs.libvirt}/bin"
    # Start display manager
    systemctl start display-manager.service
    # Return host to all cores
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-11
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-11
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-11
    Dealloc hugepages
    echo 0 > /proc/sys/vm/nr_hugepages
  '';
in {
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "rd.driver.pre=vfio-pc" "video=efifb:off" ];
  boot.kernelModules = [ "kvm-amd" "vfio-pci" ];

  # Enable libvirtd
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = true;
  };

  # VFIO Packages installed
  environment.systemPackages = with pkgs; [
    lsiommu
    virt-manager
    gnome3.dconf # needed for saving settings in virt-manager
    libguestfs # needed to virt-sparsify qcow2 files
    win-virtio # needed for passing through input devices
  ];
  programs.dconf.enable = true;

  # User accounts
  users.users.iver = { extraGroups = [ "libvirtd" "input" "kvm" ]; };

  #systemd.services.vlmcsd.script =
  #  "${packages.self.vlmcsd}/bin/vlmcsd -L 192.168.122.1:${
  #    builtins.toString vlmcsd-port
  #  } -e -D";
  networking.firewall.interfaces.virbr0.allowedTCPPorts = [ vlmcsd-port ];
  networking.firewall.interfaces.virbr0.allowedUDPPorts = [ vlmcsd-port ];

  systemd.tmpfiles.rules = [
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${qemuEntrypoint}"

    "L+ /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin/start.sh - - - - ${win10.hookPrepare}"
    "L+ /var/lib/libvirt/hooks/qemu.d/win10/release/end/stop.sh - - - - ${win10.hookRelease}"
  ];
}

{ config, pkgs, lib, ... }:
let
  memory = 12288;
  Hugepagesize = 2048;
  # $ grep Hugepagesize /proc/meminfo

  # Scripts.
  lsiommu = pkgs.writeShellScriptBin "lsiommu" ''
    shopt -s nullglob
    for g in /sys/kernel/iommu_groups/*; do
      echo "IOMMU Group ''${g##*/}:"
      for d in $g/devices/*; do
          echo -e "\t$(lspci -nns ''${d##*/})"
      done;
    done;
  '';

  # VM start shortcut.
  xdg.desktopEntries.win11 = {
    name = "Windows 11";
    genericName = "Virtual Machine";
    exec = "sudo virsh start win11";
    icon = "/home/iver/Documents/Icons/win11.ico";
    terminal = false;
    type = "Application";
    categories = [ "VirtualMachine" ];
  };

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

  usbLibvirtHotplug = pkgs.writeShellScript "usb-libvirt-hotplug.sh" ''
export PATH="$PATH:/var/lib/libvirt"
# Abort script execution on errors
set -e

PROG="$(basename "$0")"

if [ ! -t 1 ]; then
  # stdout is not a tty. Send all output to syslog.
  coproc logger --tag "$PROG"
  exec >&$COPROC[1] 2>&1
fi

DOMAIN="$1"
if [ -z "$DOMAIN" ]; then
  echo "Missing libvirt domain parameter for $PROG." >&2
  exit 1
fi


#
# Do some sanity checking of the udev environment variables.
#

if [ -z "$SUBSYSTEM" ]; then
  echo "Missing udev SUBSYSTEM environment variable." >&2
  exit 1
fi
if [ "$SUBSYSTEM" != "usb" ]; then
  echo "Invalid udev SUBSYSTEM: $SUBSYSTEM" >&2
  echo "You should probably add a SUBSYSTEM=\"USB\" match to your udev rule." >&2
  exit 1
fi

if [ -z "$DEVTYPE" ]; then
  echo "Missing udev DEVTYPE environment variable." >&2
  exit 1
fi
if [ "$DEVTYPE" == "usb_interface" ]; then
  # This is normal -- sometimes the udev rule will match
  # usb_interface events as well.
  exit 0
fi
if [ "$DEVTYPE" != "usb_device" ]; then
  echo "Invalid udev DEVTYPE: $DEVTYPE" >&2
  exit 1
fi

if [ -z "$ACTION" ]; then
  echo "Missing udev ACTION environment variable." >&2
  exit 1
fi
if [ "$ACTION" == 'add' ]; then
  COMMAND='attach-device'
elif [ "$ACTION" == 'remove' ]; then
  COMMAND='detach-device'
else
  echo "Invalid udev ACTION: $ACTION" >&2
  exit 1
fi

if [ -z "$BUSNUM" ]; then
  echo "Missing udev BUSNUM environment variable." >&2
  exit 1
fi
if [ -z "$DEVNUM" ]; then
  echo "Missing udev DEVNUM environment variable." >&2
  exit 1
fi


#
# This is a bit ugly. udev passes us the USB bus number and
# device number with leading zeroes. E.g.:
#   BUSNUM=001 DEVNUM=022
# This causes libvirt to assume that the numbers are octal.
# To work around this, we need to strip the leading zeroes.
# The easiest way is to ask bash to convert the numbers from
# base 10:
#
BUSNUM=$((10#$BUSNUM))
DEVNUM=$((10#$DEVNUM))

#
# Now we have all the information we need to update the VM.
# Run the appropriate virsh-command, and ask it to read the
# update XML from stdin.
#
echo "Running virsh $COMMAND $DOMAIN for USB bus=$BUSNUM device=$DEVNUM:" >&2
virsh "$COMMAND" "$DOMAIN" /dev/stdin <<END
<hostdev mode='subsystem' type='usb'>
  <source>
    <address bus='$BUSNUM' device='$DEVNUM' />
  </source>
</hostdev>
END
  '';
in {
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "rd.driver.pre=vfio-pc" "video=efifb:off" "kvm.ignore_msrs=1" ];
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

  systemd.tmpfiles.rules = [
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${qemuEntrypoint}"
    "L+ /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh - - - - ${win11.hookPrepare}"
    "L+ /var/lib/libvirt/hooks/qemu.d/win11/release/end/stop.sh - - - - ${win11.hookRelease}"
    "L+ /var/lib/libvirt/usb-libvirt-hotplug.sh - - - - ${usbLibvirtHotplug}"
  ];
  services.udev.extraRules = ''SUBSYSTEM=="usb",DEVPATH=="/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2",RUN+="/var/lib/libvirt/usb-libvirt-hotplug.sh win11"'';
}


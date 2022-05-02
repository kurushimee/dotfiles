{ config, pkgs, lib, ... }:
let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/cachix.nix
    ./vfio.nix
  ];

  # Setup Grub bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root "B406-FD60"
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      version = 2;
      extraGrubInstallArgs = [ "--modules=tpm" "--disable-shim-lock" ];
    };
  };
  time.hardwareClockInLocalTime = true;

  # Networking
  networking = {
    hostName = "nixos";
    # wireless.enable = true; # Enables wireless support via wpa_supplicant.
    useDHCP = false;
    interfaces.ens3.useDHCP = true;
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };

  # Time zone.
  time.timeZone = "Asia/Novosibirsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Splash screen.
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";

  # Nvidia graphics.
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
  };

  # Enable the Gnome Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # BSPWM.
  services.xserver.windowManager.bspwm.enable = true;

  # Set mouse speed.
  services.xserver.libinput.mouse = {
    accelProfile = "flat";
    accelSpeed = "-0.3";
  };

  # Enable sound via Pipewire.
  # TODO: transition from media-session to wireplumber.
  # Prepare Bluetooth and audio.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.hsphfpd.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    # Initialize Pipewire.
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Configure Bluetooth audio.
    media-session.config.bluez-monitor.rules = [
      {
        # Match any device and auto-connect A2DP sink instead of poor quality HFP.
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = { "bluez5.auto-connect" = [ "a2dp_sink" ]; };
        };
      }
      {
        # Match any Bluetooth audio device.
        matches = [
          { node.name = "~bluez.input.*"; }
          { node.name = "~bluez.output.*"; }
        ];
        actions = { "node.pause-on-idle" = false; };
      }
    ];

    # Configure Pipewire for low latency.
    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = 2;
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 32;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 32;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }

        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }
        {
          name = "libpipewire-module-access";
          args = { };
        }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
      ];
    };

    # Configure Pipewire-Pulse for low-latency.
    config.pipewire-pulse = {
      "context.properties" = { "log.level" = 2; };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "32/48000";
            "pulse.max.req" = "32/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "32/48000";
            "server.address" = [ "unix:native" ];
          };
        }
      ];
      "stream.properties" = {
        "node.latency" = "32/48000";
        "resample.quality" = 1;
      };
    };
  };

  # Define user accounts.
  users.users.iver = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
  users.users.anna = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  # Set Fish as shell.
  programs.fish.enable = true;
  users.users.iver = { shell = pkgs.fish; };

  # Enable Docker.
  virtualisation.docker.enable = true;
  # Enable Steam.
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  # Enable Blueman.
  services.blueman.enable = true;

  # Enable SSH.
  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  environment.sessionVariables.TERMINAL = [ "alacritty" ];
  environment.sessionVariables.EDITOR = [ "nvim" ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # CLI tools.
    alacritty # Terminal.
    git # Version control system.
    pinentry # Key generation for GPG.
    gnupg # GPG key management.
    wget
    neovim # CLI editor.
    pfetch # System info.
    feh # Set background image.
    sxiv
    ranger # File manager.
    maim
    scrot # Screenshot capture tool.
    killall
    unzip
    service-wrapper # service command support.
    pavucontrol # Audio volume management.
    nodejs
    shellcheck
    # Languages.
    python310
    unstable.clang_14 # C++.
    omnisharp-roslyn # CSharp language server.
    mono # CSharp.
    dotnet-sdk # .NET.
    haskellPackages.ghcup # Haskell package manager?
    haskell-language-server
    nixfmt # Nix formatter.
    lua
    # GUI apps.
    firefox
    gnome.nautilus # File manager.
    vlc
    steam
    lutris
    discord
    audacity
    aseprite-unfree
    qbittorrent
    blueman
    # Window management.
    nur.repos.reedrw.picom-next-ibhagwan # Picom fork with rounded corners and blur.
    bspwm # Tiling window manager.
    sxhkd # Keyboard bindings manager.
    polybar # Top bar for bspwm.
    rofi # Run tool for bspwm.
    # Theming.
    lxappearance # Change GTK appearance.
    arc-theme # GTK theme.
    papirus-icon-theme # Icon theme.
    bibata-cursors # Cursor theme.
    # Libraries.
    libgdiplus
    ffmpeg # Media codecs.
    gcc
    libgccjit
    glibcLocales
    unstable.certbot
    ripgrep
    unstable.fd
    xclip # Clipboard management.
    xdotool
    xorg.xprop
    xorg.xwininfo
    xorg.xinit
  ];

  fonts.fonts = with pkgs; [
    roboto
    (nerdfonts.override { fonts = [ "Iosevka" "FiraCode" ]; })
  ];

  # Auto upgrades.
  system.autoUpgrade.enable = true;

  nix = {
    # Hard link identical files in the store automatically.
    autoOptimiseStore = true;
    # Automatically trigger garbage collection.
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}


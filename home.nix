{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "iver";
  home.homeDirectory = "/home/iver";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git.
  programs.git = {
    enable = true;
    userName = "Ivan Ermacoff";
    userEmail = "jermacoff@gmail.com";
    signing = {
      key = "810A731D7554CA16";
      signByDefault = true;
    };
  };

  # Alacritty.
  home.file = {
    ".config/alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;
    ".config/alacritty/dracula.yml".source = ./alacritty/dracula.yml;
  };

  # Ranger.
  home.file = {
    ".config/ranger/commands.py".source = ./ranger/commands.py;
    ".config/ranger/rc.conf".source = ./ranger/rc.conf;
    ".config/ranger/rifle.conf".source = ./ranger/rifle.conf;
    ".config/ranger/scope.sh".source = ./ranger/scope.sh;
  };

  # Window management.
  # Based off of https://github.com/NiharKod/dots
  home.file = {
    ".config/bspwm/bspwmrc".source = ./bspwmrc;
    ".config/picom/picom.conf".source = ./picom.conf;
    ".config/sxhkd/sxhkdrc".source = ./sxhkdrc;
    # Polybar.
    ".config/polybar/colors.ini".source = ./polybar/colors.ini;
    ".config/polybar/config.ini".source = ./polybar/config.ini;
    ".config/polybar/modules.ini".source = ./polybar/modules.ini;
    ".config/polybar/launch.sh".source = ./polybar/launch.sh;
    # Rofi.
    ".config/rofi/config.rasi".source = ./rofi/config.rasi;
    ".config/rofi/onedark.rasi".source = ./rofi/onedark.rasi;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacsGcc;
    extraPackages = (epkgs: [ epkgs.vterm ] );
  };
}


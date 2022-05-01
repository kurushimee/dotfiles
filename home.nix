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

  # Git config.
  programs.git = {
    enable = true;
    userName = "Ivan Ermacoff";
    userEmail = "jermacoff@gmail.com";
    signing = {
      key = "810A731D7554CA16";
      signByDefault = true;
    };
  };

  home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
  home.file.".config/alacritty/dracula.yml".source = ./dracula.yml;

  # Window management config.
  home.file.".config/bspwm/bspwmrc".source = ./bspwmrc;
  home.file.".config/picom/picom.conf".source = ./picom.conf;
  home.file.".config/sxhkd/sxhkdrc".source = ./sxhkdrc;
}

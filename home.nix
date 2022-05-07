{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "iver";
  home.homeDirectory = "/home/iver";

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.ranger     # CLI file manager.
    pkgs.pinentry   # GnuPG’s interface to passphrase input.
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship.enable = true;  # Starship prompt.

  # Ranger file manager.
  home.file = {
    ".config/ranger/commands.py".source = ./ranger/commands.py;
    ".config/ranger/rc.conf".source = ./ranger/rc.conf;
    ".config/ranger/rifle.conf".source = ./ranger/rifle.conf;
    ".config/ranger/scope.sh".source = ./ranger/scope.sh;
  };

  # Git source control.
  programs.git = {
    enable = true;
    userName = "Ivan Ermacoff";
    userEmail = "jermacoff@gmail.com";
    signing = {
      key = "DEFE834B657D760E";
      signByDefault = true;
    };
  };

  programs.gpg.enable = true;  # GPG key management.
}

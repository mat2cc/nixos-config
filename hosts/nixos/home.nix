{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ../common.nix
    ../../modules/tmux.nix
    ../../modules/sway.nix
  ];
  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  myprograms.tmux.tmuxType = "play";


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    brave
    ghostty # gui
  ];

  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}

{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ../common.nix
    ../../modules/tmux.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.file.".ssh/rpi4.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjTv5iYdJm96i/yANv4bCqJiV3XuAacO5uKrW3cCGdc mattc@nixos
  '';

  myprograms.tmux.tmuxType = "play";

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets.github-ssh-key = {};
  sops.secrets.rpi4-ssh-key = {};

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "rpi4" = {
        hostname = "192.168.68.73";
        user = "mattc";
        identityFile = config.sops.secrets.rpi4-ssh-key.path;
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      
      "github.com" = {
        hostname = "github.com";
        identityFile = config.sops.secrets.github-ssh-key.path;
      };
    };
  };


  programs.waybar.enable = true;
  # programs.waybar.settings = {
  #   mainBar = {
  #     layer = "top";
  #     position = "top";
  #     height = 26;
  #     output = [
  #       "eDP-1"
  #     ];
  #
  #     modules-left = [ "custom/logo" "sway/workspaces" "sway/mode" ];
  #     modules-right = [ "sway/language" "clock" "battery" ];
  #     
  #     "custom/logo" = {
  #       format = "";
  #       tooltip = false;
  #       on-click = ''bemenu-run --accept-single  -n -p "Launch" --hp 4 --hf "#ffffff" --sf "#ffffff" --tf "#ffffff" '';
  #     };
  #
  #     "sway/workspaces" = {
  #       disable-scroll = true;
  #       all-outputs = true;
  #       persistent_workspaces = {
  #         "1" = []; 
  #         "2" = [];
  #   "3" = [];
  #   "4" = [];
  #       };
  #       disable-click = true;
  #     };
  #
  #     "sway/mode" = {
  #       tooltip = false;
  #     };
  #     
  #     "sway/language" = {
  #       format = "{shortDescription}";
  #       tooltip = false;
  #       on-click = ''swaymsg input "1:1:AT_Translated_Set_2_keyboard" xkb_switch_layout next'';
  #
  #     };
  #
  #     "clock" = {
  #       interval = 60;
  #       format = "{:%a %d/%m %I:%M}";
  #     };
  #
  #     "battery" = {
  #       tooltip = false;
  #     };
  #   };
  # };
  #
  # programs.waybar.style = ''
  # * {
  #   border: none;
  #   border-radius: 0;
  #   padding: 0;
  #   margin: 0;
  #   font-size: 11px;
  # }
  #
  # window#waybar {
  #   background: #292828;
  #   color: #ffffff;
  # }
  #
  # #custom-logo {
  #   font-size: 18px;
  #   margin: 0;
  #   margin-left: 7px;
  #   margin-right: 12px;
  #   padding: 0;
  #   font-family: NotoSans Nerd Font Mono;
  # }
  #
  # #workspaces button {
  #   margin-right: 10px;
  #   color: #ffffff;
  # }
  # #workspaces button:hover, #workspaces button:active {
  #   background-color: #292828;
  #   color: #ffffff;
  # }
  # #workspaces button.focused {
  #   background-color: #383737;
  # }
  #
  # #language {
  #   margin-right: 7px;		
  # }
  #
  # #battery {
  #   margin-left: 7px;
  #   margin-right: 3px;
  # }
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # waybar
    brave
    librewolf
    claude-code
    ghostty # gui
    neovim
  ];

  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}

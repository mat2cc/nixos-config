{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ../common.nix
    ../../modules/tmux.nix
    ../../modules/firstmate.nix
    ../../modules/openwhispr.nix
    # ../../modules/code.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  myprograms.firstmate.enable = true;
  myprograms.openwhispr.enable = true;

  home.file.".ssh/rpi4.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjTv5iYdJm96i/yANv4bCqJiV3XuAacO5uKrW3cCGdc mattc@nixos
  '';

  myprograms.tmux.tmuxType = "play";

  # Convenience symlinks to the secondary drives declared in modules/drives.nix.
  # mkOutOfStoreSymlink points at the live path rather than copying anything
  # into the nix store, so these stay live mounts and not frozen snapshots.
  home.file."seagate_st8000".source = config.lib.file.mkOutOfStoreSymlink "/mnt/seagate_st8000";
  home.file."samsung_980_pro".source = config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_980_pro";
  home.file."samsung_990_evo".source = config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_990_evo";

  # Steam libraries left behind by the old Windows / Ubuntu / Arch installs,
  # grouped so they don't clutter $HOME. Sizes are as of the Sep 2026 survey.
  #
  # arch-old_steam is the 642G library rescued from the old /mnt/wd_black. A
  # stale second snapshot alongside it (old_steam/SteamLibrary) was deleted on
  # 2026-09-03 to reclaim ~630G; its Proton prefixes for the only two games
  # that differed are archived in ~/steam-old-prefix-backup.
  home.file."steam-libraries/arch-old_steam".source =
    config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_990_evo/@home/mattc/old_steam";
  home.file."steam-libraries/arch-live".source =
    config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_990_evo/@home/mattc/.local/share/Steam";
  home.file."steam-libraries/ubuntu".source =
    config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_980_pro/ubuntu-home/mattc/.local/share/Steam";
  home.file."steam-libraries/windows".source =
    config.lib.file.mkOutOfStoreSymlink "/mnt/samsung_980_pro/windows/Program Files (x86)/Steam";

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

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # waybar
    obsidian
    brave
    librewolf
    # claude-code
    ghostty
    neovim
    kitty
    discord
    tree-sitter
    stockfish # UCI engine; the chess project's analysis worker shells out to it

    # protonup-ng
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
  ];

  programs.direnv = {
    enable = true;
    # enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # };
  gtk = {
    enable = true;
  };

  # wayland.windowManager.hyprland = {
  #   systemd.enable = false;
  #   settings = {
  #   };
  # };

  # 
  # programs.waybar.enable = true;
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


  # home.sessionVariables = {
  #   STEAM_EXTRA_COMPAT_TOOLS_PATHS =
  #     "\\\${HOME}/.steam/root/compatibilitytools.d";
  # };

  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}

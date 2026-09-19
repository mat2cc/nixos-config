# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, username, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/gaming.nix
      ../../modules/displays.nix
      ../../modules/fonts.nix
      ../../modules/drives.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      Policy = {
        AutoEnable = true;
      };
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        dmenu
      ];
    };
  };
  services.displayManager.defaultSession = "none+i3";
  programs.i3lock.enable = true;

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--netfilter-mode=nodivert" ];
  };


  # docker
  virtualisation.docker = {
    enable = true;
  };

  # Required for sway (if used with home manager)
  # security.polkit.enable = true;

  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  #   extraOptions = [ "--unsupported-gpu" ];
  # };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "Matthew Christofides";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.overlays = [inputs.claude-code.overlays.default inputs.tuxedo.overlays.default];
  environment.systemPackages = with pkgs; [
    wget
    # neovim
    nixd
    steam
    pavucontrol
    pwvucontrol
    claude-code
    # fishPlugins.tide
    # git
  ];

  environment.variables.EDITOR = "nvim";

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
        # PasswordAuthentication = true;
        AllowUsers = [ "mattc" ];
        PermitRootLogin = "no";
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
    };
  };

  # services.greetd = {                                                      
  #   enable = true;                                                         
  #   settings = {                                                           
  #     default_session = {                                                  
  #       command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd i3";
  #       user = "greeter";                                                  
  #     };                                                                   
  #   };                                                                     
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

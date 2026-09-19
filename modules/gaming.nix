{ pkgs, lib, config, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    # protonup
  ];

  # protonup -d "~/.steam/root/compatibilitytools.d/"

  programs.gamemode.enable = true;
}

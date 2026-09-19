{ pkgs, lib, ... }:
let
  # DP-0 is the portrait 2560x1440 panel, DP-4 the ultrawide.
  mkMode = name: args: pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.xorg.xrandr ];
    text = ''
      export DISPLAY="''${DISPLAY:-:0}"
      xrandr ${args}
    '';
  };

  mode-standard = mkMode "mode-standard"
    "--output DP-4 --auto --right-of DP-0 --output DP-0 --auto --mode 2560x1440 --rate 120 --rotate right";

  mode-gaming = mkMode "mode-gaming"
    "--output DP-0 --rotate normal --mode 2560x1440 --rate 120 --auto --left-of DP-4 --output DP-4 --auto";
in
{
  environment.systemPackages = [ mode-standard mode-gaming ];

  # mode-standard is the default layout at login.
  services.xserver.displayManager.sessionCommands = ''
    ${lib.getExe mode-standard} || true
  '';
}

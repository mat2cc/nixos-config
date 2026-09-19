{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.myprograms.code;
in {
  options.myprograms.code = {
    enable = mkEnableOption "Enable code";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      go
      nodejs
      yarn
      pnpm
      rustup
      air # go runner
      pi-coding-agent # `pi` terminal coding agent
    ];
  };
 }

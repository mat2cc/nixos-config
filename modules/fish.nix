{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # disable geeting
    '';
    shellAliases = {
      ls = "eza";
      l = "eza -lah --icons";
      vi = "nvim";
      vim = "nvim";
      gs = "git status";
      gl = "git log";
    };
    plugins = [
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
    ];
  };
}

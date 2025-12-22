{ ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "ghostty"; 
      output = {
        "DP-6" = {
          resolution = "3440x1440";
          position = "0,0";
        };
        "DP-4" = {
          resolution = "2560x1440@120Hz";
          position = "-1440,-320";
          transform = "90";
        };
      };
      # modes = {
      #   resize = {
      #     "${modifier}" = "resize shrink width 10 px or 10 ppt";
      #     "${modifier}" = "resize grow height 10 px or 10 ppt";
      #     "${modifier}" = "resize shrink height 10 px or 10 ppt";
      #     "${modifier}" = "resize grow width 10 px or 10 ppt";
      #   };
      # };
      # startup = [
      #   # Launch Firefox on start
      #   {command = "firefox";}
      # ];
    };
  };
}

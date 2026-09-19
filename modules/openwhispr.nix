{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.myprograms.openwhispr;

  pname = "openwhispr";
  version = "1.8.1";

  src = pkgs.fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${version}/OpenWhispr-${version}-linux-x86_64.AppImage";
    hash = "sha256-9QPEEb20XrbhNNYl45z/TmC2d0/+CzzfkKi0EOzR9uY=";
  };

  contents = pkgs.appimageTools.extractType2 { inherit pname version src; };

  # Electron app, so it ships its own Chromium and whisper.cpp/llama.cpp
  # binaries. AppImage rather than the .deb because the bundled natives expect
  # an FHS layout; wrapType2 gives them one instead of us autoPatchelf'ing
  # ~450MB of vendored libs.
  openwhispr = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    # Text injection is shelled out to, not linked, so these have to be on PATH
    # inside the FHS env or dictation transcribes and then silently drops the
    # text. xdotool/xclip are the X11 pair this host actually uses; the wayland
    # equivalents are cheap to carry and save a debugging session if the sway
    # config in this repo ever gets wired up.
    extraPkgs = pkgs: with pkgs; [
      xdotool
      xclip
      xsel
      wtype
      wl-clipboard
    ];

    extraInstallCommands = ''
      install -Dm444 ${contents}/open-whispr.desktop \
        $out/share/applications/openwhispr.desktop
      substituteInPlace $out/share/applications/openwhispr.desktop \
        --replace-fail "AppRun --no-sandbox" "openwhispr"
      cp -r ${contents}/usr/share/icons $out/share/
    '';
  };
in {
  options.myprograms.openwhispr = {
    enable = mkEnableOption "OpenWhispr voice dictation";
  };

  config = mkIf cfg.enable {
    home.packages = [ openwhispr ];
  };
}

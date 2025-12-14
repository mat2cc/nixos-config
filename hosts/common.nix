{ pkgs, ... }:
{
  imports = [
    ../modules/fish.nix 
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Matthew Christofides";
      userName = "mat2cc";
      email = "matthewchristofides@gmail.com";
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };
}

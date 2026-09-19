{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.myprograms.firstmate;

  # firstmate is an "agent distro", not an app: the cloned repo *is* the
  # install, and it keeps mutable state (state/, data/, config/, projects/,
  # worktrees) inside its own root, so it can't live read-only in the store.
  # This module installs the toolchain its bin/ scripts shell out to, keeps a
  # clone at cfg.home, and adds a launcher that starts a harness inside it.
  launcher = pkgs.writeShellScriptBin "firstmate" ''
    set -eu
    home=''${FM_HOME:-${cfg.home}}
    if [ ! -d "$home/.git" ]; then
      echo "firstmate: no clone at $home" >&2
      echo "  git clone ${cfg.repo} $home" >&2
      exit 1
    fi
    if ! command -v ${cfg.harness} >/dev/null 2>&1; then
      echo "firstmate: harness '${cfg.harness}' not on PATH" >&2
      exit 1
    fi
    cd "$home"
    exec ${cfg.harness} "$@"
  '';
in {
  options.myprograms.firstmate = {
    enable = mkEnableOption "firstmate agent distro";

    home = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/firstmate";
      description = "Directory holding the firstmate clone (its FM_HOME).";
    };

    repo = mkOption {
      type = types.str;
      default = "https://github.com/kunchenguid/firstmate";
      description = "Upstream repository cloned into `home`.";
    };

    harness = mkOption {
      type = types.str;
      default = "claude";
      description = "Agent harness the `firstmate` launcher execs inside the clone.";
    };

    autoClone = mkOption {
      type = types.bool;
      default = true;
      description = "Clone the repo on activation when `home` doesn't exist yet. Never touches an existing clone - firstmate updates itself.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      launcher

      # required by bin/fm-*.sh
      git
      gh # `gh auth login` is still a manual one-time step
      tmux # default session backend
      jq
      nodejs # fm-arm-command-policy.mjs
      python3
      curl
      fd
      shellcheck # fm-lint.sh
    ];

    home.activation.firstmate = mkIf cfg.autoClone (
      hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e ${escapeShellArg cfg.home} ]; then
          run ${pkgs.git}/bin/git clone ${escapeShellArg cfg.repo} ${escapeShellArg cfg.home}
        fi
      ''
    );
  };
}

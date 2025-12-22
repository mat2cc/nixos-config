{ pkgs, lib, config, ... }:
{

  options.myprograms.tmux = {
    # shortcutBindings = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [ ];
    #   description = ''
    #     A set of key bindings to be added to the tmux config.
    #   '';
    # };
    tmuxType = lib.mkOption {
      type = lib.types.enum [ "work" "play" ];
      default = "work";
      description = "setting the default keybinding for the home row";
    };
  };

  config = {
    programs.tmux = let
      cfg = config.myprograms.tmux;
      playBindings = ''
        bind -r a switch-client -t "nixos-config"
        bind -r o switch-client -t "chip8"
        bind -r e switch-client -t ""
        bind -r u switch-client -t ""
        bind -r i switch-client -t ""
      '';
      workBindings = ''
        bind -r a switch-client -t "api"
        bind -r o switch-client -t "dev-panel"
        bind -r e switch-client -t "auto"
        bind -r u switch-client -t "auth"
        bind -r i switch-client -t "proxy"
        bind -r p switch-client -t "play"
      '';
      bindings = if cfg.tmuxType == "work" then workBindings else playBindings;
    in {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [ 
        sensible 
        resurrect 
        vim-tmux-navigator
      ];
      extraConfig = ''
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",xterm-256color:Tc"

        # action key
        set -g prefix C-t
        unbind C-b
        bind-key C-t send-prefix

        # Splits
        unbind '"'
        unbind %
        bind c new-window -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind _ split-window -v -c "#{pane_current_path}"

        #### Key bindings
        set-window-option -g mode-keys vi
        set -g mouse on

        #bind t send-key C-t
        # Reload settings
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

        # Moving window
        bind-key -n C-S-Left swap-window -t -1 \; previous-window
        bind-key -n C-S-Right swap-window -t +1 \; next-window

        # Resizing pane
        bind -r k resize-pane -U 5
        bind -r j resize-pane -D 5
        bind -r h resize-pane -L 5
        bind -r l resize-pane -R 5

        # Maximize/Minimize
        bind -r m resize-pane -Z

        #### basic settings

        set-option -g status-justify "left"
        #set-option utf8-default on
        set-window-option -g mode-keys vi
        #set-window-option -g utf8 on

        unbind i
        unbind o
        ${bindings}

        # allow the title bar to adapt to whatever host you connect to
        set -g set-titles on
        set -g set-titles-string "#T"

        bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Status bar customization
        set -g status-interval 3     # update the status bar every 3 seconds
        set -g status-left "#[fg=#b4befe,bg=default]  #S #[fg=#45475a,bg=default]|"
        set -g status-right "#[fg=#b4befe,bg=default] %A, %d %b %Y | %I:%M %p"
        set -g status-justify left
        set -g status-left-length 200    # increase length (from 10)
        set -g status-position top
        set -g status-style 'bg=default' # transparent
        set -g window-status-current-format '#[fg=#a6da95,bg=default] #I #W'
        set -g window-status-format '#[fg=gray,bg=default] #I| #W'
        set -g window-status-last-style 'fg=white,bg=default'
        set -g default-terminal "''${TERM}"
        set -g message-command-style bg=default,fg=yellow
        set -g message-style bg=default,fg=#f2dcdc
        set -g mode-style bg=default,fg=yellow
      '';
    };
  };
}

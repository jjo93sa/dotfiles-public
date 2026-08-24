{pkgs, ...}: {
  # Tmux terminal multiplexer configuration
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = false;
    terminal = "screen-256color";

    extraConfig = ''
      # Set proper colours
      set -g default-terminal "screen-256color"

      set -g prefix C-a
      unbind C-b
      bind-key C-a send-prefix

      # Use | and - to split a window vertically and horizontally instead of " and % respoectively
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v

      unbind r
      bind r source-file ~/.tmux.conf

      # Resize panes with vim like keys
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      # C-a m maximizes a pane
      bind -r m resize-pane -Z

      # Enable resizing panes with the mouse
      set -g mouse on

      # Enable vi keys in tmux
      set-window-option -g mode-keys vi

      # Make selecting and copyng text like vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane

      # C-a C-x synchronizes/ unsynchronizes panes
      bind -n C-x setw synchronize-panes

      # Install the tmux plugin manager
      #set -g @plugin 'tmux-plugins/tpm'

      # Init tmux plugin manager (should be last line of file)
      #run '~/.config/tmux/plugins/tpm/tpm'
    '';

    # Install plugins with home-manager
    plugins = with pkgs.tmuxPlugins;
      [
        vim-tmux-navigator
        gruvbox
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }
      ];
  };

}

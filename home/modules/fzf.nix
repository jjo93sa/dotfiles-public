{...}: {
  # Install fzf via home-manager module
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    defaultOptions = [
      "--bind '?:toggle-preview'"
      "--bind 'ctrl-a:select-all'"
      "--bind 'ctrl-e:execute(echo {+} | xargs -o nvim)'"
      "--bind 'ctrl-y:execute-silent(echo {+} | wl-copy)'"
      "--color=fg:#ebdbb2,bg:#282828,hl:#b16286,fg+:#689d6a,bg+:#32302f,hl+:#d3869b,info:#d65d0e,prompt:#458588,pointer:#fe8019,marker:#8ec07c,spinner:#cc241d,header:#fabd2f"
      "--height=40%"
      "--info=inline"
      #"--layout=reverse"
      "--multi"
      "--preview '([[ -f {}  ]] && (bat --color=always --style=numbers,changes {} || cat {})) || ([[ -d {}  ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
      "--preview-window=:hidden"
      "--prompt='~ ' --pointer='▶' --marker='✓'"
    ];

    # ALT-C keybinding
    changeDirWidget.command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";

    # CTRL-T keybinding
    fileWidget.command = "fd --hidden --strip-cwd-prefix --exclude .git";

    # Atuin is the history manager and owns CTRL-R. Setting an empty command
    # disables FZF's competing history widget while retaining its other widgets.
    historyWidget.command = "";
    historyWidget.options = [];
  };
}
#FZF_DEFAULT_COMMAND=fd --hidden --strip-cwd-prefix --exclude .git
#FZF_CTRL_T_COMMAND=fd --hidden --strip-cwd-prefix --exclude .git
#FZF_ALT_C_COMMAND=fd --type=d --hidden --strip-cwd-prefix --exclude .git
#FZF_DEFAULT_OPTS=--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED

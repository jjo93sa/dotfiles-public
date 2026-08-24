{...}: {
  # Install fzf via home-manager module
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}

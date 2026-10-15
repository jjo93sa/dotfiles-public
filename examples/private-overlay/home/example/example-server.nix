{...}: {
  programs.home-manager.enable = true;
  home.stateVersion = "26.05";

  # Add user configuration specific to this NixOS server here.
  programs.zsh.shellAliases.example-host = "hostname";
}

{...}: {
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  # Private aliases, directory hashes, and application settings belong here.
  programs.zsh.shellAliases.example-host = "hostname";
}

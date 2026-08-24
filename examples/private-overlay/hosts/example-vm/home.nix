{...}: {
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  # This profile targets standalone Home Manager on Ubuntu rather than NixOS.
  programs.zsh.shellAliases.example-host = "hostname";
}

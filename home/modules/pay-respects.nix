{...}: {
  # Install pay-respects via home-manager module
  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.shellAliases.fuck = "pay-respects";

  # Store-manage the configuration so it works regardless of where the flake
  # is checked out. Rebuild Home Manager after editing the source directory.
  xdg.configFile = {
    "pay-respects" = {
      source = ../../files/configs/pay-respects;
      recursive = true;
    };
  };
}

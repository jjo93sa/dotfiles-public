{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.default
  ];

  programs.nix-index = {
    enable = true;

    # Let pay-respects remain the command-not-found handler.
    enableZshIntegration = false;
  };

  # Install pay-respects via home-manager module
  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--alias"
      "fuck"
    ];
  };

  # Store-manage the configuration so it works regardless of where the flake
  # is checked out. Rebuild Home Manager after editing the source directory.
  xdg.configFile = {
    "pay-respects" = {
      source = ../../files/configs/pay-respects;
      recursive = true;
    };
  };
}

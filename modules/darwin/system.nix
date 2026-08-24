{
  pkgs,
  outputs,
  userConfig,
  ...
}: {
  # Nix and account plumbing shared by the Darwin hosts that select this
  # capability. This is deliberately named for its concern rather than `base`.
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = userConfig.name;
    autoMigrate = true;
  };

  nixpkgs = {
    overlays = [outputs.overlays.stable-packages];
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = "nix-command flakes";
    optimise.automatic = true;
    package = pkgs.nix;
  };

  users.users.${userConfig.name} = {
    inherit (userConfig) name;
    home = "/Users/${userConfig.name}";
    shell = pkgs.zsh;
  };

  system = {
    primaryUser = userConfig.name;
    # Compatibility version: review the nix-darwin changelog before changing.
    stateVersion = 5;
  };
}

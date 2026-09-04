{
  inputs,
  outputs,
}: {
  darwinModules,
  extraSpecialArgs ? {},
  homeModules,
  hostname,
  system,
  userConfig,
}: let
  specialArgs =
    extraSpecialArgs
    // {
      inherit inputs hostname userConfig;
      inherit outputs;
    };
in {
  darwinConfiguration = inputs.darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwinModules
      ++ [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            overwriteBackup = true;
            extraSpecialArgs = specialArgs;
            users.${userConfig.name}.imports = homeModules;
          };
        }
      ];
  };

  homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [outputs.overlays.stable-packages];
      config.allowUnfree = true;
    };
    extraSpecialArgs = specialArgs;
    modules = homeModules;
  };
}

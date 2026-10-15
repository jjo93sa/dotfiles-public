{
  inputs,
  outputs,
}: {
  extraSpecialArgs ? {},
  homeModules,
  hostname,
  nixosModules,
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
  nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixosModules
      ++ [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
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

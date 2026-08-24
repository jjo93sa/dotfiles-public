{
  inputs,
  outputs,
}: {
  extraSpecialArgs ? {},
  homeModules,
  hostname,
  nixpkgsConfig ? {allowUnfree = true;},
  overlays ? [outputs.overlays.stable-packages],
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
  homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system overlays;
      config = nixpkgsConfig;
    };
    extraSpecialArgs = specialArgs;
    modules = homeModules;
  };
}

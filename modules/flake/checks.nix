{
  inputs,
  self,
  ...
}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      checks = let
        mkModuleEvaluation = name: module: let
          evaluated = inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              module
              {system.stateVersion = "26.05";}
            ];
          };
          packageNames = map lib.getName evaluated.config.environment.systemPackages;
        in
          pkgs.writeText "${name}-${system}.json" (builtins.toJSON packageNames);
      in {
        nixos-baseline-evaluation =
          mkModuleEvaluation "nixos-baseline" self.nixosModules.baseline;
        nixos-development-evaluation =
          mkModuleEvaluation "nixos-development" self.nixosModules.development;
        nixos-ghostty-terminfo-evaluation =
          mkModuleEvaluation "nixos-ghostty-terminfo" self.nixosModules.ghostty-terminfo;
      };
    };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.dotfiles.just;
  moduleDeclarations = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: _: "mod ${name} \"${config.xdg.configHome}/just/modules/${name}.just\""
    )
    cfg.globalModules
  );
in {
  options.dotfiles.just.globalModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = {};
    description = ''
      Named Just modules to expose beneath the global Justfile. A module named
      `work`, for example, is invoked as `jg work <recipe>`.
    '';
  };

  config = {
    xdg.configFile =
      {
        "just/justfile".text = ''
          import "${../../files/configs/just/global.just}"
          ${moduleDeclarations}
        '';
      }
      // lib.mapAttrs' (
        name: source:
          lib.nameValuePair "just/modules/${name}.just" {
            inherit source;
          }
      )
      cfg.globalModules;

    programs.zsh.shellAliases.jg = "just --global-justfile";
  };
}

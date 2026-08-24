{config, lib, pkgs, ...}: {
  options.dotfiles.atuin.sync.enable = lib.mkEnableOption "Atuin history synchronization" // {
    default = true;
  };

  config = {
    # Install atuin via home-manager module
    programs.atuin = {
      enable = true;
      # Atuin 18.18 uses AlertError for the selected history row. Keep red for
      # genuine failures and use the theme's Important accent for selection.
      package = pkgs.atuin.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../../files/patches/atuin-selected-command-color.patch
        ];
      });
      settings = {
        enableZshIntegration = true;
        enter_accept = true;
        # Explicitly disable network synchronization on hosts which opt out.
        auto_sync = config.dotfiles.atuin.sync.enable;
        dialect = "uk";
        inline_height = 25;
        invert = true;
        records = true;
        search_mode = "fuzzy";
        secrets_filter = true;
        style = "compact";
        theme.name = "gruvbox-dark-hard";
      } // lib.optionalAttrs config.dotfiles.atuin.sync.enable {
        sync_frequency = "5m";
        sync_address = "http://100.120.237.8:8888";
      };
      flags = [];
    };

    xdg.configFile."atuin/themes/gruvbox-dark-hard.toml".source =
      ../../files/configs/atuin/themes/gruvbox-dark-hard.toml;
  };
}

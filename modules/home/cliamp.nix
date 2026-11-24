{
  config,
  lib,
  ...
}: let
  cfg = config.dotfiles.cliamp;
in {
  options.dotfiles.cliamp = {
    enable = lib.mkEnableOption "Plex-backed cliamp configuration";

    plexUrl = lib.mkOption {
      type = lib.types.str;
      description = "URL of the Plex server, including its port.";
    };

    plexVault = lib.mkOption {
      type = lib.types.str;
      description = "1Password vault containing the Plex token item.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."cliamp/config.toml" = {
      # cliamp may replace its config when preferences change. Reclaim the
      # path on every activation so Nix remains the sole source of truth.
      force = true;
      text = ''
        provider = "plex"
        visualizer = "ClassicPeak"

        [plex]
        url = "${cfg.plexUrl}"
        token = "$PLEX_TOKEN"
        libraries = ["Music"]
      '';
    };

    # cliamp expands PLEX_TOKEN at runtime. Read it directly from 1Password
    # before execing the TUI, preserving its terminal streams.
    home.file.".local/bin/cliamp" = {
      executable = true;
      text = ''
        #!/bin/sh
        PLEX_TOKEN="$(/opt/homebrew/bin/op read ${lib.escapeShellArg "op://${cfg.plexVault}/Plex token/password"})" || exit 1
        export PLEX_TOKEN
        exec /opt/homebrew/bin/cliamp "$@"
      '';
    };
  };
}

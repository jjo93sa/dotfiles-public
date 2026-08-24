{
  config,
  lib,
  ...
}: {
  xdg.configFile."herdr/config.toml".source = ../../files/configs/herdr/config.toml;

  # Herdr bundles the version-matched Codex hook and installs it idempotently.
  # Running its installer during activation keeps the hook, hooks.json, and
  # Codex feature flag synchronized when either application changes format.
  home.activation.installHerdrCodexIntegration = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ -x /opt/homebrew/bin/herdr && -d ${lib.escapeShellArg "${config.home.homeDirectory}/.codex"} ]]; then
      $DRY_RUN_CMD /opt/homebrew/bin/herdr integration install codex
    fi
  '';
}

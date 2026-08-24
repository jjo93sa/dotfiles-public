{config, ...}:
{
  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    configPath = "${config.xdg.configHome}/starship/starship.toml";
    settings = builtins.fromTOML (builtins.readFile ../../files/configs/starship/starship.toml);
  };

  # Keep the alternate prompt alongside the primary, generated configuration.
  xdg.configFile."starship/starship-compact.toml".source =
    ../../files/configs/starship/starship-compact.toml;
}

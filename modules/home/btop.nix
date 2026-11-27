{...}: {
  # Install btop via home-manager module
  programs.btop = {
    enable = true;
    settings = {
      # This packaged theme uses the same #1d2021 background and canonical
      # accent colours as the rest of the Gruvbox Dark Hard configuration.
      color_theme = "gruvbox_dark";
      vim_keys = true;
    };
  };
}

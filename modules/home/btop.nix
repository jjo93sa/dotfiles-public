{...}: {
  # Install btop via home-manager module
  programs.btop = {
    enable = true;
    settings = {
      # Use btop's more vivid Gruvbox variant: it retains the canonical palette
      # while making selections, meters and graph gradients clearly distinct.
      color_theme = "gruvbox_dark_v2";
      vim_keys = true;
    };
  };
}

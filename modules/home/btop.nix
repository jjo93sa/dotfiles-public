{pkgs, ...}: {
  # Install btop via home-manager module
  programs.btop = {
    enable = true;
    settings = {
      # Use btop's more vivid Gruvbox variant: it retains the canonical palette
      # while making selections, meters and graph gradients clearly distinct.
      color_theme = "gruvbox_dark_v2";
      vim_keys = true;
    };

    # btop discovers packaged themes relative to the executable path. Home
    # Manager exposes btop through a profile symlink, so deploy the selected
    # packaged theme into btop's user theme directory as well.
    themes.gruvbox_dark_v2 =
      builtins.readFile "${pkgs.btop}/share/btop/themes/gruvbox_dark_v2.theme";
  };
}

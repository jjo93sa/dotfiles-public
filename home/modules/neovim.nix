{pkgs, ...}:
{
  # Neovim text editor configuration
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    plugins = with pkgs.vimPlugins; [
      # Use the Nix package so the native generator and its libraries are
      # patched for the Nix store instead of depending on Homebrew libraries.
      codesnap-nvim
    ];
  };

  # Copy the canonical Lua configuration into the Nix store. Unlike an
  # out-of-store symlink, this works regardless of where the flake is cloned.
  # Rebuild Home Manager after editing files/configs/nvim.
  xdg.configFile = {
    "nvim" = {
      source = ../../files/configs/nvim;
      recursive = true;
      # Replace an older, unmanaged copy of this tree with Home Manager's
      # per-file links. The repository remains the canonical source.
      force = true;
    };
  };
}

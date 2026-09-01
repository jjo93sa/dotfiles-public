{
  inputs,
  self,
  ...
}: {
  flake.lib.mkDarwinHost = import ../../lib/mkDarwinHost.nix {
    inherit inputs;
    outputs = self;
  };
  flake.lib.mkHomeHost = import ../../lib/mkHomeHost.nix {
    inherit inputs;
    outputs = self;
  };

  flake.darwinModules = {
    development = ../darwin/development.nix;
    herdr = ../darwin/herdr.nix;
    homebrew = ../darwin/homebrew.nix;
    macos-defaults = ../darwin/macos-defaults.nix;
    system = ../darwin/system.nix;
    tailscale = ../darwin/tailscale.nix;
  };

  flake.homeModules = {
    atuin = ../../home/modules/atuin.nix;
    bat = ../../home/modules/bat.nix;
    btop = ../../home/modules/btop.nix;
    common = ../../home/modules/common.nix;
    development = ../../home/modules/development.nix;
    direnv = ../../home/modules/direnv.nix;
    eza = ../../home/modules/eza.nix;
    fastfetch = ../../home/modules/fastfetch.nix;
    fzf = ../../home/modules/fzf.nix;
    ghostty = ../../home/modules/ghostty.nix;
    git = ../../home/modules/git.nix;
    herdr = ../../home/modules/herdr.nix;
    home = ../../home/modules/home.nix;
    krew = ../../home/modules/krew.nix;
    lazygit = ../../home/modules/lazygit.nix;
    neovim = ../../home/modules/neovim.nix;
    onePassword = ../../home/modules/onePassword.nix;
    pay-respects = ../../home/modules/pay-respects.nix;
    scripts = ../../home/modules/scripts.nix;
    starship = ../../home/modules/starship.nix;
    tmux = ../../home/modules/tmux.nix;
    yamllint = ../../home/modules/yamllint.nix;
    zoxide = ../../home/modules/zoxide.nix;
    zsh = ../../home/modules/zsh.nix;
  };
}

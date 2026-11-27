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
  flake.lib.mkLinuxHost = import ../../lib/mkLinuxHost.nix {
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
    atuin = ../home/atuin.nix;
    bat = ../home/bat.nix;
    btop = ../home/btop.nix;
    cliamp = ../home/cliamp.nix;
    common = ../home/common.nix;
    development = ../home/development.nix;
    direnv = ../home/direnv.nix;
    eza = ../home/eza.nix;
    fastfetch = ../home/fastfetch.nix;
    fzf = ../home/fzf.nix;
    ghostty = ../home/ghostty.nix;
    git = ../home/git.nix;
    herdr = ../home/herdr.nix;
    home = ../home/home.nix;
    just = ../home/just.nix;
    krew = ../home/krew.nix;
    lazygit = ../home/lazygit.nix;
    neovim = ../home/neovim.nix;
    onePassword = ../home/onePassword.nix;
    pay-respects = ../home/pay-respects.nix;
    scripts = ../home/scripts.nix;
    starship = ../home/starship.nix;
    yamllint = ../home/yamllint.nix;
    zoxide = ../home/zoxide.nix;
    zsh = ../home/zsh.nix;
  };

  flake.nixosModules = {
    baseline = ../nixos/baseline.nix;
    development = ../nixos/development.nix;
    ghostty-terminfo = ../nixos/ghostty-terminfo.nix;
  };
}

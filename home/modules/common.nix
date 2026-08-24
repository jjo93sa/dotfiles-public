{outputs, ...}: {
  imports = [
    #../modules/atuin.nix
    ../modules/onePassword.nix
    ../modules/bat.nix
    ../modules/btop.nix
    ../modules/development.nix
    ../modules/fastfetch.nix
    ../modules/eza.nix
    ../modules/fzf.nix
    ../modules/ghostty.nix
    ../modules/git.nix
    ../modules/home.nix
    ../modules/lazygit.nix
    ../modules/neovim.nix
    #../modules/scripts.nix
    ../modules/starship.nix
    ../modules/tmux.nix
    ../modules/yamllint.nix
    ../modules/zoxide.nix
    ../modules/zsh.nix
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };
}

{outputs, ...}: {
  imports = [
    # ./atuin.nix
    ./onePassword.nix
    ./bat.nix
    ./btop.nix
    ./development.nix
    ./direnv.nix
    ./fastfetch.nix
    ./eza.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./home.nix
    ./just.nix
    ./lazygit.nix
    ./neovim.nix
    # ./scripts.nix
    ./starship.nix
    ./yamllint.nix
    ./zoxide.nix
    ./zsh.nix
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

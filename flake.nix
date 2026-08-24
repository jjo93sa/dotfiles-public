{
  description = "Reusable nix-darwin and Home Manager modules";

  # flake.nix only declares dependencies and hands control to flake-parts.
  # Configuration lives in modules/flake, where every file is an ordinary
  # flake-parts module that can contribute outputs without editing this file.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # This is the only import root. The imported modules compose the flake.
      imports = [./modules/flake];

      # perSystem outputs (packages, checks, dev shells, and formatters) are
      # generated for all common Linux and macOS CPU architectures.
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}

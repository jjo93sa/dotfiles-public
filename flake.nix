{
  description = "Reusable nix-darwin and Home Manager modules";

  # flake.nix only declares dependencies and hands control to flake-parts.
  # Configuration lives in modules/flake, where every file is an ordinary
  # flake-parts module that can contribute outputs without editing this file.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

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

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Recursively discover the flake-parts modules. Adding a module beneath
      # modules/flake does not require maintaining a separate import index.
      imports = [(import-tree ./modules/flake)];

      # Generate per-system outputs for Apple Silicon macOS and the Linux
      # architectures used by development VMs.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}

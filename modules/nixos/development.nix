{pkgs, ...}: {
  imports = [./baseline.nix];

  # Small, non-opinionated command-line layer for disposable development
  # guests. User dotfiles and interactive shell policy remain Home Manager's
  # responsibility.
  environment.systemPackages = with pkgs; [
    fastfetch
    jq
    just
    ripgrep
  ];
}

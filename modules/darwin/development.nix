{pkgs, ...}: {
  # Darwin system integration for development hosts. Cross-platform command-
  # line tools are owned by Home Manager in home/modules/development.nix.
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    roboto
  ];
}

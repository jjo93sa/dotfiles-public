{...}: {
  # Herdr has no native nix-darwin module. Its official Homebrew formula ships
  # bottled macOS binaries, so this tiny module expresses the installation as
  # declarative nix-darwin state. `nix-homebrew` supplies/manages Homebrew.
  homebrew.brews = ["herdr"];
}

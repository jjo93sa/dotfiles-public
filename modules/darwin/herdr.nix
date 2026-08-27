{...}: {
  # Herdr has no native nix-darwin module. Its official Homebrew formula ships
  # bottled macOS binaries, so this tiny module expresses the installation as
  # declarative nix-darwin state. Cliamp's upstream Nix package is Linux-only,
  # so use its supported macOS Homebrew formula and codec dependencies.
  # `nix-homebrew` supplies/manages Homebrew.
  homebrew = {
    taps = ["bjarneo/cliamp"];
    brews = [
      "herdr"
      "bjarneo/cliamp/cliamp"
    ];
  };
}

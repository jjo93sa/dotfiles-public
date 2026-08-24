{...}: {
  # Shared graphical applications installed through Homebrew casks.
  homebrew = {
    enable = true;
    casks = [
      "1password-cli"
      "ghostty"
      "raycast"
    ];
  };
}

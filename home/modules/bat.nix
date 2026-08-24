{...}: {
  # Install bat via home-manager module
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
    };
  };
}

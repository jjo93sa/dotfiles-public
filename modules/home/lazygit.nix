{...}: {
  # Install lazygit via home-manager module
  programs.lazygit = {
    enable = true;

    settings = {
      git = {
        diffRenderers = [
          {
            type = "stdinFilter";
            name = "delta";
            colorArg = "always";
            command = "delta --color-only --dark --paging=never";
          }
        ];
      };
    };
  };
}

{userConfig, ...}: {
  # Install git via home-manager module
  programs.git = {
    enable = true;
    #signing = {
    #  key = userConfig.gitKey;
    #  signByDefault = true;
    #};
    settings = {
      user = {
        name = userConfig.fullName;
        email = userConfig.email;
      };

      # Preserve useful behavior from the pre-Home Manager ~/.gitconfig.
      status.submoduleSummary = true;
      pull.rebase = true;
      core.editor = "nvim";
      pager.branch = "cat";
      alias = {
        cd = "!cd `git rev-parse --show-toplevel`";
        root = "!pwd";
      };
    };
  };

  # Delta is Git's syntax-highlighting pager. Home Manager now manages it as a
  # standalone program and wires it into Git explicitly.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };
}

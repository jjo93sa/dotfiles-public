{
  lib,
  pkgs,
  ... }: {
  # home.packages = with pkgs; [
  #   ghostty
  # ];
  # # Install ghostty via home-manager module
  programs.ghostty = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    package = null;
    enable = true;
    enableZshIntegration = true;
    #installBatSyntax = true;
    settings = {
      copy-on-select = "clipboard";
      # Alternative: "Berkeley Mono".
      font-family = "PragmataPro Mono Regular";
      # This installation only exposes the regular face, so Ghostty otherwise
      # synthesizes a noticeably heavy bold weight for terminal applications.
      font-style-bold = false;
      font-style-bold-italic = false;
      font-size = 16;
      # font-thicken = true;
      keybind = [
        "global:cmd+grave_accent=toggle_quick_terminal"
        "global:alt+b=esc:b"
        "global:alt+f=esc:f"
      ];
      # Alternative: "gruvbox-material".
      theme = "Gruvbox Dark Hard";
    };
  };
}

{pkgs, ...}: {
  # Let remote shells and full-screen applications understand TERM=xterm-ghostty
  # without depending on any user's Home Manager profile.
  environment.systemPackages = [pkgs.ghostty.terminfo];
}

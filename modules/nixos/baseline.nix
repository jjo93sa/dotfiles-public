{pkgs, ...}: {
  # Machine-owned tools expected to be available when administering or
  # recovering a NixOS host, independently of any user's Home Manager profile.
  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    unzip
  ];
}

{
  inputs,
  pkgs,
  ...
}: let
  masterPkgs = import inputs.nixpkgs-master {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in {
  # Run the CLI-based macOS client on every Mac. Authentication remains local
  # to each machine and is established once with `sudo tailscale up`.
  services.tailscale = {
    enable = true;
    # 1.102.3 contains TS-2026-011 and has not yet reached nixos-unstable.
    package = masterPkgs.tailscale;
  };
}

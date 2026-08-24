{inputs, ...}: {
  # `flake.overlays` becomes the public `overlays` output. Hosts and standalone
  # Home Manager configurations can both consume this same overlay.
  flake.overlays.stable-packages = final: _prev: {
    # Packages from nixpkgs-stable are available as `pkgs.stable.<package>`.
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}

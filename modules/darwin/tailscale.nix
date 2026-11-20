{
  config,
  lib,
  ...
}: let
  cfg = config.dotfiles.tailscale;
in {
  options.dotfiles.tailscale.variant = lib.mkOption {
    type = lib.types.enum [
      "none"
      "cli"
      "gui"
    ];
    default = "none";
    description = ''
      Tailscale client variant to install. The CLI variant runs the open-source
      tailscaled service; the GUI variant installs Tailscale's standalone macOS
      application through Homebrew.
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.variant == "cli") {
      # Authentication remains local to each machine and is established once
      # with `sudo tailscale up`.
      services.tailscale.enable = true;
    })

    (lib.mkIf (cfg.variant == "gui") {
      # Install Tailscale's recommended standalone macOS application. It uses
      # a system extension and retains its built-in automatic updater.
      homebrew.casks = ["tailscale-app"];
    })
  ];
}

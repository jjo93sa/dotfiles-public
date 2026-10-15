{
  hostname,
  userConfig,
  ...
}: {
  networking.hostName = hostname;

  # Replace these synthetic disk assumptions with the target's hardware or
  # Disko configuration before installation.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub = {
    enable = true;
    devices = ["/dev/sda"];
  };

  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = ["wheel"];
  };

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "26.05";
}

{
  description = "Example private host overlay for the public dotfiles flake";

  # Replace this with the URL of your public dotfiles repository.
  # For example: github:your-user/dotfiles
  inputs.dotfiles.url = "github:example/dotfiles";

  outputs = inputs @ {dotfiles, ...}: let
    exampleUser = {
      name = "example";
      fullName = "Example User";
      email = "example@example.invalid";
    };

    exampleMac = dotfiles.lib.mkDarwinHost {
      hostname = "example-mac";
      system = "aarch64-darwin";
      userConfig = exampleUser;
      extraSpecialArgs.privateInputs = inputs;
      darwinModules = [
        dotfiles.darwinModules.system
        dotfiles.darwinModules.macos-defaults
        dotfiles.darwinModules.development
        dotfiles.darwinModules.homebrew
        ./hosts/example-mac/configuration.nix
      ];
      homeModules = [
        dotfiles.homeModules.common
        dotfiles.homeModules.pay-respects
        dotfiles.homeModules.atuin
        ./home/example/example-mac.nix
      ];
    };

    exampleVm = dotfiles.lib.mkHomeHost {
      hostname = "example-vm";
      system = "aarch64-linux";
      userConfig = exampleUser;
      extraSpecialArgs.privateInputs = inputs;
      homeModules = [
        dotfiles.homeModules.common
        dotfiles.homeModules.pay-respects
        dotfiles.homeModules.atuin
        ./home/example/example-vm.nix
      ];
    };

    exampleServer = dotfiles.lib.mkLinuxHost {
      hostname = "example-server";
      system = "x86_64-linux";
      userConfig = exampleUser;
      extraSpecialArgs.privateInputs = inputs;
      nixosModules = [./hosts/example-server/configuration.nix];
      homeModules = [
        dotfiles.homeModules.common
        dotfiles.homeModules.pay-respects
        dotfiles.homeModules.atuin
        ./home/example/example-server.nix
      ];
    };
  in {
    darwinConfigurations.example-mac = exampleMac.darwinConfiguration;
    nixosConfigurations.example-server = exampleServer.nixosConfiguration;
    homeConfigurations = {
      "example@example-mac" = exampleMac.homeConfiguration;
      "example@example-server" = exampleServer.homeConfiguration;
      "example@example-vm" = exampleVm.homeConfiguration;
    };
  };
}

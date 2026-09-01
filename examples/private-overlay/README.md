# Private host overlay

This directory is a copyable starting point for a private flake that consumes
the reusable constructors and modules from the public dotfiles repository. It
contains synthetic Darwin and Ubuntu hosts; no real hostname, account, secret,
or organization-specific value is required in the public repository.

## Create the private repository

1. Create an empty private Git repository and clone it locally.
2. Copy the contents of `examples/private-overlay/` into its root. Do not copy
   the `private-overlay` directory itself:

   ```sh
   cp -R /path/to/public-dotfiles/examples/private-overlay/. /path/to/private-dotfiles/
   cd /path/to/private-dotfiles
   ```

3. In `flake.nix`, replace `github:example/dotfiles` with the URL of the public
   repository, such as `github:your-user/dotfiles`.
4. Replace the synthetic identity, hostnames, systems, and local module names.
   One private flake may define any number of Darwin and Linux hosts.
5. Add private modules under `hosts/<hostname>/`. These may add to, override,
   or omit the public modules selected in `flake.nix`.
6. Pin the public repository and all of its transitive inputs, then commit the
   resulting lock file:

   ```sh
   nix flake lock
   git add flake.nix flake.lock hosts
   ```

Keep credentials and private keys out of the Nix source even though the
repository is private. Refer to an external secret manager or encrypted secret
material instead; evaluated Nix values and build inputs can be copied into the
world-readable Nix store.

## Evaluate before activating

List the private flake's outputs:

```sh
nix flake show
```

Evaluate the complete Darwin system without switching to it:

```sh
nix eval --raw .#darwinConfigurations.example-mac.system
```

Evaluate the standalone Home Manager profile used by the Ubuntu VM:

```sh
nix eval --raw '.#homeConfigurations.example@example-vm.activationPackage.drvPath'
```

## Activate a host

For the first activation, before `darwin-rebuild` and `nh` are installed:

```sh
sudo nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- \
  switch --flake .#example-mac
```

On a Darwin machine already using nix-darwin, either use the traditional
command:

```sh
sudo darwin-rebuild switch --flake .#example-mac
```

or the equivalent `nh` command:

```sh
nh darwin switch .#example-mac
```

On an Ubuntu VM, after installing Nix with flakes enabled, activate the
standalone Home Manager profile directly from the flake:

```sh
nix run github:nix-community/home-manager -- switch \
  --flake '.#example@example-vm'
```

The Ubuntu example manages the user's packages and home environment; it does
not turn Ubuntu into NixOS or manage the operating system itself. An automated
bootstrap can install Nix, clone the private repository, and run that Home
Manager command—for example from Ansible's final-boot hook.

## Test this template while developing the public repository

The checked-in example points at a deliberately inert placeholder URL. From
the public repository root, override that input with the current checkout:

```sh
nix eval --no-write-lock-file --override-input dotfiles path:. --raw \
  path:./examples/private-overlay#darwinConfigurations.example-mac.system

nix eval --no-write-lock-file --override-input dotfiles path:. --raw \
  'path:./examples/private-overlay#homeConfigurations.example@example-vm.activationPackage.drvPath'
```

# Backlog

This file tracks outstanding work owned by the public flake. Host-specific
tasks belong in the corresponding private repository.

## CI/CD and repository tooling

- Run formatting checks and `nix flake check --all-systems` for commits and
  pull requests.
- Add synthetic Darwin and Home Manager configurations to `checks` so exported
  modules are evaluated without publishing private host data.
- Add checking recipes to `examples/private-overlay`, keeping their names and
  behaviour consistent with the private repositories where practical.
- Add a scheduled or manually dispatched workflow that updates flake inputs on
  a branch and subjects the lock-file change to the same checks.

## Shared configuration

- Expose a small reusable NixOS development module and then separate portable
  configuration from platform-specific integration:
  - Start with `nixosModules.development`, containing a deliberately small set
    of command-line packages that are useful in a disposable development VM
    (for example `git`, `jq`, `just`, `ripgrep`, and `fastfetch`). Keep this
    first module independent of Home Manager so a minimal NixOS guest can
    import it directly.
  - Import that module into the work-private `microvm-dev` configuration and
    use `fastfetch` plus one or two development commands as the visible proof
    that functionality supplied by the public flake is present in the guest.
  - Inventory the relocated `modules/home/development.nix` and classify each
    package as cross-platform, interactive-user configuration, Darwin-only,
    or Linux/NixOS-only. Do not silently remove packages from existing Macs
    while moving ownership.
  - Extract shared package lists or narrowly focused modules instead of making
    a single module work by accumulating platform conditionals. Keep system
    services, fonts, Homebrew, macOS defaults, and other Darwin integration in
    `darwinModules`; keep per-user dotfiles and shell configuration in
    `homeModules`; keep Linux system policy in `nixosModules`.
  - Decide whether longer-lived Linux hosts and VMs should consume the shared
    user environment through Home Manager. If so, add it separately from the
    minimal NixOS module so disposable guests are not forced to adopt it.
  - Export the new modules from `modules/flake/lib.nix`, document the three
    module families and their intended consumers, and add evaluation checks
    for both `aarch64-linux` and `x86_64-linux` where the package set permits.
  - After consumers have migrated, remove duplicated package declarations and
    verify the Darwin hosts, existing Linux hosts, and MicroVM independently.
- Investigate replacing the Homebrew `1password-cli` package with nixpkgs and
  whether the macOS 1Password GUI from nixpkgs preserves the required browser,
  SSH-agent, biometric, update, and code-signing behaviour. Make this usable by
  private overlays without forcing the same choice on every host.

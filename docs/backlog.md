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

- Investigate replacing the Homebrew `1password-cli` package with nixpkgs and
  whether the macOS 1Password GUI from nixpkgs preserves the required browser,
  SSH-agent, biometric, update, and code-signing behaviour. Make this usable by
  private overlays without forcing the same choice on every host.

## Temporary pins

- Remove the `nixpkgs-master` Tailscale override once the regular nixpkgs input
  provides Tailscale 1.102.3 or newer. When recorded, regular nixpkgs provided
  1.102.2 and master provided 1.102.3, so the override was still required.

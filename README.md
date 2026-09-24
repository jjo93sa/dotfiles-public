# Public dotfiles modules

This flake provides reusable nix-darwin and Home Manager constructors, modules,
and application configuration. It deliberately contains no real hosts, user
identities, credentials, private keys, or organization-specific configuration.

The intended entry point is a separate private flake. Copy
[`examples/private-overlay`](examples/private-overlay), replace its synthetic
identity and hosts, and point its `dotfiles` input at this repository.

## Public outputs

- `lib.mkDarwinHost` constructs a nix-darwin system and matching standalone
  Home Manager profile.
- `lib.mkHomeHost` constructs a standalone Home Manager profile for Linux or
  Darwin.
- `darwinModules` exposes reusable machine-wide macOS capabilities.
- `homeModules` exposes reusable user-level capabilities.

See [`examples/private-overlay/README.md`](examples/private-overlay/README.md)
for setup, evaluation, and activation commands.

See [`docs/maintenance-guide.md`](docs/maintenance-guide.md) for the repository
structure, module evaluation flow, update workflow, and debugging commands.
Outstanding work is tracked in [`docs/backlog.md`](docs/backlog.md).

## Git hooks

Enable the repository-managed hooks once per clone:

```sh
git config --local core.hooksPath .githooks
```

The pre-commit hook runs `git diff --cached --check` against staged changes.

## Neovim plugin updates

Most Neovim plugins are managed by Lazy and pinned in
`files/configs/nvim/lazy-lock.json`. The active configuration is linked through
the Nix store, so update plugins from the mutable repository checkout instead:

```sh
just update-nvim-plugins
```

Review and test the resulting lock-file diff before committing it and updating
the public flake input in consuming repositories.

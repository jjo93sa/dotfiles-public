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

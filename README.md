# Public dotfiles modules

This flake provides reusable nix-darwin and Home Manager constructors, modules,
and application configuration. It deliberately contains no real hosts, user
identities, credentials, private keys, or organization-specific configuration.

The intended entry point is a separate private flake. Copy
[`examples/private-overlay`](examples/private-overlay), replace its synthetic
identity and hosts, and point its `dotfiles` input at this repository.

## Set up a new Mac

Install Apple's Command Line Tools before cloning a repository. On a fresh Mac,
the system `git` command may prompt for them; you can start the installation
explicitly and then verify Git works:

```sh
xcode-select --install
git --version
```

If Command Line Tools are already installed, `xcode-select --install` will say
so. Complete any installer dialog before continuing.

If Just is already available, install Nix with flakes enabled by running:

```sh
just install-nix
```

On a fresh machine without Just, invoke the official NixOS community installer
directly:

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer |
  sh -s -- install --enable-flakes
```

Start a new login shell after installation, then clone the appropriate private
flake and follow its first-activation instructions. Just and the rest of the
development toolset become Nix-managed after that activation.

Ghostty is configured to use the licensed PragmataPro Mono Regular font, but
this flake does not install it. Install your licensed copy in macOS before
expecting Ghostty to render with that face; until then, Ghostty may use a
fallback font. The flake does install JetBrains Mono and Meslo Nerd Fonts.

## Public outputs

- `lib.mkDarwinHost` constructs a nix-darwin system and matching standalone
  Home Manager profile.
- `lib.mkLinuxHost` constructs a NixOS system with an integrated Home Manager
  profile, plus a matching standalone Home Manager profile.
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

Install the pre-commit framework hook once per clone, after activating the Nix
configuration (which supplies `just` and `pre-commit`):

```sh
just hooks-install
```

The recipe removes the old `.githooks` override if present, then installs the
hook in Git's standard `.git/hooks` directory. It leaves unrelated custom hook
paths alone. The pre-commit hook runs `git diff --cached --check` against staged
changes.

## Repository checks

The root Justfile provides the routine validation commands:

```sh
just check              # Evaluate without building.
just check-all-systems  # Evaluate every supported system without building.
just format-check       # Check Nix formatting without rewriting files.
just test               # Build checks supported by this machine.
```

These recipes use `path:.` so that evaluation includes the complete working
tree, including new files that have not yet been added to Git.

## Neovim plugin updates

Most Neovim plugins are managed by Lazy and pinned in
`files/configs/nvim/lazy-lock.json`. The active configuration is linked through
the Nix store, so update plugins from the mutable repository checkout instead:

```sh
just update-nvim-plugins
```

Review and test the resulting lock-file diff before committing it and updating
the public flake input in consuming repositories.

See [`docs/neovim-treesitter.md`](docs/neovim-treesitter.md) for the configured
language support and practical syntax-aware editing shortcuts.

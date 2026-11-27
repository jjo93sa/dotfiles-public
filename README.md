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

Ghostty is configured to use the licensed PragmataPro Mono family (its Regular
face), but this flake does not install it. Install your licensed copy in macOS
before expecting Ghostty to render with that face; until then, Ghostty may use
a fallback font. The flake does install JetBrains Mono and Meslo Nerd Fonts.

## Public outputs

- `lib.mkDarwinHost` constructs a nix-darwin system and matching standalone
  Home Manager profile.
- `lib.mkLinuxHost` constructs a NixOS system with an integrated Home Manager
  profile, plus a matching standalone Home Manager profile.
- `lib.mkHomeHost` constructs a standalone Home Manager profile for Linux or
  Darwin.
- `darwinModules` exposes reusable machine-wide macOS capabilities.
- `homeModules` exposes reusable user-level capabilities.
- `nixosModules` exposes reusable machine-wide Linux capabilities.

The exported NixOS modules deliberately separate a host's minimum operational
tooling from development conveniences:

- `nixosModules.baseline` supplies `curl`, Git, Nano and Unzip for machine
  administration and recovery, independently of any user's Home Manager
  profile.
- `nixosModules.development` imports that baseline and adds a small,
  non-opinionated set of guest-development tools: Fastfetch, Jq, Just and
  Ripgrep. It does not impose user dotfiles or interactive shell policy.

Private NixOS hosts should import only the capability they need. A disposable
development VM can use `development`; a longer-lived server can use `baseline`
without acquiring the additional development environment.

See [`examples/private-overlay/README.md`](examples/private-overlay/README.md)
for setup, evaluation, and activation commands.

See [`docs/maintenance-guide.md`](docs/maintenance-guide.md) for the repository
structure, module evaluation flow, update workflow, and debugging commands.
Outstanding work is tracked in [`docs/backlog.md`](docs/backlog.md).

## Where packages belong

Both nix-darwin/NixOS and Home Manager use Nix and share `/nix/store`; choosing
Home Manager does not create a second package store or duplicate an identical
package. The choice is about ownership and lifecycle, not the number of users:

> Install a package at the layer that owns the reason it exists.

- The system configuration owns packages needed to provide, operate,
  administer, or recover the machine's declared capabilities.
- Home Manager owns packages selected for an individual user's interactive
  environment and workflow.
- A service or program module should own its package through its `package`
  option where one is available.
- Intentional overlap is safe, but should be documented when the system and a
  user genuinely require the same package for different reasons.

See [Where a change belongs](docs/maintenance-guide.md#where-a-change-belongs)
for the complete decision test and examples. The current classification and
follow-up actions are recorded in the
[package ownership audit](docs/package-ownership-audit.md).

## Package sources and profiles

The flake uses several independently locked nixpkgs inputs. They express a
package-selection policy rather than combining every package into one moving
package set:

- `nixpkgs` follows `nixos-unstable` and supplies the normal `pkgs` used by
  modules and hosts.
- `nixpkgs-stable` follows the current stable release and is exposed as
  `pkgs.stable` for packages that deliberately need the slower-moving branch.
- `nixpkgs-ghostty` follows `nixos-unstable` independently so Ghostty can be
  updated without changing the default package set for every host package.

The rough promotion path is `master` to `nixos-unstable` to a stable release
branch, although stable branches receive selected backports rather than every
new package. This flake does not normally track `master`; it uses the regular
`nixos-unstable` input once a package reaches that branch. Each input is pinned
to an exact revision in `flake.lock`, so an activated system does not update
until its lock is changed. For example, update only the normal package set
with:

```sh
nix flake update nixpkgs
```

The package channels offered by [NixOS package search](https://search.nixos.org/packages)
correspond to release or unstable branches, not necessarily the raw nixpkgs
`master` branch. A newly added package can therefore exist upstream before it
appears in an unstable or stable package search. A temporary input can bridge
that gap for an urgent package, but should be removed once the package reaches
the normal `nixpkgs` input.

Nix also supports commands that operate outside these declarative host and
Home Manager configurations. Tailcat provides a useful example:

```sh
nix run nixpkgs#tailcat
```

`nix run` resolves and builds the package, stores the result in `/nix/store`,
and executes it directly. It does not add `tailcat` to `PATH`; another run can
reuse the store result until it is garbage-collected.

```sh
nix profile install nixpkgs#tailcat
nix profile list
```

`nix profile install` instead records the package in the default imperative
user profile, makes its executable available on `PATH`, and keeps its store
paths alive. A nix-darwin or Home Manager activation does not normally remove
it because those systems manage their own profiles and generations. Likewise,
an empty `nix profile list` only means that this imperative user profile has no
installed packages; it does not identify which system or Home Manager flake is
active. Remove the example installation with:

```sh
nix profile remove tailcat
```

Imperative profiles are useful for experiments, but they are machine-local
state. Add a package to the appropriate Nix module when it should be installed
reproducibly on every matching host.

## Global Just recipes

Home Manager installs a global Justfile at `~/.config/just/justfile` and the
following shell alias:

```sh
jg='just --global-justfile'
```

Use ordinary `just` for the project-local Justfile discovered from the current
directory. Use `jg` for commands that should be available independently of the
current repository:

```sh
jg --list
jg tailcat --help
jg herdr-refresh-ssh-agent
jg atuin-backup
```

The hierarchy deliberately has three layers:

1. `files/configs/just/global.just` in this public flake contains reusable,
   non-private recipes such as `tailcat` and the Nix garbage-collection tools.
2. Private Home Manager configurations extend the global file through
   `dotfiles.just.globalModules`. Each attribute becomes a Just module and a
   command namespace; a module named `work`, for example, is invoked with
   `jg work <recipe>`.
3. Repository and project Justfiles remain local. Recipes whose behaviour
   depends on a particular checkout should stay there. A global or private
   module can provide a small dispatcher when a global entry point is useful.

For example, a private flake can add a namespaced module without changing the
public global file:

```nix
dotfiles.just.globalModules.work = ../../files/just/work.just;
```

The supplied `tailcat` recipe uses the package from the `nixpkgs` flake
registry and forwards all arguments unchanged:

```sh
jg tailcat [TAILCAT OPTIONS]
```

It uses `nix run`, so Tailcat is not added to an imperative profile. The recipe
also has Just's `no-cd` attribute, which means relative file arguments are
resolved from the directory in which `jg` was invoked.

If Herdr starts after a reboot or crash before 1Password has created its SSH
agent socket, restored panes can retain Herdr's unavailable-agent link even
after 1Password starts. Once the 1Password SSH agent is running, repair the
shared link for all affected panes with:

```sh
jg herdr-refresh-ssh-agent
```

The recipe verifies that the 1Password path is a live Unix socket, refuses to
replace a non-symlink at Herdr's agent path, retargets
`~/.config/herdr/herdr.sock.agent`, and finishes by listing the available SSH
keys. It does not need to change `SSH_AUTH_SOCK` in each pane because Herdr
already points those panes at its shared link.

### Atuin client backups and migration

Create a consistent backup of the complete local Atuin client data with:

```sh
jg atuin-backup
```

By default, archives are written beneath
`${XDG_STATE_HOME:-$HOME/.local/state}/atuin/backups`. An alternative directory
can be supplied as the recipe's first argument. The recipe snapshots every
SQLite database with SQLite's online-backup operation and includes the Atuin
encryption key and other client state. It deliberately excludes transient WAL
and SHM files. Backup archives have mode `0600`; because they contain the key,
handle them with the same care as an SSH private key.

To migrate or recover a client, copy an archive to the target machine and run:

```sh
jg atuin-restore /path/to/atuin-client-TIMESTAMP.tar.gz \
  restore-atuin-client-data
```

The explicit final argument guards against an accidental restore. The recipe
validates the archive and its databases before making changes, stops and later
restarts the Atuin daemon if it was running, and moves the current data
directory to a timestamped `pre-restore` path rather than deleting it. Open a
new shell and run `atuin doctor` before removing that safety copy.

This is an Atuin-to-Atuin backup and restore. `atuin import` serves a different
purpose: importing history from shells and other history tools, with less
metadata than a native Atuin backup preserves.

Prefer the same Atuin version on the source and target. When moving data from
an older client, first create a pre-upgrade archive with the source's current
version. Then update Atuin on the source, open a new shell, run `atuin doctor`,
and confirm that the old history remains searchable. Create a second archive
after that successful migration and restore that archive on the target. The
restore recipe prints the archive's recorded Atuin version and the installed
version, and warns if they differ.

For example, before activating a configuration that updates the source Mac,
the newly pulled recipe can be run directly from the public checkout:

```sh
just --justfile files/configs/just/global.just atuin-backup
```

After activation and verification, use `jg atuin-backup` to create the archive
that will be transferred.

Restoring replaces the active client data, so use a native merge when the
target already has history that must also be retained:

```sh
jg atuin-merge /path/to/atuin-client-TIMESTAMP.tar.gz \
  merge-atuin-client-data
```

The merge source may instead be an Atuin data directory, including the
timestamped `pre-restore` directory retained by `atuin-restore`. The recipe
validates both databases and requires matching history schemas. It creates a
fresh backup of the active client, inserts only history UUIDs that are missing,
and runs Atuin's idempotent `history init-store` operation to encode those
entries into the active encrypted record store. It then verifies both SQLite
and record-store integrity. This preserves native Atuin metadata including
timestamps, directories, durations, exit statuses, sessions, hosts and UUIDs.

Use `atuin import` only when the source is a shell or another history tool. It
cannot preserve all of this Atuin-specific metadata.

## Generations and garbage collection

Nix profiles retain generations so that an earlier configuration can be used
for rollback. On a nix-darwin Mac, list the system generations with:

```sh
sudo darwin-rebuild --list-generations
```

The same information is available from the underlying profile:

```sh
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
```

Home Manager is integrated into nix-darwin in these host constructors. Its
configuration is therefore part of the corresponding system generation; it
does not create a separate Home Manager generation, and the `home-manager`
command need not be installed. A separately activated standalone Home Manager
configuration would instead have its own profile, commonly inspectable with:

```sh
nix profile history --profile ~/.local/state/nix/profiles/home-manager
```

The default imperative user profile is independent again. Inspect its history
with `nix profile history`; an empty `nix profile list` does not imply that the
system has no nix-darwin generations.

Store paths reachable from any garbage-collection root—including retained
system generations and imperative profiles—are live and cannot be collected.
An uninstalled `nix run` result normally becomes eligible for collection once
the command exits, but remains in `/nix/store` until collection runs.

Inspect the registered roots on a multi-user macOS installation with:

```sh
sudo nix-store --gc --print-roots
```

Given a particular `/nix/store/...` path, show which roots keep it live and
inspect its complete runtime closure with:

```sh
nix-store --query --roots /nix/store/…
nix-store --query --requisites /nix/store/…
```

The first command can produce no output when the path is retained only
indirectly through another store object. The requisites command follows the
opposite direction: it shows everything the selected path needs. GC decides
liveness by starting at every root and following this reference graph.

Darwin hosts run automatic garbage collection at 03:00 each Sunday, deleting
profile generations older than 30 days and then collecting paths no longer
reachable from a root. The current generation is retained. Removing an old
generation also removes the ability to roll back to it.

The global Justfile also offers an explicit, more conservative pair of tools:

```sh
jg nix-gc-inspect  # Show unreachable paths; make no changes.
jg nix-gc          # Confirm, then delete currently unreachable paths.
```

Both use `sudo` on the multi-user macOS installation. The execution recipe
does not delete generations; it only collects paths that are already
unreachable. Automatic store optimisation is configured separately and
deduplicates identical store contents rather than deciding what is live.

## Git hooks

Install the pre-commit framework hook once per clone, after activating the Nix
configuration (which supplies `just` and `pre-commit`):

```sh
just hooks-install
```

The recipe removes the old `.githooks` override if present, then installs the
hook in Git's standard `.git/hooks` directory. It leaves unrelated custom hook
paths alone. The pre-commit hooks check staged whitespace and run
`just format-check` across the repository.

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

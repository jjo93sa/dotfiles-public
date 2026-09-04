# Public dotfiles maintenance guide

This repository is a library of reusable Nix modules rather than a deployable
host configuration. A separate private flake supplies identities and hosts,
selects the public capabilities it wants, and owns the lock file used for
activation. The synthetic overlay in [`../examples/private-overlay`](../examples/private-overlay)
provides copyable Darwin and Linux examples.

## Repository structure

```text
flake.nix
  Declares inputs and passes evaluation to flake-parts.

modules/flake/
  Builds the public outputs: constructors, module sets, overlays, and the
  per-system formatter.

modules/darwin/
  Reusable machine-wide nix-darwin capabilities.

home/modules/
  Reusable user-level Home Manager capabilities.

files/
  Configuration payloads consumed by the public modules.

examples/private-overlay/
  Synthetic, copyable private-flake entry point and host compositions.
```

Private overlays follow a scope-based layout: machine-wide nix-darwin modules
live at `hosts/<hostname>/configuration.nix`, while user-level Home Manager
modules live at `home/<username>/<hostname>.nix`. Private modules reused by
multiple hosts belong under `modules/`, and their payloads belong under
`files/`. The example overlay includes Just recipes for scaffolding these
paths.

`import-tree` recursively discovers the flake-parts modules beneath
`modules/flake`, so adding a module there does not require maintaining an
import index.
Those modules contribute attributes to the same final output set; their file
boundaries do not create separate flakes.

## From entry point to configured host

Evaluation flows through the repositories as follows:

```text
private flake.nix
  |
  +-- pinned dotfiles-public input
  |
  +-- dotfiles.lib.mkDarwinHost or mkHomeHost
        |
        +-- private identity, hostname, platform, and special arguments
        +-- selected public modules
        +-- private host modules and overrides
        `-- final nix-darwin and/or Home Manager configuration
```

`mkDarwinHost` returns both a nix-darwin configuration and a standalone Home
Manager configuration. `mkHomeHost` returns a standalone Home Manager
configuration, suitable for a user environment on an existing Linux system
such as Ubuntu. The Linux constructor does not turn that system into NixOS.

Every module participating in one evaluation receives the standard module
arguments (`config`, `lib`, `options`, and so on). Constructors pass additional
values with `specialArgs` for nix-darwin and `extraSpecialArgs` for Home
Manager. These values are automatically available by name to every module in
that evaluation; a module requests only the arguments it uses in its function
header. Read `modules/flake/lib.nix` to see the complete constructor argument
sets.

Nix combines all participating definitions by option. A public default written
with `lib.mkDefault` can be replaced by an ordinary private definition. Equal-
priority conflicting definitions produce an evaluation error; reserve
`lib.mkForce` for cases that genuinely require overriding a non-default value.

## Where a change belongs

- Put reusable, non-sensitive user configuration in a public Home Manager
  module.
- Put reusable machine-wide macOS configuration in a public nix-darwin module.
- Put identity, host selection, organization-specific values, and private
  overrides in the private flake.
- Prefer Home Manager for user-owned files, shell configuration, and user
  applications. Prefer nix-darwin for system packages, macOS defaults,
  services, Homebrew policy, and settings requiring system activation.
- Never put credentials or decrypted secrets into Nix expressions or build
  inputs. They may be copied into the world-readable Nix store.

## Updating a private flake

Commit and push the public change first. In each private repository that should
consume it, update only the public input:

```sh
nix flake update dotfiles
git diff -- flake.lock
```

Evaluate the affected outputs, activate the host, and then commit the private
lock-file change. Each private repository owns its own update schedule.

## Evaluation and discovery

Run these commands in a private overlay, replacing the synthetic output names
as appropriate.

List the outputs that the flake exposes:

```sh
nix flake show
```

Inspect the pinned public input and its exact revision:

```sh
nix flake metadata --json | jq '.locks.nodes.dotfiles.locked'
```

List the top-level attributes in a final Darwin configuration:

```sh
nix eval --json \
  .#darwinConfigurations.example-mac.config \
  --apply builtins.attrNames
```

Inspect a final option value after all modules have merged:

```sh
nix eval --json \
  .#darwinConfigurations.example-mac.config.system.defaults.screencapture
```

Show every definition of an option and its source location:

```sh
nix eval --json \
  .#darwinConfigurations.example-mac.options.system.defaults.screencapture.location.definitionsWithLocations
```

The same pattern works for Home Manager:

```sh
nix eval --json \
  '.#homeConfigurations."example@example-mac".config.programs.zsh.shellAliases'

nix eval --json \
  '.#homeConfigurations."example@example-mac".options.programs.zsh.shellAliases.definitionsWithLocations'
```

Inspect names contributed through the module system's `_module.args` option:

```sh
nix eval --json \
  .#darwinConfigurations.example-mac.options._module.args.value \
  --apply builtins.attrNames
```

This lists values contributed through the `_module.args` option. It does not
enumerate the standard arguments or constructor `specialArgs`; inspect
`modules/flake/lib.nix` for those because functions and other non-JSON values
cannot generally be printed directly.

For interactive exploration:

```sh
nix repl
```

Then load the current flake and inspect values without repeatedly typing the
full command:

```text
:lf .
outputs.darwinConfigurations.example-mac.config.networking.hostName
:p outputs.darwinConfigurations.example-mac.config.system.defaults.screencapture
```

## Validation and troubleshooting

Evaluate without activating:

```sh
nix eval --raw .#darwinConfigurations.example-mac.system
nix eval --raw \
  '.#homeConfigurations."example@example-vm".activationPackage.drvPath'
```

Show the full evaluation trace when a module fails:

```sh
nix eval --show-trace --raw .#darwinConfigurations.example-mac.system
```

Check formatting and repository whitespace:

```sh
nix fmt -- --check .
git diff --check
```

Git-backed flakes include only tracked files. If a new module is intentionally
untracked during development, evaluate the working directory explicitly:

```sh
nix eval --raw path:.#darwinConfigurations.example-mac.system
```

To test a private overlay against an unpublished public checkout without
changing its lock file:

```sh
nix eval --no-write-lock-file \
  --override-input dotfiles path:/path/to/dotfiles-public \
  --raw .#darwinConfigurations.example-mac.system
```

Useful distinctions when diagnosing failures:

- An evaluation error occurs while modules and options are being combined.
- A build error occurs while realizing a derivation in the Nix store.
- An activation error occurs while applying an already-built configuration.
- A new shell or restarted long-running process may be required before an
  activated environment or `PATH` change becomes visible.

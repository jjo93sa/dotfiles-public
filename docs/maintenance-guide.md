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

modules/home/
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
  +-- dotfiles.lib.mkDarwinHost, mkLinuxHost, or mkHomeHost
        |
        +-- private identity, hostname, platform, and special arguments
        +-- selected public modules
        +-- private host modules and overrides
        `-- final nix-darwin and/or Home Manager configuration
```

`mkDarwinHost` returns both a nix-darwin configuration and a standalone Home
Manager configuration. `mkLinuxHost` does the same for a NixOS system, adding
Home Manager as a NixOS module so the system and user profile activate
together. `mkHomeHost` returns only a standalone Home Manager configuration,
suitable for a user environment on an existing Linux system such as Ubuntu;
it does not turn that system into NixOS.

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

## Guided tour: follow one work Mac

The quickest way to refresh the architecture is to trace one real host from
its private entry point to an evaluated option. Start in
`dotfiles-work-private/flake.nix` and find the `GBBRS-0264` definition. It calls
the public constructor with the real hostname, platform, user identity, and
two private module lists:

```text
dotfiles-work-private/flake.nix
  |
  +-- darwinModules = [ hosts/GBBRS-0264/configuration.nix ]
  +-- homeModules   = [ home/jameso/GBBRS-0264.nix ]
  `-- dotfiles.lib.mkDarwinHost
```

`dotfiles.lib.mkDarwinHost` is exported by
`dotfiles-public/modules/flake/lib.nix`; its implementation is
`dotfiles-public/lib/mkDarwinHost.nix`. The constructor adds the Home Manager
and nix-homebrew integration modules, passes the shared module arguments, and
returns two related outputs:

```text
darwinConfiguration
  Machine-wide nix-darwin configuration. Home Manager is integrated here so
  the system and user configuration activate together.

homeConfiguration
  Standalone evaluation of the same private Home Manager module list. This is
  useful for inspection and targeted builds; normal Mac activation uses the
  integrated configuration above.
```

Next, read the two private modules selected by the host:

1. `hosts/GBBRS-0264/configuration.nix` imports public machine-wide
   capabilities such as `outputs.darwinModules.system` and
   `outputs.darwinModules.macos-defaults`, then adds work-host policy and
   overrides.
2. `home/jameso/GBBRS-0264.nix` imports `outputs.homeModules.common` and other
   selected user capabilities, then adds work-only files, aliases, and
   settings.

`outputs.homeModules.common` leads back to
`dotfiles-public/modules/home/common.nix`. That module is the shared user-level
bundle; follow its imports into individual public modules to see where a
program or generated file is defined.

These read-only commands, run from `dotfiles-work-private`, confirm the final
results after all public and private modules have merged:

```sh
nix eval --raw .#darwinConfigurations.GBBRS-0264.system

nix eval --json \
  .#darwinConfigurations.GBBRS-0264.config.nix.gc.interval

nix eval --json \
  '.#homeConfigurations."jameso@GBBRS-0264".config.programs.zsh.shellAliases'
```

### Follow one feature: global Just

Global Just demonstrates how a reusable public mechanism can accept private
extensions without the public repository knowing private paths or policy:

```text
dotfiles-public/modules/home/just.nix
  |
  +-- imported by public modules/home/common.nix
  +-- installs ~/.config/just/justfile
  +-- defines the jg shell alias
  `-- declares dotfiles.just.globalModules
        |
        `-- work-private GBBRS-0264.nix adds the `work` module
              |
              `-- files/just/work.just
                    `-- jg work dotfiles-check
```

The public global recipes themselves live in
`dotfiles-public/files/configs/just/global.just`. Private configurations add
named modules through `dotfiles.just.globalModules`; Home Manager renders each
module into `~/.config/just/modules/` and writes the corresponding `mod`
declaration into the generated root Justfile.

Inspect that generated root file before activation with:

```sh
nix eval --raw \
  '.#homeConfigurations."jameso@GBBRS-0264".config.xdg.configFile."just/justfile".text'
```

To discover both the final value and where its definitions came from, use the
same `definitionsWithLocations` technique described below:

```sh
nix eval --json \
  '.#homeConfigurations."jameso@GBBRS-0264".options.dotfiles.just.globalModules.definitionsWithLocations'
```

This two-pass tour—one complete host, then one feature—generalises to other
hosts and modules. Begin with the private flake's constructor call, follow the
selected module list into public outputs, and finally inspect the merged value
through `config` or its provenance through `options`.

## Where a change belongs

The primary package-ownership rule is:

> Install a package at the layer that owns the reason it exists.

Both system configuration and Home Manager use Nix and share the machine's
`/nix/store`. If two profiles select the same derivation, they link to the same
immutable store path rather than storing separate package copies. The choice
between layers therefore expresses ownership, availability, and lifecycle; it
should not be based only on whether a machine currently has one user.

Use NixOS or nix-darwin system configuration when a package:

- is required before a user logs in, by a system service or activation script;
- is needed to provide, administer, diagnose, or recover the machine;
- must be available independently of any user's Home Manager profile;
- is expected to be available to every user; or
- belongs to a machine-wide capability such as networking, storage,
  virtualization, backup, or security.

Use Home Manager when a package:

- exists because of an individual user's interactive workflow;
- belongs with that user's files, aliases, plugins, identity, or preferences;
- should follow the person between otherwise different machines;
- could reasonably vary by user, version, or preferred alternative; and
- is not required for system operation or recovery.

Prefer a service or program module's `package` option when it has one. This
keeps the executable with the capability that configures and uses it, instead
of adding an unrelated entry to `environment.systemPackages` or
`home.packages`.

Apply this decision test in order:

1. If a service or another module requires the package, let that capability
   own it.
2. If the machine would be incomplete or difficult to recover without it, use
   system configuration.
3. If it must work without the user's Home Manager profile, use system
   configuration.
4. If its purpose and configuration are personal, use Home Manager.
5. If it should follow a person across machines, use Home Manager.
6. If it should follow the machine when its users change, use system
   configuration.
7. If both layers genuinely require it for different reasons, allow the
   overlap and document both reasons.

For example, Neovim with personal plugins belongs in Home Manager, while a
minimal recovery editor belongs to the system. Git normally belongs in a
developer's Home Manager configuration, but a system activation script that
requires Git gives the system an independent reason to install it. Fastfetch
is ordinarily a user tool, but a disposable demonstration VM may deliberately
provide it as part of that VM's declared capability. Package names do not have
one permanent classification; the reason for installing them determines
ownership.

Do not extract a shared package list merely because two configurations happen
to contain the same names. Prefer narrowly named capability modules whose
purpose explains their packages. A shared list is appropriate when the shared
ownership is itself intentional and stable.

- Put reusable, non-sensitive user configuration in a public Home Manager
  module.
- Put reusable machine-wide macOS configuration in a public nix-darwin module.
- Put identity, host selection, organization-specific values, and private
  overrides in the private flake.
- Prefer Home Manager for user-owned files and shell configuration. Prefer
  nix-darwin for macOS defaults, services, Homebrew policy, and settings
  requiring system activation; apply the ownership test above to packages.
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

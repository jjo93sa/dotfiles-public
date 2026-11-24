# Package ownership audit

This audit applies the repository's package-ownership rule:

> Install a package at the layer that owns the reason it exists.

`Keep` means the present owner expresses the intended lifecycle. `Refine`
means the owner is sound but the dependency can be made more precise. Private
host decisions are recorded in the corresponding private repositories.

## Public Home Manager capabilities

| Capability or packages | Current owner | Decision | Required change |
|---|---|---|---|
| Atuin, Bat, Btop, Direnv, Eza, Fastfetch, FZF, Git/Delta, Lazygit, Neovim, Nix Index/Pay Respects, Starship, Zoxide and Zsh | Dedicated Home Manager `programs.*` modules | Keep: these are configured parts of an individual's interactive environment | None |
| `alejandra`, `deadnix`, `fd`, `gh`, `glab`, `grepcidr`, `jq`, `just`, `k9s`, `kubectl`, `lua5_4`, `marp-cli`, `mtr`, `nh`, `nixd`, `pipenv`, `pre-commit`, `pv`, `ripgrep`, `shellcheck`, `shfmt`, `statix`, `tio`, `tree-sitter`, `yamllint`, `yq-go` and the Python `pip`/`virtualenv` environment | `homeModules.development` via `home.packages` | Keep: portable, role-selected development tools should follow the user | None |
| `ipinfo` | `homeModules.home` via `home.packages` | Keep: interactive user utility | Consider moving it to a more descriptive shell/network-tools module when the module layout is reorganised |
| Krew and its selected plugins | `homeModules.krew` | Keep: Kubernetes workflow selected by the user | Ownership is correct; separately review the mutable activation-time plugin upgrade behaviour |
| C compiler and GNU Make used by Neovim plugins on Linux | `homeModules.neovim` via conditional `home.packages` | Keep for now: the dependency exists because of the user-managed editor | Prefer building native plugins declaratively so these become derivation build inputs rather than general runtime tools |
| Ghostty configuration | Home Manager with `package = null` | Keep: the user owns settings while the Mac installation owns the application bundle | None |

## Public machine capabilities

| Capability or packages | Current owner | Decision | Required change |
|---|---|---|---|
| Login Zsh support | `darwinModules.development` | Keep: the machine must recognise and provide the configured login shell | None |
| JetBrains Mono, Meslo Nerd Font and Roboto | nix-darwin `fonts.packages` | Keep: installed fonts are a machine-wide macOS resource | None |
| Ghostty application bundle | nix-darwin `environment.systemPackages` | Keep: nix-darwin installs the application into the machine's Nix Apps collection; Home Manager owns only its settings | None |
| Tailscale CLI service or GUI application | `darwinModules.tailscale` | Keep: machine networking and its macOS system extension are system capabilities | None |
| Raycast and 1Password CLI | nix-darwin Homebrew integration | Keep as a practical macOS installation boundary, although their use is personal | Continue the existing investigation of nixpkgs replacements; document any intentional system-installer/user-configuration split |
| Herdr and Cliamp formulae | `darwinModules.herdr` through nix-darwin Homebrew integration | Keep as the supported macOS installer; their configuration, credentials, plugins and wrappers remain user-owned | Document the intentional system-installer/user-configuration split |
| SwitchMyMagic | nix-darwin activation-managed application bundle | Keep: installation and update policy for an `/Applications` integration are machine state | None |
| Nix itself | `nix.package` | Keep: package-manager infrastructure is owned by the system | None |

## Shared follow-up

1. Normalise the module paths to `modules/home`, `modules/darwin`,
   `modules/nixos`, and `modules/flake` as already recorded in the backlog.
2. Introduce a small NixOS baseline capability for tools promised to every
   administrator: `curl`, `git`, `unzip`, and a minimal recovery editor.
3. Keep personal Git and editor configuration in Home Manager even where the
   system independently supplies a baseline executable.
4. When activation code needs a tool, reference its store path or declare it
   in `runtimeInputs`; do not rely on a package merely appearing on `PATH`.
5. Re-run this audit when a new package list or module family is introduced.

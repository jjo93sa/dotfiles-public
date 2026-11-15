set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --global-justfile --list

# Run Tailcat without installing it into an imperative profile. Arguments are
# forwarded unchanged and relative paths remain relative to the calling shell.
[no-cd]
tailcat *args:
    #!/usr/bin/env bash
    set -euo pipefail
    nix run github:tailscale/tailcat/v0.7.0 -- "$@"

# Show unreachable Nix store paths without deleting them.
[no-cd]
nix-gc-inspect:
    sudo nix store gc --dry-run

# Delete only currently unreachable Nix store paths. This does not remove old
# profile generations, which remain available as rollback roots.
[confirm("Delete all currently unreachable paths from the Nix store?")]
[no-cd]
nix-gc:
    sudo nix store gc

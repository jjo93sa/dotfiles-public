set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --global-justfile --list

# Run Tailcat without installing it into an imperative profile. Arguments are
# forwarded unchanged and relative paths remain relative to the calling shell.
[no-cd]
tailcat *args:
    #!/usr/bin/env bash
    set -euo pipefail
    nix run nixpkgs#tailcat -- "$@"

# Reconnect Herdr panes after Herdr starts before 1Password's SSH agent.
[no-cd]
herdr-refresh-ssh-agent:
    #!/usr/bin/env bash
    set -euo pipefail

    agent="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    herdr_agent="$HOME/.config/herdr/herdr.sock.agent"

    if [[ ! -S "$agent" ]]; then
      printf '1Password SSH agent socket is unavailable: %s\n' "$agent" >&2
      printf '%s\n' 'Start 1Password and enable its SSH agent, then retry.' >&2
      exit 1
    fi

    if [[ -e "$herdr_agent" && ! -L "$herdr_agent" ]]; then
      printf 'Refusing to replace non-symlink Herdr agent path: %s\n' \
        "$herdr_agent" >&2
      exit 1
    fi

    mkdir -p "$(dirname "$herdr_agent")"
    ln -sfn "$agent" "$herdr_agent"
    printf 'Herdr SSH agent now points to %s\n' "$agent"
    ssh-add -l

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

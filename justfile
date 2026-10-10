set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Evaluate the flake without building or activating anything.
check:
    nix flake check --no-build path:.

# Evaluate outputs for every supported system without building them.
check-all-systems:
    nix flake check --no-build --all-systems path:.

# Check Nix formatting using Alejandra without modifying files.
format-check:
    nix fmt path:. -- --check .

# Format all Nix files using Alejandra in the repository.
format:
    nix fmt path:. -- .

# Install Nix with flakes enabled when Just is already available.
install-nix:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v nix >/dev/null 2>&1; then
        printf 'Nix is already installed: %s\n' "$(command -v nix)"
        exit 0
    fi

    curl -sSfL https://artifacts.nixos.org/nix-installer |
        sh -s -- install --enable-flakes

    printf '%s\n' \
        'Nix installation completed.' \
        'Start a new login shell before continuing with flake activation.'

# Build the flake checks supported by the current machine.
test:
    nix flake check path:.

# Update Lazy-managed plugins and write the lock file to the mutable repository.
update-nvim-plugins:
    #!/usr/bin/env bash
    set -euo pipefail

    export XDG_CONFIG_HOME="$PWD/files/configs"
    nvim --headless '+Lazy! update' +qa

    printf 'Updated files/configs/nvim/lazy-lock.json; review and test the diff.\n'

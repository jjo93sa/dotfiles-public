set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Update Lazy-managed plugins and write the lock file to the mutable repository.
update-nvim-plugins:
    #!/usr/bin/env bash
    set -euo pipefail

    export XDG_CONFIG_HOME="$PWD/files/configs"
    nvim --headless '+Lazy! update' +qa

    printf 'Updated files/configs/nvim/lazy-lock.json; review and test the diff.\n'

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

# Create a complete Atuin client backup (contains the encryption key).
[no-cd]
atuin-backup destination="":
    #!/usr/bin/env bash
    set -euo pipefail

    source_directory="${ATUIN_DATA_DIR:-$HOME/.local/share/atuin}"
    destination={{ quote(destination) }}
    if [[ -z "$destination" ]]; then
      destination="${XDG_STATE_HOME:-$HOME/.local/state}/atuin/backups"
    fi

    if [[ ! -d "$source_directory" ]]; then
      printf 'Atuin data directory does not exist: %s\n' "$source_directory" >&2
      exit 1
    fi

    timestamp="$(date -u +%Y-%m-%dT%H%M%SZ)"
    archive="$destination/atuin-client-$timestamp.tar.gz"
    temporary="$(mktemp -d "${TMPDIR:-/tmp}/atuin-backup.XXXXXX")"
    trap 'rm -rf "$temporary"' EXIT

    install -d -m 0700 "$destination" "$temporary/atuin-data"

    # SQLite's online backup command creates consistent snapshots even if an
    # interactive shell has the source database open. WAL and SHM files are
    # deliberately excluded because their contents are incorporated here.
    while IFS= read -r -d '' path; do
      name="${path##*/}"
      case "$name" in
        *.db)
          sqlite3 "$path" ".backup '$temporary/atuin-data/$name'"
          ;;
        *.db-wal|*.db-shm)
          ;;
        *)
          cp -p "$path" "$temporary/atuin-data/$name"
          ;;
      esac
    done < <(find "$source_directory" -maxdepth 1 -type f -print0)

    atuin --version >"$temporary/atuin-data/ATUIN_BACKUP_VERSION"
    chmod -R go-rwx "$temporary/atuin-data"
    tar -C "$temporary" -czf "$archive" atuin-data
    chmod 0600 "$archive"

    tar -tzf "$archive" >/dev/null
    printf 'Created Atuin client backup: %s\n' "$archive"

# Restore Atuin client data while retaining the current data as a safety copy.
[no-cd]
atuin-restore archive confirmation:
    #!/usr/bin/env bash
    set -euo pipefail

    archive={{ quote(archive) }}
    confirmation={{ quote(confirmation) }}
    data_directory="${ATUIN_DATA_DIR:-$HOME/.local/share/atuin}"

    if [[ "$confirmation" != restore-atuin-client-data ]]; then
      printf '%s\n' 'Restoring replaces the active Atuin client data.' >&2
      printf '%s\n' \
        'Re-run with the final argument: restore-atuin-client-data' >&2
      exit 1
    fi
    if [[ ! -f "$archive" ]]; then
      printf 'Backup archive does not exist: %s\n' "$archive" >&2
      exit 1
    fi

    temporary="$(mktemp -d "${TMPDIR:-/tmp}/atuin-restore.XXXXXX")"
    trap 'rm -rf "$temporary"' EXIT
    tar -xzf "$archive" -C "$temporary"
    restored="$temporary/atuin-data"

    for required in history.db records.db meta.db key ATUIN_BACKUP_VERSION; do
      if [[ ! -f "$restored/$required" ]]; then
        printf 'Invalid Atuin backup; missing %s\n' "$required" >&2
        exit 1
      fi
    done
    for database in "$restored"/*.db; do
      if [[ "$(sqlite3 "$database" 'PRAGMA integrity_check;')" != ok ]]; then
        printf 'SQLite integrity check failed: %s\n' "$database" >&2
        exit 1
      fi
    done

    backup_version="$(<"$restored/ATUIN_BACKUP_VERSION")"
    installed_version="$(atuin --version)"
    printf 'Backup version:    %s\n' "$backup_version"
    printf 'Installed version: %s\n' "$installed_version"
    if [[ "$backup_version" != "$installed_version" ]]; then
      printf '%s\n' \
        'Warning: Atuin versions differ; matching versions are recommended.' >&2
    fi

    daemon_was_running=false
    if atuin daemon status 2>/dev/null | grep -q 'is running'; then
      daemon_was_running=true
      atuin daemon stop
    fi

    timestamp="$(date -u +%Y-%m-%dT%H%M%SZ)"
    safety_copy="${data_directory}.pre-restore-$timestamp"
    if [[ -e "$data_directory" ]]; then
      mv "$data_directory" "$safety_copy"
    fi

    if ! install -d -m 0700 "$(dirname "$data_directory")" \
      || ! cp -pR "$restored" "$data_directory"; then
      failed_copy="${data_directory}.failed-$timestamp"
      [[ ! -e "$data_directory" ]] || mv "$data_directory" "$failed_copy"
      [[ ! -e "$safety_copy" ]] || mv "$safety_copy" "$data_directory"
      printf '%s\n' 'Restore failed; the original data was put back.' >&2
      exit 1
    fi
    chmod -R go-rwx "$data_directory"

    if [[ "$daemon_was_running" == true ]]; then
      atuin daemon start
    fi

    printf 'Restored Atuin client data from: %s\n' "$archive"
    if [[ -e "$safety_copy" ]]; then
      printf 'Previous Atuin data retained at: %s\n' "$safety_copy"
    fi
    printf '%s\n' 'Open a new shell, then run: atuin doctor'

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

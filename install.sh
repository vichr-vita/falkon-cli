#!/bin/sh
# Installs the falkon CLI from the latest (or a chosen) GitHub release.
#
#   curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | sh
#
# To pass flags through a pipe, put them after `sh -s --`:
#
#   curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | sh -s -- --version vX.Y.Z
#
# Setting FALKON_VERSION=vX.Y.Z in the environment does the same.
#
# Options:
#   --version vX.Y.Z   install this release instead of the latest
#   --help             show this text
#
# Environment:
#   FALKON_VERSION      same as --version
#   FALKON_INSTALL_DIR  install directory (default: $HOME/.local/bin)
#
# The script never uses sudo and never edits shell or falkon config files.
set -eu

REPO="vichr-vita/falkon-cli"
# Test hook, not documented for users: point at a mirror of the release assets
# laid out as <base>/<version>/<file>.
RELEASE_BASE_URL="${FALKON_RELEASE_BASE_URL:-https://github.com/$REPO/releases/download}"

# Prints an error message to stderr and exits non-zero.
fail() {
    printf 'install.sh: error: %s\n' "$*" >&2
    exit 1
}

# Prints progress to stdout.
say() {
    printf '%s\n' "$*"
}

# Prints the usage text.
usage() {
    cat <<'USAGE'
Usage: install.sh [--version vX.Y.Z]

Installs the falkon CLI from a GitHub release of vichr-vita/falkon-cli.

To pass flags through a pipe: curl -fsSL <install.sh URL> | sh -s -- --version vX.Y.Z
FALKON_VERSION=vX.Y.Z in the environment does the same.

Options:
  --version vX.Y.Z   install this release instead of the latest
  --help             show this text

Environment:
  FALKON_VERSION      same as --version
  FALKON_INSTALL_DIR  install directory (default: $HOME/.local/bin)

The script never uses sudo and never edits shell or falkon config files.
USAGE
}

# Succeeds when the command exists on PATH.
have() {
    command -v "$1" >/dev/null 2>&1
}

# Writes the body of the URL ($1) to stdout, using curl or wget.
fetch() {
    if have curl; then
        curl -fsSL "$1"
    elif have wget; then
        wget -qO- "$1"
    else
        fail "curl or wget is required"
    fi
}

# Downloads the URL ($1) to the file ($2) and fails with a clear message.
download() {
    fetch "$1" >"$2" || fail "download failed: $1"
}

# Prints the Rust target triple for this machine, or fails when unsupported.
detect_target() {
    os=$(uname -s)
    arch=$(uname -m)
    case "$arch" in
        x86_64 | amd64) arch_part="x86_64" ;;
        aarch64 | arm64) arch_part="aarch64" ;;
        *) fail "unsupported CPU architecture: $arch" ;;
    esac
    case "$os" in
        Linux) printf '%s-unknown-linux-musl\n' "$arch_part" ;;
        Darwin) printf '%s-apple-darwin\n' "$arch_part" ;;
        *) fail "unsupported operating system: $os (on Windows use install.ps1)" ;;
    esac
}

# Prints the latest release tag: the GitHub API first, then the redirect of
# the /releases/latest page.
resolve_latest_version() {
    tag=$(fetch "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null |
        sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1) || tag=""
    if [ -z "$tag" ] && have curl; then
        tag=$(curl -sI "https://github.com/$REPO/releases/latest" |
            sed -n 's/^[Ll]ocation:.*\/tag\/\([^[:space:]]*\).*/\1/p' | head -n 1) || tag=""
    fi
    [ -n "$tag" ] || fail "could not determine the latest release; pass --version vX.Y.Z"
    printf '%s\n' "$tag"
}

# Prints the SHA-256 hex digest of the file ($1).
sha256_of() {
    if have sha256sum; then
        sha256sum "$1" | cut -d ' ' -f 1
    elif have shasum; then
        shasum -a 256 "$1" | cut -d ' ' -f 1
    else
        fail "sha256sum or shasum is required to verify the download"
    fi
}

# Verifies the archive file ($1, named $2 in the checksum list) against the
# SHA256SUMS file ($3).
verify_checksum() {
    expected=$(awk -v name="$2" '$2 == name || $2 == "*" name { print $1; exit }' "$3")
    [ -n "$expected" ] || fail "$2 is not listed in SHA256SUMS"
    actual=$(sha256_of "$1")
    if [ "$expected" != "$actual" ]; then
        fail "checksum mismatch for $2 (expected $expected, got $actual)"
    fi
}

# Parses arguments, downloads, verifies and installs the binary.
main() {
    version="${FALKON_VERSION:-}"
    while [ $# -gt 0 ]; do
        case "$1" in
            --version)
                [ $# -ge 2 ] || fail "--version needs a value such as v0.1.0"
                version="$2"
                shift 2
                ;;
            --version=*)
                version="${1#--version=}"
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *) fail "unknown argument: $1 (see --help)" ;;
        esac
    done

    have curl || have wget || fail "curl or wget is required"

    if [ -n "${FALKON_INSTALL_DIR:-}" ]; then
        INSTALL_DIR="$FALKON_INSTALL_DIR"
    else
        [ -n "${HOME:-}" ] || fail "HOME is not set; set HOME or FALKON_INSTALL_DIR"
        INSTALL_DIR="$HOME/.local/bin"
    fi

    target=$(detect_target)
    [ -n "$version" ] || version=$(resolve_latest_version)
    case "$version" in
        v*) ;;
        *) version="v$version" ;;
    esac

    archive="falkon-$version-$target.tar.gz"
    say "Installing falkon $version for $target"

    work_dir=$(mktemp -d) || fail "could not create a temporary directory"
    staged="$INSTALL_DIR/.falkon.tmp.$$"
    trap 'rm -rf "$work_dir"; rm -f "$staged"' EXIT HUP INT TERM

    download "$RELEASE_BASE_URL/$version/$archive" "$work_dir/$archive"
    download "$RELEASE_BASE_URL/$version/SHA256SUMS" "$work_dir/SHA256SUMS"
    verify_checksum "$work_dir/$archive" "$archive" "$work_dir/SHA256SUMS"
    say "Checksum verified"

    mkdir "$work_dir/extract"
    tar -xzf "$work_dir/$archive" -C "$work_dir/extract" || fail "could not extract $archive"
    [ -f "$work_dir/extract/falkon" ] || fail "$archive does not contain a falkon binary"

    mkdir -p "$INSTALL_DIR" || fail "could not create $INSTALL_DIR"
    # Copy beside the target, then rename over it: a running falkon is never
    # overwritten in place.
    cp "$work_dir/extract/falkon" "$staged" || fail "could not write $staged"
    chmod 0755 "$staged" || fail "could not make $staged executable"
    mv -f "$staged" "$INSTALL_DIR/falkon" || fail "could not replace $INSTALL_DIR/falkon"

    say "Installed: $INSTALL_DIR/falkon"
    "$INSTALL_DIR/falkon" --version || fail "the installed binary does not run"

    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *) say "Warning: $INSTALL_DIR is not on your PATH. Add it to your shell profile to run falkon directly." ;;
    esac
}

main "$@"

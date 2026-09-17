#!/usr/bin/env bash
#
# Build, serve, and stop the DocC site for a Swift package.
#
#   docs.sh build            build into ./_site for local viewing
#   docs.sh build --hosted   build the way GitHub Pages serves it
#   docs.sh serve [--port N] build, then serve ./_site in the background
#   docs.sh stop             stop the background server
#   docs.sh status           report whether a server is running
#   docs.sh preview          swift's live-reloading preview (foreground)
#
# Options, accepted before or after the command:
#   --target NAME       the target whose Documentation.docc to build; detected
#                       when exactly one Sources/*/Documentation.docc exists
#   --base-path NAME    the path a hosted build is served under; defaults to
#                       the repository name from the origin remote
#
# The package is the nearest ancestor of the working directory that holds a
# Package.swift, or the parent of this script's directory. DOCS_ROOT,
# DOCS_TARGET, and DOCS_BASE_PATH set the same things from the environment.

set -euo pipefail

usage() {
    sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

find_root() {
    if [ -n "${DOCS_ROOT:-}" ]; then
        printf '%s' "$DOCS_ROOT"
        return 0
    fi
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/Package.swift" ]; then
            printf '%s' "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [ -f "$dir/Package.swift" ]; then
        printf '%s' "$dir"
        return 0
    fi
    echo "docs.sh: no Package.swift above $PWD; run from inside the package or set DOCS_ROOT" >&2
    return 1
}

find_target() {
    if [ -n "${DOCS_TARGET:-}" ]; then
        printf '%s' "$DOCS_TARGET"
        return 0
    fi
    local catalogs=()
    local catalog
    for catalog in "$ROOT"/Sources/*/Documentation.docc; do
        [ -d "$catalog" ] && catalogs+=("$(basename "$(dirname "$catalog")")")
    done
    case "${#catalogs[@]}" in
        1) printf '%s' "${catalogs[0]}" ;;
        0)
            echo "docs.sh: no Sources/*/Documentation.docc in $ROOT; pass --target" >&2
            return 1
            ;;
        *)
            echo "docs.sh: several targets have a catalog (${catalogs[*]}); pass --target" >&2
            return 1
            ;;
    esac
}

find_base_path() {
    if [ -n "${DOCS_BASE_PATH:-}" ]; then
        printf '%s' "$DOCS_BASE_PATH"
        return 0
    fi
    local url
    if url="$(git -C "$ROOT" remote get-url origin 2>/dev/null)"; then
        url="${url%/}"
        url="${url%.git}"
        printf '%s' "${url##*/}"
        return 0
    fi
    echo "docs.sh: no origin remote to take the base path from; pass --base-path" >&2
    return 1
}

# The site title for the root redirect: the landing page's @DisplayName when
# it has one, otherwise the target name.
site_title() {
    local landing="$ROOT/Sources/$TARGET/Documentation.docc/$TARGET.md"
    local title=""
    if [ -f "$landing" ]; then
        title="$(sed -n 's/.*@DisplayName("\([^"]*\)").*/\1/p' "$landing" | head -n 1)"
    fi
    printf '%s' "${title:-$TARGET}"
}

build() {
    local hosted="${1:-no}"

    cd "$ROOT"

    # Only `swift build` type checks the files under Snippets/. The docs build
    # extracts them textually, so a broken example renders fine and ships wrong.
    swift build

    local args=(
        --allow-writing-to-directory "$OUTPUT"
        generate-documentation
        --target "$TARGET"
        --disable-indexing
        --transform-for-static-hosting
        --output-path "$OUTPUT"
    )

    # The base path prefixes every asset URL with the repo name, which is what
    # Pages serves the site under. A build carrying it cannot be served from
    # $OUTPUT directly, so local builds leave it off.
    if [ "$hosted" = "hosted" ]; then
        local base_path
        base_path="$(find_base_path)"
        args+=(--hosting-base-path "$base_path")
    fi

    swift package "${args[@]}"

    if [ "$hosted" = "hosted" ]; then
        # DocC puts the landing page under documentation/, not at the site
        # root, so the root needs a redirect.
        local title
        title="$(site_title)"
        cat > "$OUTPUT/index.html" <<EOF
<!doctype html>
<meta http-equiv="refresh" content="0; url=./$LANDING/">
<title>$title</title>
<a href="./$LANDING/">$title</a>
EOF
    fi
}

port_in_use() {
    (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null && exec 3>&- && return 0
    return 1
}

free_port() {
    local port
    for ((port = FIRST_PORT; port <= LAST_PORT; port++)); do
        if ! port_in_use "$port"; then
            printf '%s' "$port"
            return 0
        fi
    done
    echo "docs.sh: no free port between $FIRST_PORT and $LAST_PORT" >&2
    return 1
}

running_pid() {
    [ -f "$PID_FILE" ] || return 1
    local pid
    pid="$(cat "$PID_FILE")"
    kill -0 "$pid" 2>/dev/null || return 1
    printf '%s' "$pid"
}

serve() {
    local port="${1:-}"

    build
    stop >/dev/null

    [ -n "$port" ] || port="$(free_port)"

    # Something else on the port would keep listening after python exits,
    # which otherwise reads as a successful start and prints a URL that 404s.
    if port_in_use "$port"; then
        echo "docs.sh: port $port is already in use" >&2
        return 1
    fi

    mkdir -p "$STATE_DIR"

    python3 -m http.server "$port" --directory "$OUTPUT" >/dev/null 2>&1 &
    local pid=$!
    disown "$pid" 2>/dev/null || true
    echo "$pid" > "$PID_FILE"
    echo "$port" > "$PORT_FILE"

    local waited=0
    until port_in_use "$port"; do
        if ! kill -0 "$pid" 2>/dev/null || [ "$waited" -ge 10 ]; then
            echo "docs.sh: server failed to start on port $port" >&2
            return 1
        fi
        sleep 1
        waited=$((waited + 1))
    done

    echo "http://localhost:$port/$LANDING/"
}

stop() {
    local pid
    if pid="$(running_pid)"; then
        kill "$pid" 2>/dev/null || true
        echo "stopped server (pid $pid)"
    else
        echo "no server running"
    fi
    rm -f "$PID_FILE" "$PORT_FILE"
}

status() {
    local pid
    if pid="$(running_pid)"; then
        echo "running (pid $pid): http://localhost:$(cat "$PORT_FILE")/$LANDING/"
    else
        echo "no server running"
    fi
}

preview() {
    cd "$ROOT"
    swift build
    swift package preview-documentation --target "$TARGET"
}

POSITIONAL=()
while [ $# -gt 0 ]; do
    case "$1" in
        --target) DOCS_TARGET="${2:?docs.sh: --target needs a name}"; shift 2 ;;
        --base-path) DOCS_BASE_PATH="${2:?docs.sh: --base-path needs a name}"; shift 2 ;;
        -h | --help | help) usage; exit 0 ;;
        *) POSITIONAL+=("$1"); shift ;;
    esac
done

if [ "${#POSITIONAL[@]}" -eq 0 ]; then
    usage
    exit 0
fi

ROOT="$(find_root)"
TARGET="$(find_target)"
OUTPUT="$ROOT/_site"
LANDING="documentation/$(printf '%s' "$TARGET" | tr '[:upper:]' '[:lower:]')"
STATE_DIR="$ROOT/.build"
PID_FILE="$STATE_DIR/docs-server.pid"
PORT_FILE="$STATE_DIR/docs-server.port"
FIRST_PORT=8000
LAST_PORT=8099

case "${POSITIONAL[0]}" in
    build)
        case "${POSITIONAL[1]:-}" in
            "") build ;;
            --hosted) build hosted ;;
            *) echo "docs.sh: unknown option ${POSITIONAL[1]}" >&2; exit 2 ;;
        esac
        ;;
    serve)
        case "${POSITIONAL[1]:-}" in
            "") serve ;;
            --port) serve "${POSITIONAL[2]:?docs.sh: --port needs a number}" ;;
            *) echo "docs.sh: unknown option ${POSITIONAL[1]}" >&2; exit 2 ;;
        esac
        ;;
    stop) stop ;;
    status) status ;;
    preview) preview ;;
    *) echo "docs.sh: unknown command ${POSITIONAL[0]}" >&2; usage >&2; exit 2 ;;
esac

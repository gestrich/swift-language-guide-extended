#!/usr/bin/env bash
#
# Build, serve, and stop the DocC site for this package.
#
#   docs.sh build            build into ./_site for local viewing
#   docs.sh build --hosted   build the way GitHub Pages serves it
#   docs.sh serve [--port N] build, then serve ./_site in the background
#   docs.sh stop             stop the background server
#   docs.sh status           report whether a server is running
#   docs.sh preview          swift's live-reloading preview (foreground)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
TARGET="SwiftLanguageGuideExtended"
BASE_PATH="swift-language-guide-extended"
OUTPUT="$ROOT/_site"
LANDING="documentation/$(printf '%s' "$TARGET" | tr '[:upper:]' '[:lower:]')"
STATE_DIR="$ROOT/.build"
PID_FILE="$STATE_DIR/docs-server.pid"
PORT_FILE="$STATE_DIR/docs-server.port"
FIRST_PORT=8000
LAST_PORT=8099

usage() {
    sed -n '3,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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
        args+=(--hosting-base-path "$BASE_PATH")
    fi

    swift package "${args[@]}"

    if [ "$hosted" = "hosted" ]; then
        # DocC puts the landing page under documentation/, not at the site
        # root, so the root needs a redirect.
        cat > "$OUTPUT/index.html" <<EOF
<!doctype html>
<meta http-equiv="refresh" content="0; url=./$LANDING/">
<title>Swift Language Guide Extended</title>
<a href="./$LANDING/">Swift Language Guide Extended</a>
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

case "${1:-}" in
    build)
        case "${2:-}" in
            "") build ;;
            --hosted) build hosted ;;
            *) echo "docs.sh: unknown option ${2}" >&2; exit 2 ;;
        esac
        ;;
    serve)
        case "${2:-}" in
            "") serve ;;
            --port) serve "${3:?docs.sh: --port needs a number}" ;;
            *) echo "docs.sh: unknown option ${2}" >&2; exit 2 ;;
        esac
        ;;
    stop) stop ;;
    status) status ;;
    preview) preview ;;
    "" | -h | --help | help) usage ;;
    *) echo "docs.sh: unknown command ${1}" >&2; usage >&2; exit 2 ;;
esac

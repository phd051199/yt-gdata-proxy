#!/bin/sh
set -e

APP_PID=""
SSH_PID=""

cleanup() {
    [ -n "$APP_PID" ] && kill "$APP_PID" 2>/dev/null || true
    [ -n "$SSH_PID" ] && kill "$SSH_PID" 2>/dev/null || true
    exit 0
}

trap cleanup TERM INT

maintain_ssh_tunnel() {
    while true; do
        ssh -i /ssh/key.pem -N -R 3000:localhost:3000 nglocalhost.com &
        SSH_PID=$!
        wait $SSH_PID
        sleep 5
    done
}

./proxy-server &
APP_PID=$!

maintain_ssh_tunnel &

wait $APP_PID
cleanup

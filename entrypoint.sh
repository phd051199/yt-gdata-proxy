#!/bin/sh

set -e

echo "Starting Go proxy application..."

APP_PID=""
SSH_PID=""

cleanup() {
    echo "Stopping services..."
    if [ ! -z "$APP_PID" ]; then
        kill $APP_PID 2>/dev/null || true
        echo "Go application stopped"
    fi
    if [ ! -z "$SSH_PID" ]; then
        kill $SSH_PID 2>/dev/null || true
        echo "SSH tunnel stopped"
    fi
    exit 0
}

trap cleanup TERM INT

maintain_ssh_tunnel() {
    while true; do
        echo "Establishing SSH tunnel..."
        sleep 5

        ssh -i /ssh/key.pem -R 3000:localhost:3000 nglocalhost.com &
        
        SSH_PID=$!
        echo "SSH tunnel started with PID: $SSH_PID"

        wait $SSH_PID
        
        echo "SSH tunnel disconnected. Retrying in 5 seconds..."
        sleep 5
    done
}

wait_for_app() {
    echo "Waiting for application to be ready..."
    for i in $(seq 1 30); do
        if wget --quiet --tries=1 --spider http://localhost:3000 2>/dev/null; then
            echo "Application is ready!"
            return 0
        fi
        echo "Waiting... ($i/30)"
        sleep 1
    done
    echo "Application failed to start properly"
    return 1
}

echo "Starting Go proxy server..."
./proxy-server &
APP_PID=$!
echo "Go application started with PID: $APP_PID"

if wait_for_app; then
    echo "Starting SSH tunnel maintenance..."
    maintain_ssh_tunnel &
else
    echo "Failed to start application, exiting..."
    cleanup
fi

wait $APP_PID

echo "Main application process exited"
cleanup

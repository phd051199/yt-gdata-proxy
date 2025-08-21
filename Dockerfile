# stage 1
FROM golang:1.25.0-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -trimpath \
    -o proxy-server .

# stage 2
FROM alpine:latest

RUN apk add --no-cache openssh-client

RUN mkdir -p /root/.ssh && \
    echo "StrictHostKeyChecking no" > /root/.ssh/config && \
    echo "UserKnownHostsFile /dev/null" >> /root/.ssh/config && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/config

WORKDIR /app

COPY --from=builder /app/proxy-server .
COPY --chmod=400 key.pem /ssh/key.pem
COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]

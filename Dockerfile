FROM golang:1.25.0-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o proxy-server .

FROM alpine:latest

RUN apk add --no-cache \
    openssh-client \
    ca-certificates \
    tzdata

RUN adduser -D -s /bin/sh appuser

WORKDIR /app

COPY --from=builder /app/proxy-server .

RUN mkdir -p /ssh
COPY key.pem /ssh/key.pem
RUN chmod 400 /ssh/key.pem && \
    chown appuser:appuser /ssh/key.pem

RUN mkdir -p /home/appuser/.ssh && \
    echo "StrictHostKeyChecking no" >> /home/appuser/.ssh/config && \
    echo "UserKnownHostsFile /dev/null" >> /home/appuser/.ssh/config && \
    chown -R appuser:appuser /home/appuser/.ssh && \
    chmod 700 /home/appuser/.ssh && \
    chmod 600 /home/appuser/.ssh/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown appuser:appuser /entrypoint.sh

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]

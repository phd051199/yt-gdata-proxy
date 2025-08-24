#!/bin/sh
set -e

IMAGE_NAME="phd051199/youtube-gdata-proxy"
TAG="latest"
PLATFORMS="linux/amd64"
BUILDER_NAME="multiarch-builder"

echo "🔍 Checking buildx builder..."
if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  echo "⚙️  Creating buildx builder: $BUILDER_NAME"
  docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  docker buildx inspect --bootstrap
else
  echo "✅ Builder $BUILDER_NAME already exists."
  docker buildx use "$BUILDER_NAME"
fi

echo "🚀 Building and pushing image: $IMAGE_NAME:$TAG"
docker buildx build \
  --platform "$PLATFORMS" \
  -t "$IMAGE_NAME:$TAG" \
  . \
  --push

echo "🎉 Done! Image pushed: $IMAGE_NAME:$TAG"

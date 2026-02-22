#!/bin/bash

# ===================================
# Docker Build Script (Linux/Mac)
# ===================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
VERSION="${1:-latest}"
REGISTRY="${2:-localhost}"
IMAGE_NAME="whatsapp-api"
FULL_IMAGE="$REGISTRY/$IMAGE_NAME:$VERSION"

echo -e "${YELLOW}🐳 WhatsApp API Docker Build${NC}"
echo "Version: $VERSION"
echo "Registry: $REGISTRY"
echo "Image: $FULL_IMAGE"
echo ""

# Validar Dockerfile
if [ ! -f "$(dirname "$0")/Dockerfile" ]; then
    echo -e "${RED}❌ Dockerfile not found!${NC}"
    exit 1
fi

# Build
echo -e "${YELLOW}📦 Building Docker image...${NC}"
docker build \
    -t "$IMAGE_NAME:$VERSION" \
    -t "$IMAGE_NAME:latest" \
    -f "$(dirname "$0")/Dockerfile" \
    -o type=docker \
    ..

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    
    # Tagging for registry (if not localhost)
    if [ "$REGISTRY" != "localhost" ]; then
        echo -e "${YELLOW}🏷️  Tagging for registry...${NC}"
        docker tag "$IMAGE_NAME:$VERSION" "$FULL_IMAGE"
        echo -e "${GREEN}✅ Tagged as $FULL_IMAGE${NC}"
    fi
    
    # Show image info
    echo ""
    echo -e "${YELLOW}📊 Image Info:${NC}"
    docker images "$IMAGE_NAME:$VERSION" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    echo ""
    echo -e "${GREEN}✨ Ready to use!${NC}"
    echo "To run: docker-compose up -d"
    echo "To push: docker push $FULL_IMAGE"
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

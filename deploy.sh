#!/bin/bash

# ===================================
# Deploy Script for VPS
# ===================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validar argumentos
if [ $# -lt 3 ]; then
    echo -e "${RED}Usage: ./deploy.sh <user@host> <version> [docker-compose-file]${NC}"
    echo "Example: ./deploy.sh ubuntu@seu-vps.com v1.0.0"
    exit 1
fi

USER_HOST=$1
VERSION=$2
COMPOSE_FILE="${3:-docker-compose.yml}"
DEPLOY_PATH="/opt/whatsapp-api"

echo -e "${BLUE}🚀 WhatsApp API Deploy to VPS${NC}"
echo "Target: $USER_HOST"
echo "Version: $VERSION"
echo "Compose: $COMPOSE_FILE"
echo ""

# Conectar via SSH e fazer deploy
echo -e "${YELLOW}📡 Conectando ao VPS...${NC}"

ssh -o ConnectTimeout=10 "$USER_HOST" << EOFSH
    set -e
    
    # Cores no servidor
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    
    echo -e "\${YELLOW}📂 Verificando diretório...${NC}"
    mkdir -p $DEPLOY_PATH
    cd $DEPLOY_PATH
    
    echo -e "\${YELLOW}📥 Atualizando código...${NC}"
    if [ -d .git ]; then
        git pull origin main
    else
        echo "Aviso: Não é um repositório git. Pulando git pull."
    fi
    
    echo -e "\${YELLOW}🐳 Fazendo pull da imagem...${NC}"
    docker pull localhost/whatsapp-api:$VERSION || docker-compose pull
    
    echo -e "\${YELLOW}🔄 Atualizando container (zero-downtime)...${NC}"
    docker-compose -f $COMPOSE_FILE up -d --no-deps --build whatsapp-api
    
    echo -e "\${YELLOW}⏳ Aguardando health check...${NC}"
    sleep 5
    
    if docker-compose -f $COMPOSE_FILE exec -T whatsapp-api curl -f http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "\${GREEN}✅ Health check passed!${NC}"
    else
        echo -e "\${YELLOW}⚠️  Health check failed. Verificar logs:${NC}"
        docker-compose -f $COMPOSE_FILE logs whatsapp-api
        exit 1
    fi
    
    echo -e "\${GREEN}✅ Deploy bem-sucedido!${NC}"
    echo "Vers: $VERSION"
    echo "Time: \$(date)"
EOFSH

echo ""
echo -e "${GREEN}✨ Deploy completo!${NC}"
echo "Acesso: https://seu-dominio.com/health"

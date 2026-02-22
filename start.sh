#!/bin/bash

# ===================================
# Docker Startup Script (Linux/Mac)
# ===================================

set -e

# Cores
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo -e "${BLUE}======================================"
echo -e "   WhatsApp API - Docker Startup"
echo -e "======================================${NC}"
echo ""

# Verificar se está na pasta certa
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Erro: docker-compose.yml não encontrado!${NC}"
    echo "Execute este script de dentro da pasta 'docker/'"
    exit 1
fi

# Menu
echo -e "${YELLOW}Escolha uma opção:${NC}"
echo ""
echo "1 - Produção (docker-compose.yml)"
echo "2 - Desenvolvimento (docker-compose.dev.yml)"
echo "3 - Parar containers"
echo "4 - Ver logs"
echo "5 - Health check"
echo "6 - Sair"
echo ""

read -p "Digite sua escolha (1-6): " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}[*] Iniciando produção...${NC}"
        docker-compose -f docker-compose.yml up -d
        echo ""
        echo -e "${GREEN}[+] API rodando em http://localhost:5000${NC}"
        echo -e "${GREEN}[+] Health check: http://localhost:5000/health${NC}"
        sleep 3
        ;;
    2)
        echo ""
        echo -e "${YELLOW}[*] Iniciando desenvolvimento (hot reload)...${NC}"
        docker-compose -f docker-compose.dev.yml up -d
        echo ""
        echo -e "${GREEN}[+] API rodando em http://localhost:5000${NC}"
        echo -e "${GREEN}[+] As mudanças no código vão ser recarregadas automaticamente${NC}"
        sleep 3
        ;;
    3)
        echo ""
        echo -e "${YELLOW}[*] Parando containers...${NC}"
        docker-compose down
        echo -e "${GREEN}[+] Containers parados${NC}"
        sleep 2
        ;;
    4)
        echo ""
        echo -e "${YELLOW}[*] Mostrando logs (Ctrl+C para sair)...${NC}"
        docker-compose logs -f whatsapp-api
        ;;
    5)
        echo ""
        echo -e "${YELLOW}[*] Verificando health...${NC}"
        if curl -s http://localhost:5000/health | grep -q "ok"; then
            echo -e "${GREEN}[+] API está saudável${NC}"
        else
            echo -e "${YELLOW}[-] API pode não estar respondendo${NC}"
        fi
        ;;
    6)
        exit 0
        ;;
    *)
        echo "Opção inválida!"
        ;;
esac

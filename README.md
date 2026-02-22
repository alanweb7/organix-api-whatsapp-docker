# 🐳 Docker - Organização Limpa

Toda a configuração Docker está aqui nesta pasta, mantendo o projeto organizado.

## 📁 Estrutura

```
docker/
├── Dockerfile                    # Imagem multi-stage
├── docker-compose.yml           # Produção
├── docker-compose.dev.yml       # Desenvolvimento
├── .dockerignore                # Excludes
├── build.sh                     # Build script (Linux/Mac)
├── build.ps1                    # Build script (Windows)
├── deploy.sh                    # VPS deployment
├── Makefile                     # Automation
└── README.md                    # Este arquivo
```

## 🚀 Quick Start

### Opção 1: Usar Make (Recomendado)

```bash
cd docker
make help              # Ver todos os comandos
make build VERSION=1.0.0
make up
make logs-follow
```

### Opção 2: Docker Compose Direto

```bash
# Produção
docker-compose -f docker/docker-compose.yml up -d

# Desenvolvimento (com hot reload)
docker-compose -f docker/docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f
```

### Opção 3: Scripts de Build

**Windows PowerShell:**
```powershell
cd docker
.\build.ps1 -Version "1.0.0"
docker-compose -f docker-compose.yml up -d
```

**Linux/Mac:**
```bash
cd docker
chmod +x build.sh
./build.sh 1.0.0
docker-compose -f docker-compose.yml up -d
```

## 📊 Comandos Make

```bash
# Build
make build VERSION=1.0.0         # Build image
make build-dev                   # Build com hot reload
make build-clean                 # Clean rebuild (sem cache)

# Rodar
make up                          # Start production
make up-dev                      # Start development
make down                        # Stop containers
make restart                     # Restart

# Monitoramento
make logs                        # Ver logs
make logs-follow                 # Tail logs
make ps                          # Ver containers
make stats                       # Ver recursos (CPU/Mem)
make health                      # Check health

# Testes
make test                        # Run Go tests
make lint                        # Run linter
make shell                       # SSH para container

# Deploy
make deploy HOST=user@vps VERSION=v1.0.0
make deploy-k8s NAMESPACE=whatsapp

# Limpeza
make clean                       # Remove containers
make clean-all                   # Remove everything
make prune                       # Clean system

# Registry
make push REGISTRY=docker.io     # Push to registry
make pull                        # Pull image
make version                     # Show version info
```

## 🐳 docker-compose.yml (Produção)

```yaml
- Container otimizado (~100MB)
- Non-root user (segurança)
- Health checks automáticos
- Volumes persistentes
- Logging estruturado
- Network isolada
```

Usar:
```bash
docker-compose -f docker/docker-compose.yml up -d
```

## 🔧 docker-compose.dev.yml (Desenvolvimento)

```yaml
- Volume mount para código local
- go run . com hot reload
- Debug logging
- Mesma estrutura de produção
```

Usar:
```bash
docker-compose -f docker/docker-compose.dev.yml up -d
# Edite arquivos local e veja mudanças ao vivo
```

## 🏗 Dockerfile

- **Stage 1**: Builder com CGO
  - Go 1.21
  - SQLite dev dependencies
  - Compila binário estático

- **Stage 2**: Runtime
  - Alpine 3.19 (mínimo)
  - Non-root user
  - Health checks
  - ~100MB final

## 🚀 Deploy em VPS

```bash
# Automático
cd docker
chmod +x deploy.sh
./deploy.sh ubuntu@seu-vps.com v1.0.0

# Faz automaticamente:
# ✅ SSH para VPS
# ✅ Git pull (se repo)
# ✅ Docker pull
# ✅ docker-compose up -d
# ✅ Health check
```

## 📖 Documentação Completa

- `docker-compose.yml` - Comentários inline
- `Dockerfile` - Comments em cada stage
- `Makefile` - Help em cada target
- `build.sh` / `build.ps1` - Scripts comentados

## 🆘 Troubleshooting

### Container não inicia

```bash
make logs                    # Ver erro
make down && make up         # Restart
```

### Porta em uso

```bash
# Windows
netstat -ano | findstr :5000

# Linux
ss -tlnp | grep :5000

# Mudar porta em docker-compose.yml
# ports:
#   - "5001:5000"
```

### Imagem muito grande

```bash
# Verificar
docker images whatsapp-api

# Limpar
make clean-all
make build-clean
```

### Erro de permissão

```bash
# Verificar ownership
ls -la data/

# Fixar
sudo chown -R 1000:1000 ./data/
```

## ✅ Checklist

- [ ] Docker instalado (`docker --version`)
- [ ] Docker Compose instalado (`docker-compose --version`)
- [ ] Arquivo `docker-compose.yml` presente
- [ ] Arquivo `Dockerfile` presente
- [ ] `.dockerignore` configurado
- [ ] `build.sh` / `build.ps1` executáveis

## 🎯 Próximas Etapas

1. **Build local**: `make build VERSION=1.0.0`
2. **Testar**: `make up && make health`
3. **Ver logs**: `make logs-follow`
4. **Stop**: `make down`
5. **Deploy**: `make deploy HOST=seu-vps VERSION=v1.0.0`

## 📝 Notas

- `docker-compose.yml` usa configuração de produção
- `docker-compose.dev.yml` tem hot reload
- Ambos usam o mesmo `Dockerfile`
- Dados persistidos em volumes Docker
- Backups de dados estão em `./data` (local) ou Docker volumes

---

**Status**: ✅ Organizado e pronto para uso

Para documentação completa, veja:
- [../DOCKER.md](../DOCKER.md) - Docker detalhado
- [../MANUAL.md](../MANUAL.md) - API completa
- [../DEPLOYMENT-CHECKLIST.md](../DEPLOYMENT-CHECKLIST.md) - Deploy passo-a-passo

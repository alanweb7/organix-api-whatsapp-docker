.PHONY: help build build-dev up up-dev down logs logs-follow clean test lint deploy

# Variables
VERSION ?= latest
REGISTRY ?= localhost
COMPOSE_FILE ?= docker-compose.yml
CONTAINER_NAME ?= whatsapp-api

# Colors
YELLOW := \033[1;33m
GREEN := \033[0;32m
NC := \033[0m

help: ## Show this help message
	@echo "$(YELLOW)WhatsApp API - Docker Make Targets$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

# ===== BUILD =====

build: ## Build Docker image (VERSION=x.x.x)
	@echo "$(YELLOW)Building Docker image...$(NC)"
	@chmod +x build.sh
	./build.sh $(VERSION) $(REGISTRY)

build-dev: ## Build development image with hot reload
	@echo "$(YELLOW)Building development image...$(NC)"
	docker build -t $(CONTAINER_NAME):dev-$(VERSION) -f Dockerfile ..

build-clean: ## Clean build (remove cache)
	@echo "$(YELLOW)Clean building...$(NC)"
	docker build --no-cache -t $(CONTAINER_NAME):$(VERSION) -f Dockerfile ..

# ===== RUN =====

up: ## Start containers (production)
	@echo "$(YELLOW)Starting containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ API running at http://localhost:5000$(NC)"

up-dev: ## Start containers with hot reload (development)
	@echo "$(YELLOW)Starting development containers...$(NC)"
	docker-compose -f docker-compose.dev.yml up -d
	@echo "$(GREEN)✅ Dev API running at http://localhost:5000$(NC)"

down: ## Stop containers
	@echo "$(YELLOW)Stopping containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

restart: ## Restart containers
	@echo "$(YELLOW)Restarting containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart

# ===== LOGS & MONITORING =====

logs: ## Show container logs
	docker-compose -f $(COMPOSE_FILE) logs whatsapp-api

logs-follow: ## Follow container logs (tail -f)
	docker-compose -f $(COMPOSE_FILE) logs -f whatsapp-api

ps: ## Show running containers
	docker-compose -f $(COMPOSE_FILE) ps

stats: ## Show container resource usage
	docker stats $(CONTAINER_NAME)

exec: ## Execute shell in container
	docker-compose -f $(COMPOSE_FILE) exec whatsapp-api /bin/sh

# ===== TESTING =====

test: ## Run tests
	@echo "$(YELLOW)Running tests...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec -T whatsapp-api go test -v ./...

lint: ## Run linter
	@echo "$(YELLOW)Running linter...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec -T whatsapp-api go fmt ./...
	docker-compose -f $(COMPOSE_FILE) exec -T whatsapp-api go vet ./...

health: ## Check API health
	@echo "$(YELLOW)Checking health...$(NC)"
	curl -s http://localhost:5000/health | grep -q "ok" && echo "$(GREEN)✅ API is healthy$(NC)" || echo "$(RED)❌ API is down$(NC)"

# ===== DEPLOYMENT =====

deploy: ## Deploy to VPS (HOST=user@vps VERSION=v1.0.0)
	@if [ -z "$(HOST)" ] || [ -z "$(VERSION)" ]; then \
		echo "Usage: make deploy HOST=user@vps.com VERSION=v1.0.0"; \
		exit 1; \
	fi
	@chmod +x deploy.sh
	./deploy.sh $(HOST) $(VERSION)

deploy-k8s: ## Deploy to Kubernetes
	@if [ -z "$(NAMESPACE)" ]; then \
		echo "Usage: make deploy-k8s NAMESPACE=whatsapp"; \
		exit 1; \
	fi
	kubectl apply -f k8s-deployment.yaml -n $(NAMESPACE)
	kubectl get pods -n $(NAMESPACE)

# ===== CLEANUP =====

clean: ## Remove containers (keeps data)
	@echo "$(YELLOW)Cleaning containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

clean-all: ## Remove everything (containers, volumes, images)
	@echo "$(YELLOW)⚠️  Removing everything...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v
	docker rmi $(CONTAINER_NAME):$(VERSION) || true
	docker volume prune -f

prune: ## Clean unused Docker resources
	@echo "$(YELLOW)Pruning Docker system...$(NC)"
	docker system prune -a --volumes -f

# ===== REGISTRY =====

push: ## Push image to registry (REGISTRY=docker.io)
	@if [ "$(REGISTRY)" = "localhost" ]; then \
		echo "$(RED)❌ Cannot push to localhost$(NC)"; \
		exit 1; \
	fi
	docker tag $(CONTAINER_NAME):$(VERSION) $(REGISTRY)/$(CONTAINER_NAME):$(VERSION)
	docker push $(REGISTRY)/$(CONTAINER_NAME):$(VERSION)

pull: ## Pull image from registry
	docker-compose -f $(COMPOSE_FILE) pull

# ===== UTILITIES =====

version: ## Show version
	@echo "Version: $(VERSION)"
	@docker images $(CONTAINER_NAME):$(VERSION) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

env-example: ## Generate .env from example
	@if [ ! -f ../.env ]; then \
		cp ../.env.example ../.env; \
		echo "$(GREEN)✅ .env created from .env.example$(NC)"; \
	else \
		echo ".env already exists"; \
	fi

shell: ## Open shell in container
	docker-compose -f $(COMPOSE_FILE) exec whatsapp-api /bin/sh

# Default target
.DEFAULT_GOAL := help

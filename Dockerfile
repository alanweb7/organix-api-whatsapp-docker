# Stage 1: Builder
FROM golang:1.21-alpine AS builder

# Instalar dependências de build
RUN apk add --no-cache gcc musl-dev sqlite-dev

WORKDIR /build

# Copiar go.mod e go.sum
COPY api/go.mod api/go.sum ./

# Download dependencies
RUN go mod download

# Copiar código fonte
COPY api/ .

# Build com otimizações
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o whatsapp-api .

# ===================================
# Stage 2: Runtime
# ===================================
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata curl

# Criar usuário não-root
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copiar binário do builder
COPY --from=builder /build/whatsapp-api .

# Copiar assets se houver
COPY api/.env.example .env

# Criar diretório de dados
RUN mkdir -p /data/sessions && \
    chown -R appuser:appuser /app /data

# Trocar para usuário não-root
USER appuser

# Expor porta
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Executar aplicação
CMD ["./whatsapp-api"]

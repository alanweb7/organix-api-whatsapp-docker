param(
    [string]$Version = "latest",
    [string]$Registry = "localhost"
)

# ===================================
# Docker Build Script (Windows)
# ===================================

$ErrorActionPreference = "Stop"

# Cores
$Yellow = [ConsoleColor]::Yellow
$Green = [ConsoleColor]::Green
$Red = [ConsoleColor]::Red

# Variáveis
$ImageName = "whatsapp-api"
$FullImage = "$Registry/$ImageName`:$Version"
$DockerfilePath = Join-Path $PSScriptRoot "Dockerfile"
$ContextPath = Split-Path $PSScriptRoot

Write-Host "🐳 WhatsApp API Docker Build" -ForegroundColor $Yellow
Write-Host "Version: $Version"
Write-Host "Registry: $Registry"
Write-Host "Image: $FullImage"
Write-Host ""

# Validar Dockerfile
if (-not (Test-Path $DockerfilePath)) {
    Write-Host "❌ Dockerfile not found at $DockerfilePath" -ForegroundColor $Red
    exit 1
}

# Build
Write-Host "📦 Building Docker image..." -ForegroundColor $Yellow
docker build `
    -t "$ImageName`:$Version" `
    -t "$ImageName`:latest" `
    -f $DockerfilePath `
    $ContextPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor $Green
    
    # Tagging for registry
    if ($Registry -ne "localhost") {
        Write-Host "🏷️  Tagging for registry..." -ForegroundColor $Yellow
        docker tag "$ImageName`:$Version" $FullImage
        Write-Host "✅ Tagged as $FullImage" -ForegroundColor $Green
    }
    
    # Show image info
    Write-Host ""
    Write-Host "📊 Image Info:" -ForegroundColor $Yellow
    docker images "$ImageName`:$Version" --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}"
    
    Write-Host ""
    Write-Host "✨ Ready to use!" -ForegroundColor $Green
    Write-Host "To run: docker-compose -f docker/docker-compose.yml up -d"
    Write-Host "To push: docker push $FullImage"
} else {
    Write-Host "❌ Build failed!" -ForegroundColor $Red
    exit 1
}

#!/bin/bash

# Script para iniciar la aplicación DataVision con Docker
# Se ejecuta durante el hook ApplicationStart de CodeDeploy

set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando DataVision App con Docker..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

# Verificar que los archivos necesarios existan
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile no encontrado"
    exit 1
fi

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml no encontrado"
    exit 1
fi

echo "🐳 Verificando Docker..."
# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "🔄 Iniciando servicio Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

echo "📁 Preparando directorios..."
# Crear directorio de logs si no existe
mkdir -p /home/ubuntu/app/logs

# Asegurar permisos correctos
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

echo "▶️  Iniciando aplicación con Docker Compose..."
# Iniciar la aplicación en modo detached
docker-compose up -d datavision-app

# Esperar un momento para que la aplicación se inicie
echo "⏳ Esperando que la aplicación se inicie..."
sleep 15

echo "📋 Estado de contenedores:"
docker-compose ps

echo "📊 Logs recientes:"
docker-compose logs --tail=10 datavision-app

echo "✅ Aplicación iniciada exitosamente con Docker"
echo "🐳 Contenedor: datavision-app"
echo "📊 Dashboard disponible en: http://localhost:3000/dashboard"
echo "🔍 Health check en: http://localhost:3000/health"
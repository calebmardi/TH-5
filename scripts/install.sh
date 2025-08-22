#!/bin/bash

# Script de instalación para DataVision App con Docker
# Este script se ejecuta durante el despliegue con AWS CodeDeploy

set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando instalación de DataVision App con Docker..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

echo "🐳 Verificando instalación de Docker..."
# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "📥 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    rm get-docker.sh
fi

echo "🔧 Verificando Docker Compose..."
# Verificar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    echo "📥 Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo "📁 Preparando directorios..."
# Crear directorio de logs si no existe
mkdir -p /home/ubuntu/app/logs

# Asegurar permisos correctos
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

echo "🔨 Construyendo imagen Docker..."
# Construir la imagen Docker
docker-compose build datavision-app

echo "✅ Instalación completada exitosamente!"
echo "🐳 Imagen Docker construida y lista para despliegue"
echo "📊 Usar 'docker-compose up -d' para iniciar la aplicación"
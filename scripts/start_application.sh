#!/bin/bash

# Script para iniciar la aplicación DataVision
# Se ejecuta durante el hook ApplicationStart de CodeDeploy

set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando DataVision App..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

# Verificar que los archivos necesarios existan
if [ ! -f "app.js" ]; then
    echo "❌ Error: app.js no encontrado"
    exit 1
fi

if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json no encontrado"
    exit 1
fi

echo "📦 Verificando dependencias..."
# Verificar que node_modules exista
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependencias..."
    npm install --production
fi

echo "🔧 Configurando PM2..."
# Verificar que PM2 esté instalado
if ! command -v pm2 &> /dev/null; then
    echo "📥 Instalando PM2..."
    npm install -g pm2
fi

echo "📁 Preparando directorios..."
# Crear directorio de logs si no existe
mkdir -p /home/ubuntu/app/logs

# Asegurar permisos correctos
chown -R ubuntu:ubuntu /home/ubuntu/app
chmod +x /home/ubuntu/app/scripts/*.sh

echo "▶️  Iniciando aplicación con PM2..."
# Iniciar la aplicación
pm2 start app.js --name app \
    --log /home/ubuntu/app/logs/app.log \
    --error /home/ubuntu/app/logs/error.log \
    --out /home/ubuntu/app/logs/out.log \
    --time

# Guardar configuración de PM2
pm2 save

# Esperar un momento para que la aplicación se inicie
echo "⏳ Esperando que la aplicación se inicie..."
sleep 10

echo "📋 Estado de PM2:"
pm2 list

echo "✅ Aplicación iniciada exitosamente"
echo "📊 Dashboard disponible en: http://localhost:3000/dashboard"
echo "🔍 Health check en: http://localhost:3000/health"
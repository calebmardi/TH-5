#!/bin/bash

# Script para detener la aplicación DataVision con Docker
# Se ejecuta antes de la instalación y durante ApplicationStop

echo "🛑 Deteniendo DataVision App con Docker..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

echo "🐳 Verificando contenedores en ejecución..."
# Mostrar contenedores actuales
docker ps -a --filter "name=datavision"

echo "⏹️  Deteniendo contenedores..."
# Detener y remover contenedores
docker-compose down --remove-orphans 2>/dev/null || echo "ℹ️  No hay contenedores ejecutándose"

echo "🧹 Limpiando recursos Docker..."
# Limpiar imágenes no utilizadas (opcional)
docker image prune -f --filter "label=com.datavision.description" 2>/dev/null || echo "ℹ️  No hay imágenes que limpiar"

# Verificar que no haya procesos usando el puerto 3000
echo "🔍 Verificando puerto 3000..."
if lsof -ti:3000 > /dev/null 2>&1; then
    echo "⚠️  Puerto 3000 en uso, terminando procesos..."
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    echo "✅ Puerto 3000 liberado"
else
    echo "ℹ️  Puerto 3000 está libre"
fi

echo "🏁 Script de detención completado"
echo "📋 Estado final de contenedores:"
docker ps -a --filter "name=datavision" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No hay contenedores DataVision"
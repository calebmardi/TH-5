#!/bin/bash

# Script para detener la aplicación DataVision
# Se ejecuta antes de la instalación y durante ApplicationStop

echo "🛑 Deteniendo DataVision App..."

# Verificar si PM2 está instalado
if command -v pm2 &> /dev/null; then
    echo "📋 Verificando procesos de PM2..."
    
    # Mostrar procesos actuales
    pm2 list
    
    # Detener la aplicación si está ejecutándose
    if pm2 describe app > /dev/null 2>&1; then
        echo "⏹️  Deteniendo aplicación 'app'..."
        pm2 stop app
        echo "🗑️  Eliminando proceso 'app' de PM2..."
        pm2 delete app
        echo "✅ Aplicación detenida exitosamente"
    else
        echo "ℹ️  La aplicación 'app' no está ejecutándose en PM2"
    fi
    
    # Guardar configuración actualizada
    pm2 save
else
    echo "ℹ️  PM2 no está instalado, verificando procesos Node.js..."
    
    # Buscar y terminar procesos Node.js que ejecuten app.js
    if pgrep -f "node.*app.js" > /dev/null; then
        echo "🔍 Encontrados procesos Node.js ejecutando app.js"
        pkill -f "node.*app.js"
        echo "✅ Procesos Node.js terminados"
    else
        echo "ℹ️  No se encontraron procesos Node.js ejecutando app.js"
    fi
fi

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
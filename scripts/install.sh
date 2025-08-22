#!/bin/bash

# Script de instalación para DataVision App
# Este script se ejecuta durante el despliegue con AWS CodeDeploy

set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando instalación de DataVision App..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

echo "📦 Instalando dependencias de Node.js..."
# Instalar dependencias
npm install --production

echo "🔧 Configurando PM2..."
# Instalar PM2 globalmente si no está instalado
if ! command -v pm2 &> /dev/null; then
    echo "📥 Instalando PM2..."
    npm install -g pm2
fi

echo "🔄 Gestionando proceso de la aplicación..."
# Detener la aplicación si está ejecutándose
pm2 stop app 2>/dev/null || echo "ℹ️  La aplicación no estaba ejecutándose"

# Eliminar proceso anterior si existe
pm2 delete app 2>/dev/null || echo "ℹ️  No hay proceso anterior que eliminar"

# Iniciar la aplicación con PM2
echo "▶️  Iniciando aplicación..."
pm2 start app.js --name app --log /home/ubuntu/app/logs/app.log --error /home/ubuntu/app/logs/error.log

# Guardar configuración de PM2
pm2 save

# Configurar PM2 para que se inicie automáticamente
pm2 startup ubuntu -u ubuntu --hp /home/ubuntu 2>/dev/null || echo "ℹ️  PM2 startup ya configurado"

echo "📁 Creando directorio de logs..."
# Crear directorio de logs si no existe
mkdir -p /home/ubuntu/app/logs

echo "🔍 Verificando estado de la aplicación..."
# Verificar que la aplicación esté ejecutándose
sleep 5
pm2 status

# Verificar que la aplicación responda
echo "🌐 Verificando conectividad..."
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Aplicación desplegada exitosamente y respondiendo en puerto 3000"
else
    echo "❌ Error: La aplicación no responde en el puerto 3000"
    pm2 logs app --lines 20
    exit 1
fi

echo "🎉 Instalación completada exitosamente!"
echo "📊 Dashboard disponible en: http://localhost:3000/dashboard"
echo "🔍 Health check en: http://localhost:3000/health"

# Mostrar información del proceso
echo "📋 Estado de PM2:"
pm2 list

echo "✨ DataVision App está listo para usar!"
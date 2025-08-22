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
    
    # Detectar el sistema operativo
    if [ -f /etc/amazon-linux-release ] || [ -f /etc/system-release ]; then
        # Amazon Linux
        sudo yum update -y
        sudo yum install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -a -G docker ubuntu
    elif [ -f /etc/ubuntu-release ] || [ -f /etc/debian_version ]; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker ubuntu
    else
        # Fallback: usar el script oficial
        echo "⚠️  Sistema no reconocido, usando instalación genérica..."
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        sudo sh /tmp/get-docker.sh
        sudo usermod -aG docker ubuntu
        rm -f /tmp/get-docker.sh
    fi
    
    echo "⏳ Esperando que Docker se inicie..."
    sleep 10
else
    echo "✅ Docker ya está instalado"
fi

echo "🔧 Verificando Docker Compose..."
# Verificar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    echo "📥 Instalando Docker Compose..."
    
    # Crear directorio temporal
    sudo mkdir -p /tmp/docker-compose-install
    cd /tmp/docker-compose-install
    
    # Descargar Docker Compose con reintentos
    COMPOSE_VERSION="2.24.1"
    for i in {1..3}; do
        echo "🔄 Intento $i de descarga de Docker Compose..."
        if sudo curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; then
            break
        fi
        if [ $i -eq 3 ]; then
            echo "❌ Error: No se pudo descargar Docker Compose después de 3 intentos"
            exit 1
        fi
        sleep 5
    done
    
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Limpiar directorio temporal
    cd /home/ubuntu/app
    sudo rm -rf /tmp/docker-compose-install
else
    echo "✅ Docker Compose ya está instalado"
fi

echo "📁 Preparando directorios..."
# Crear directorio de logs si no existe
sudo mkdir -p /home/ubuntu/app/logs

# Asegurar permisos correctos
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

echo "🔍 Verificando archivos necesarios..."
# Verificar que los archivos necesarios existan
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile no encontrado"
    exit 1
fi

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml no encontrado"
    exit 1
fi

echo "🐳 Verificando que Docker esté funcionando..."
# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "🔄 Iniciando servicio Docker..."
    sudo systemctl start docker
    sleep 5
    
    # Verificar nuevamente
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Error: Docker no se pudo iniciar correctamente"
        exit 1
    fi
fi

echo "🔨 Construyendo imagen Docker..."
# Construir la imagen Docker con manejo de errores
if docker-compose build datavision-app; then
    echo "✅ Imagen Docker construida exitosamente"
else
    echo "❌ Error: Falló la construcción de la imagen Docker"
    echo "📋 Logs de Docker Compose:"
    docker-compose logs || true
    exit 1
fi

echo "🔍 Verificando imagen construida..."
# Verificar que la imagen se haya creado correctamente
if docker images | grep -q "datavision-app"; then
    echo "✅ Imagen datavision-app verificada"
else
    echo "❌ Error: La imagen datavision-app no se encontró"
    exit 1
fi

echo "✅ Instalación completada exitosamente!"
echo "🐳 Imagen Docker construida y lista para despliegue"
echo "📊 Usar 'docker-compose up -d datavision-app' para iniciar la aplicación"
echo "🔍 Verificar con 'docker-compose ps' el estado de los contenedores"
#!/bin/bash

# Script de validación para DataVision App con Docker
# Se ejecuta durante el hook ValidateService de CodeDeploy

echo "🔍 Validando DataVision App con Docker..."

# Navegar al directorio de la aplicación
cd /home/ubuntu/app

# Función para verificar el estado de la aplicación
validate_app() {
    local max_attempts=20
    local attempt=1
    local wait_time=10
    
    echo "⏳ Esperando que la aplicación esté lista..."
    
    while [ $attempt -le $max_attempts ]; do
        echo "🔄 Intento $attempt de $max_attempts..."
        
        # Verificar que el contenedor esté ejecutándose
        if docker-compose ps datavision-app | grep -q "Up"; then
            echo "🐳 Contenedor Docker está ejecutándose"
            
            # Verificar el health check interno de Docker
            local health_status=$(docker inspect --format='{{.State.Health.Status}}' datavision-app 2>/dev/null || echo "no-healthcheck")
            echo "🏥 Estado de salud del contenedor: $health_status"
            
            # Verificar conectividad HTTP
            if curl -f -s http://localhost:3000/health > /dev/null; then
                echo "🌐 Verificando endpoint de salud..."
                local health_response=$(curl -s http://localhost:3000/health)
                echo "📋 Respuesta del health check: $health_response"
                
                # Verificar que la respuesta contenga "OK"
                if echo "$health_response" | grep -q '"status":"OK"'; then
                    echo "✅ Health check exitoso"
                    
                    # Verificar dashboard
                    if curl -f -s http://localhost:3000/dashboard > /dev/null; then
                        echo "📊 Dashboard accesible"
                        
                        # Verificar API endpoints
                        if curl -f -s http://localhost:3000/api/sales > /dev/null; then
                            echo "🔗 API de ventas accesible"
                            
                            if curl -f -s http://localhost:3000/api/users > /dev/null; then
                                echo "👥 API de usuarios accesible"
                                echo "🎉 ¡Validación completada exitosamente!"
                                return 0
                            else
                                echo "❌ API de usuarios no accesible"
                            fi
                        else
                            echo "❌ API de ventas no accesible"
                        fi
                    else
                        echo "❌ Dashboard no accesible"
                    fi
                else
                    echo "❌ Health check falló - respuesta inválida"
                fi
            else
                echo "❌ No se puede conectar al endpoint de salud"
            fi
        else
            echo "❌ El contenedor no está ejecutándose correctamente"
            echo "📋 Estado del contenedor:"
            docker-compose ps datavision-app
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Validación falló después de $max_attempts intentos"
            echo "📋 Estado actual de contenedores:"
            docker-compose ps
            echo "📋 Logs recientes del contenedor:"
            docker-compose logs --tail=20 datavision-app || echo "No se pudieron obtener los logs"
            echo "🐳 Información del contenedor:"
            docker inspect datavision-app --format='{{.State.Status}}: {{.State.Error}}' 2>/dev/null || echo "No se pudo inspeccionar el contenedor"
            return 1
        fi
        
        echo "⏳ Esperando $wait_time segundos antes del siguiente intento..."
        sleep $wait_time
        attempt=$((attempt + 1))
    done
}

# Ejecutar validación
if validate_app; then
    echo "✅ DataVision App validada exitosamente con Docker"
    echo "🐳 Contenedor: datavision-app ejecutándose correctamente"
    echo "🌐 Aplicación disponible en: http://localhost:3000"
    echo "📊 Dashboard: http://localhost:3000/dashboard"
    echo "🔍 Health check: http://localhost:3000/health"
    echo "📋 Estado final:"
    docker-compose ps datavision-app
    exit 0
else
    echo "❌ Validación de DataVision App con Docker falló"
    exit 1
fi
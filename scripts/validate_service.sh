#!/bin/bash

# Script de validación para DataVision App
# Se ejecuta durante el hook ValidateService de CodeDeploy

echo "🔍 Validando DataVision App..."

# Función para verificar el estado de la aplicación
validate_app() {
    local max_attempts=30
    local attempt=1
    local wait_time=5
    
    echo "⏳ Esperando que la aplicación esté lista..."
    
    while [ $attempt -le $max_attempts ]; do
        echo "🔄 Intento $attempt de $max_attempts..."
        
        # Verificar que PM2 esté ejecutando la aplicación
        if pm2 describe app > /dev/null 2>&1; then
            local app_status=$(pm2 describe app | grep 'status' | head -1 | awk '{print $4}')
            echo "📊 Estado de PM2: $app_status"
            
            if [ "$app_status" = "online" ]; then
                echo "✅ PM2 reporta que la aplicación está online"
                
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
                echo "⚠️  PM2 reporta estado: $app_status"
            fi
        else
            echo "❌ La aplicación no está registrada en PM2"
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Validación falló después de $max_attempts intentos"
            echo "📋 Estado actual de PM2:"
            pm2 list
            echo "📋 Logs recientes:"
            pm2 logs app --lines 20 || echo "No se pudieron obtener los logs"
            return 1
        fi
        
        echo "⏳ Esperando $wait_time segundos antes del siguiente intento..."
        sleep $wait_time
        attempt=$((attempt + 1))
    done
}

# Ejecutar validación
if validate_app; then
    echo "✅ DataVision App validada exitosamente"
    echo "🌐 Aplicación disponible en: http://localhost:3000"
    echo "📊 Dashboard: http://localhost:3000/dashboard"
    echo "🔍 Health check: http://localhost:3000/health"
    exit 0
else
    echo "❌ Validación de DataVision App falló"
    exit 1
fi
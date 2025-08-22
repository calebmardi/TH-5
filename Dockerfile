# Dockerfile para DataVision App
# Multi-stage build para optimizar el tamaño de la imagen

# Etapa 1: Build
FROM node:18-alpine AS builder

# Información del mantenedor
LABEL maintainer="SENATI Student"
LABEL description="DataVision App - Aplicación de visualización de datos"

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias (incluyendo devDependencies para build)
RUN npm ci --only=production && npm cache clean --force

# Etapa 2: Producción
FROM node:18-alpine AS production

# Instalar dumb-init para manejo correcto de señales
RUN apk add --no-cache dumb-init

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S datavision -u 1001

# Crear directorio de trabajo
WORKDIR /app

# Cambiar propietario del directorio
RUN chown -R datavision:nodejs /app

# Cambiar a usuario no-root
USER datavision

# Copiar dependencias desde la etapa builder
COPY --from=builder --chown=datavision:nodejs /app/node_modules ./node_modules

# Copiar código fuente
COPY --chown=datavision:nodejs package*.json ./
COPY --chown=datavision:nodejs app.js ./

# Crear directorio para logs
RUN mkdir -p logs

# Exponer puerto
EXPOSE 3000

# Variables de entorno
ENV NODE_ENV=production
ENV PORT=3000
ENV LOG_LEVEL=info

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Comando de inicio con dumb-init
CMD ["dumb-init", "node", "app.js"]
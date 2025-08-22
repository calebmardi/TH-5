# DataVision App - Dashboard de Análisis de Datos

Una aplicación web moderna para visualización y análisis de datos de ventas y usuarios, containerizada con Docker y diseñada para despliegue automatizado con AWS CodeDeploy.

## 📁 Estructura del Proyecto

```
DataVision-App/
├── app.js                 # Aplicación principal Node.js/Express
├── package.json          # Dependencias y configuración del proyecto
├── Dockerfile            # Configuración de contenedor Docker
├── docker-compose.yml    # Orquestación de contenedores
├── .dockerignore        # Archivos excluidos del contexto Docker
├── appspec.yml          # Configuración de AWS CodeDeploy
├── README.md            # Documentación del proyecto
└── scripts/             # Scripts de despliegue Docker
    ├── install.sh       # Instalación y construcción de imagen Docker
    ├── start_application.sh   # Inicio del contenedor
    ├── stop_application.sh    # Detención del contenedor
    └── validate_service.sh    # Validación del servicio containerizado
```

## 🚀 Características

- **Dashboard interactivo** con visualización de datos de ventas y usuarios
- **API REST** para consulta de datos
- **Health check endpoint** para monitoreo
- **Gestión de procesos** con PM2
- **Despliegue automatizado** con AWS CodeDeploy
- **Logging centralizado** y manejo de errores

## 📋 Prerrequisitos

### Para desarrollo local:
- Node.js >= 16.0.0
- npm >= 8.0.0

### Para despliegue en AWS:
- Instancia EC2 con Ubuntu
- AWS CLI configurado
- Rol IAM con permisos de CodeDeploy
- CodeDeploy Agent instalado en la instancia

## 🚀 Instalación Local

### Prerrequisitos
- Docker 20.10+
- Docker Compose 2.0+
- Git

### Opción 1: Usando Docker Compose (Recomendado)

1. **Clonar el repositorio:**
   ```bash
   git clone <repository-url>
   cd DataVision-App
   ```

2. **Construir y ejecutar con Docker Compose:**
   ```bash
   # Modo producción
   docker-compose up -d datavision-app
   
   # Modo desarrollo (con hot reload)
   docker-compose up -d datavision-dev
   ```

3. **Verificar funcionamiento:**
   - Aplicación: http://localhost:3000
   - Dashboard: http://localhost:3000/dashboard
   - Health Check: http://localhost:3000/health

### Opción 2: Usando Docker directamente

1. **Construir la imagen:**
   ```bash
   docker build -t datavision-app .
   ```

2. **Ejecutar el contenedor:**
   ```bash
   docker run -d -p 3000:3000 --name datavision-app datavision-app
   ```

### Opción 3: Instalación tradicional con Node.js

1. **Instalar dependencias:**
   ```bash
   npm install
   ```

2. **Iniciar la aplicación:**
   ```bash
   npm start
   ```

## 🌐 Endpoints Disponibles

- **`/`** - Página principal
- **`/dashboard`** - Dashboard de visualización de datos
- **`/health`** - Health check del servicio
- **`/api/sales`** - API de datos de ventas
- **`/api/users`** - API de datos de usuarios

## ☁️ Despliegue con AWS CodeDeploy

### 1. Preparar la instancia EC2

```bash
# Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar PM2 globalmente
sudo npm install -g pm2

# Instalar CodeDeploy Agent
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
```

### 2. Configurar el repositorio Git

```bash
# Inicializar repositorio
git init
git remote add origin https://github.com/tuusuario/datavision-app.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

### 3. Crear aplicación en CodeDeploy

```bash
# Crear aplicación
aws deploy create-application --application-name datavision-app

# Crear grupo de despliegue
aws deploy create-deployment-group \
  --application-name datavision-app \
  --deployment-group-name datavision-group \
  --ec2-tag-filters Key=Name,Value=datavision-instance,Type=KEY_AND_VALUE \
  --service-role-arn arn:aws:iam::123456789012:role/CodeDeployRole
```

### 4. Ejecutar despliegue

```bash
# Despliegue desde GitHub
aws deploy create-deployment \
  --application-name datavision-app \
  --deployment-group-name datavision-group \
  --revision revisionType=GitHub,repository=tuusuario/datavision-app,commitId=latest
```

## 🔧 Configuración del Rol IAM

El rol `CodeDeployRole` debe tener las siguientes políticas:

- `AWSCodeDeployRole`
- `AmazonEC2ReadOnlyAccess`
- `AutoScalingReadOnlyAccess`

## 📊 Monitoreo y Logs

### Ver logs de PM2:
```bash
pm2 logs app
```

### Ver estado de procesos:
```bash
pm2 status
```

### Reiniciar aplicación:
```bash
pm2 restart app
```

### Ver logs de CodeDeploy:
```bash
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

## 🧪 Testing

```bash
# Ejecutar tests
npm test

# Verificar health check
curl http://localhost:3000/health

# Verificar API
curl http://localhost:3000/api/sales
```

## 📝 Scripts Disponibles

- `npm start` - Iniciar aplicación en producción
- `npm run dev` - Iniciar en modo desarrollo con nodemon
- `npm test` - Ejecutar tests
- `npm run lint` - Verificar código con ESLint
- `npm run build` - Preparar para producción
- `npm run deploy` - Preparar para despliegue

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👥 Autor

**SENATI Student** - Proyecto de automatización de despliegues

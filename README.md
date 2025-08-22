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

## 🚀 Despliegue Automatizado con CI/CD

### 🔄 Configuración de CI/CD con AWS CodePipeline

#### 1. **Configurar CodePipeline desde AWS Console:**

1. **Crear Pipeline:**
   - Ve a AWS CodePipeline → "Crear pipeline"
   - Nombre: `datavision-pipeline`
   - Rol de servicio: Crear nuevo rol

2. **Configurar Fuente (GitHub):**
   - Proveedor: GitHub (Version 2)
   - Conectar a GitHub y autorizar AWS
   - Repositorio: `calebmardi/TH-5`
   - Rama: `main`
   - Detección de cambios: Webhook de GitHub

3. **Configurar Build (CodeBuild):**
   - Proveedor: AWS CodeBuild
   - Crear nuevo proyecto de compilación:
     - Nombre: `datavision-build`
     - Entorno: Ubuntu, Standard, aws/codebuild/standard:5.0
     - Buildspec: Usar archivo buildspec.yml del repositorio

4. **Configurar Deploy (CodeDeploy):**
   - Proveedor: AWS CodeDeploy
   - Aplicación: `datavision-app`
   - Grupo de despliegue: `datavision-group`

#### 2. **Configuración mediante AWS CLI:**

```bash
# Crear el pipeline
aws codepipeline create-pipeline --cli-input-json file://pipeline-config.json

# Ejemplo de pipeline-config.json
{
  "pipeline": {
    "name": "datavision-pipeline",
    "roleArn": "arn:aws:iam::ACCOUNT:role/service-role/AWSCodePipelineServiceRole",
    "artifactStore": {
      "type": "S3",
      "location": "codepipeline-artifacts-bucket"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [{
          "name": "Source",
          "actionTypeId": {
            "category": "Source",
            "owner": "ThirdParty",
            "provider": "GitHub",
            "version": "1"
          },
          "configuration": {
            "Owner": "calebmardi",
            "Repo": "TH-5",
            "Branch": "main"
          },
          "outputArtifacts": [{"name": "SourceOutput"}]
        }]
      }
    ]
  }
}
```

### 🏗️ Preparación del EC2 para CodeDeploy

1. **Instalar Docker y Docker Compose:**
```bash
# Actualizar el sistema
sudo apt update

# Instalar Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalaciones
docker --version
docker-compose --version
```

2. **Instalar y configurar CodeDeploy Agent:**
```bash
# Instalar CodeDeploy Agent
sudo apt update
sudo apt install -y ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Verificar que esté ejecutándose
sudo service codedeploy-agent status
```

### 📬 Configuración de Notificaciones (Opcional)

#### 1. **Crear tópico SNS para notificaciones:**
```bash
# Crear tópico SNS
aws sns create-topic --name datavision-pipeline-notifications

# Suscribirse al tópico (reemplazar con tu email)
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT:datavision-pipeline-notifications \
  --protocol email \
  --notification-endpoint tu-email@ejemplo.com
```

#### 2. **Configurar reglas de EventBridge:**
```bash
# Crear regla para fallos de pipeline
aws events put-rule \
  --name datavision-pipeline-failed \
  --event-pattern '{
    "source": ["aws.codepipeline"],
    "detail-type": ["CodePipeline Pipeline Execution State Change"],
    "detail": {
      "state": ["FAILED"]
    }
  }'

# Agregar target SNS a la regla
aws events put-targets \
  --rule datavision-pipeline-failed \
  --targets "Id"="1","Arn"="arn:aws:sns:us-east-1:ACCOUNT:datavision-pipeline-notifications"
```

### 🔐 Variables de Entorno y Secretos

#### 1. **Configurar en AWS Systems Manager Parameter Store:**
```bash
# Crear parámetros seguros
aws ssm put-parameter \
  --name "/datavision/db/password" \
  --value "tu-password-seguro" \
  --type "SecureString"

aws ssm put-parameter \
  --name "/datavision/api/key" \
  --value "tu-api-key" \
  --type "SecureString"
```

#### 2. **Configurar en AWS Secrets Manager:**
```bash
# Crear secreto
aws secretsmanager create-secret \
  --name "prod/datavision/database" \
  --description "Credenciales de base de datos para DataVision" \
  --secret-string '{
    "username": "admin",
    "password": "tu-password-super-seguro",
    "host": "tu-rds-endpoint.amazonaws.com",
    "port": 5432
  }'
```

### 🚀 Flujo de Despliegue Automatizado

1. **Push a la rama `main`** → Activa el webhook de GitHub
2. **CodePipeline detecta cambios** → Inicia el pipeline automáticamente
3. **Etapa Source** → Descarga código desde GitHub
4. **Etapa Build (CodeBuild)** → Ejecuta `buildspec.yml`:
   - Instala dependencias con `npm install`
   - Ejecuta pruebas con `npm test`
   - Valida estructura del proyecto
   - Genera artefactos para despliegue
5. **Etapa Deploy (CodeDeploy)** → Ejecuta scripts en EC2:
   - `install.sh` → Prepara el entorno
   - `start_application.sh` → Inicia la aplicación con Docker
   - `validate_service.sh` → Verifica que todo funcione

### 🛡️ Mejores Prácticas de Seguridad

- **Roles IAM mínimos:** Asigna solo los permisos necesarios
- **Secretos seguros:** Usa Parameter Store o Secrets Manager
- **Validaciones:** Implementa health checks y rollback automático
- **Monitoreo:** Configura CloudWatch para logs y métricas
- **Backup:** Mantén snapshots de la aplicación antes de desplegar

### 🔧 Comandos Útiles para Debugging

```bash
# Ver estado del pipeline
aws codepipeline get-pipeline-state --name datavision-pipeline

# Ver logs de CodeBuild
aws logs describe-log-groups --log-group-name-prefix /aws/codebuild/datavision

# Ver despliegues de CodeDeploy
aws deploy list-deployments --application-name datavision-app

# Ver estado del CodeDeploy Agent en EC2
sudo service codedeploy-agent status
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
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

### Comandos útiles para monitoreo con Docker:

```bash
# Ver estado de contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f datavision-app

# Ver logs específicos (últimas 100 líneas)
docker-compose logs --tail=100 datavision-app

# Reiniciar el contenedor
docker-compose restart datavision-app

# Ver estadísticas de recursos
docker stats datavision-app

# Inspeccionar el contenedor
docker inspect datavision-app

# Acceder al contenedor (debugging)
docker-compose exec datavision-app sh

# Ver información de la imagen
docker images datavision-app
```

### Comandos tradicionales (sin Docker):

```bash
# Ver estado de la aplicación
pm2 status

# Ver logs en tiempo real
pm2 logs datavision-app

# Reiniciar la aplicación
pm2 restart datavision-app
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

## 🔧 Troubleshooting

### Problemas comunes con Docker:

1. **Error de permisos en appspec.yml:**
   ```
   Error: permissions setting for (/home/ubuntu/app/scripts/install.sh) is specified more than once
   ```
   **Solución:** Verificar que no haya configuraciones de permisos duplicadas en appspec.yml

2. **Docker no está ejecutándose:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Puerto 3000 ocupado:**
   ```bash
   docker-compose down
   sudo lsof -ti:3000 | xargs sudo kill -9
   ```

4. **Contenedor no se inicia:**
   ```bash
   # Ver logs detallados
   docker-compose logs datavision-app
   
   # Reconstruir imagen
   docker-compose build --no-cache datavision-app
   ```

5. **Problemas de permisos:**
   ```bash
   sudo chown -R ubuntu:ubuntu /home/ubuntu/app
   sudo chmod +x /home/ubuntu/app/scripts/*.sh
   ```

6. **Limpiar recursos Docker:**
   ```bash
   # Limpiar contenedores parados
   docker container prune -f
   
   # Limpiar imágenes no utilizadas
   docker image prune -f
   
   # Limpiar todo (cuidado en producción)
   docker system prune -af
   ```

7. **Logs de CodeDeploy:**
   ```bash
   sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
   ```

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👥 Autor

**SENATI Student** - Proyecto de automatización de despliegues

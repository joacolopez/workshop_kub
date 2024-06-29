Claro, aquí tienes el README actualizado con la aclaración de que el script "deploy.sh" automatiza todo el despliegue:

---

# Aplicación CRUD Simple con Docker

Este proyecto configura una aplicación CRUD simple utilizando NGINX, PHP y MySQL, orquestado con Docker Compose.

## Prerrequisitos

Antes de comenzar, asegurate de tener instalado:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Estructura del Proyecto

Luego de haber ejecutado el script "deploy.sh" la estructura del proyecto debería verse de la siguiente forma:

```
.
├── <stack_name>/
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── index.php
│   │   ├── nginx.conf
│   │   ├── php-fpm.conf
│   │   ├── wait-for-db.sh
│   ├── .env
│   ├── docker-compose.yml
├── deploy.sh
```

## Instrucciones de Configuración

### 1. Clonar el Repositorio

Primero, clona el repositorio en tu máquina local:

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Script de Despliegue

Ejecutar el script `deploy.sh` para configurar el stack. El script automatiza todo el proceso de despliegue y acepta las siguientes opciones:

- `-s <stack_name>`: Nombre del stack (obligatorio)
- `-m <mysql_version>`: Versión de MySQL (opcional, por defecto: 5.7)
- `-n <nginx_version>`: Versión de NGINX (opcional, por defecto: alpine)
- `-p <php_version>`: Versión de PHP (opcional, por defecto: 8.1)

Ejemplo de uso:

```bash
./deploy.sh -s my_stack -m 5.7 -n alpine -p 8.1
```

DISCLAIMER: El input de versiones está WIP. Falta resolver que los templates se configuren correctamente ingresando como variable la versión de php. De momento por default utiliza 8.1. 

### 3. Acceder a la Aplicación

Una vez que el script termine, accede a la aplicación navegando a `http://localhost` en tu navegador web.

## Detalles del Script

### `deploy.sh`

El script `deploy.sh` automatiza las siguientes tareas:

1. **Crear la Estructura de Directorios**:
   - Crea una estructura de directorios bajo el nombre del stack especificado.

2. **Crear Archivos de Entorno y Configuración**:
   - Genera un archivo `.env` con las variables de entorno de MySQL.
   - Crea los archivos de configuración necesarios (`index.php`, `nginx.conf`, `php-fpm.conf`, `wait-for-db.sh`).

3. **Construir y Desplegar los Contenedores de Docker**:
   - Detiene y elimina los contenedores existentes (sin borrar los volúmenes).
   - Construye las imágenes de Docker para reflejar cualquier cambio en la configuración.
   - Despliega los servicios con Docker Compose.

4. **Inicialización de la Base de Datos**:
   - Espera a que el servidor MySQL esté listo.
   - Crea la tabla `users` en la base de datos MySQL si no existe.

## Configuración del Proyecto

### Archivo `.env`

El archivo `.env` contiene las variables de entorno de MySQL:

```
MYSQL_ROOT_PASSWORD=imroot
MYSQL_DATABASE=testdb
MYSQL_USER=pepe
MYSQL_PASSWORD=strongpassword
```

### Archivo `docker-compose.yml`

El archivo `docker-compose.yml` define los servicios y sus configuraciones:

```yaml
version: '3.8'

services:
  nginx:
    build: ./nginx
    ports:
      - "80:80"
    env_file:
      - ./.env
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/index.php:/usr/share/nginx/html/index.php
      - ./nginx/php-fpm.conf:/etc/php81/php-fpm.d/www.conf
      - ./nginx/wait-for-db.sh:/usr/local/bin/wait-for-db.sh
    networks:
      - stack_network

  db:
    image: mysql:${MYSQL_VERSION}
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - stack_network

networks:
  stack_network:
    driver: bridge

volumes:
  db_data:
```

### Archivos de Configuración

- `nginx/index.php`: Contiene el código PHP para la aplicación CRUD.
- `nginx/nginx.conf`: Configuración de NGINX.
- `nginx/php-fpm.conf`: Configuración de PHP-FPM.
- `nginx/wait-for-db.sh`: Script para esperar a que el servidor MySQL esté listo.

## Modificar la Aplicación

Para modificar la aplicación, edita directamente los archivos de configuración. Los cambios se reflejarán en los contenedores en ejecución debido al montaje de volúmenes.

### Reconstruir los Contenedores

Si modificas el Dockerfile o cualquier archivo de configuración, debes reconstruir los contenedores:

```bash
docker-compose -f <stack_name>/docker-compose.yml build
docker-compose -f <stack_name>/docker-compose.yml up -d
```

## Solución de Problemas

- **Problemas de Conexión a la Base de Datos**:
  Asegúrate de que el contenedor de MySQL esté en funcionamiento y que las credenciales en el archivo `.env` sean correctas.

- **Conflictos de Puerto**:
En caso de que tengas en utilización el puerto 80, cambiá la asignación de puertos en el archivo `docker-compose.yml`. Por ejemplo: 8080:80.
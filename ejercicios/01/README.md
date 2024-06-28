# Workshop Contenedores - Ejercicio 01

## Descripción

Este ejercicio tiene como objetivo crear un contenedor Docker que sirva una página web estática con un archivo HTML que diga "Hola, mi nombre es: [nombre custom] ".

## Contenidos

- `index.html`: Archivo HTML que contiene el contenido de la página web.
- `Dockerfile`: Archivo para construir la imagen Docker.
- `deploy.sh`: Bash script para automatizar la construcción y despliegue del contenedor Docker.
- `test.sh`: Bash script para automatizar la verificación de que la página web se está sirviendo correctamente.

## Prerrequisitos

- Docker instalado en tu máquina.
- Bash shell (para ejecutar los scripts `deploy.sh` y `test.sh`).

## Estructura del ejercicio

```
~/path/to/exercise/
├── Dockerfile
├── README.md
├── deploy.sh
├── index.html
└── test.sh
```

## Paso a paso

### Paso 1: Crear el archivo `index.html`

Crear un archivo `index.html` con el siguiente contenido:

```html
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>Página de bienvenida</title>
</head>
<body>
 <h1>Hola, mi nombre es: [tu nombre]</h1>
</body>
</html>
```

### Paso 2: Crear el archivo `Dockerfile`

Crear un archivo `Dockerfile` con el siguiente contenido:

```Dockerfile
# Pull nginx image
FROM nginx:alpine

# Copy index.html to default nginx directory
COPY index.html /usr/share/nginx/html/index.html

# Expose 8080 port
EXPOSE 8080

# nginx exec args
CMD ["nginx", "-g", "daemon off;"]
```

### Paso 3: Crear el script `deploy.sh`

Crea un archivo `deploy.sh` con el siguiente contenido:

```sh
#!/bin/bash

# Input control and usage
if [ $# -ne 3 ]; then
    echo "This script must should be executed on the directory where the configs files for the container are"
    echo "Uso: $0 [docker_user: pepito] [image_name: basic-web] [image_version: latest]"
    exit 1
fi

# Inputs
DOCKER_USER=$1
IMAGE_NAME=$2
IMAGE_VERSION=$3

# Vars
FULL_IMAGE_NAME="$DOCKER_USER/$IMAGE_NAME:$IMAGE_VERSION"
CONTAINER_NAME="basic-webpage-container"
HOST_PORT=8080
CONTAINER_PORT=80
HTML_FILE="index.html"
NGINX_HTML_DIR="/usr/share/nginx/html"

# Docker build
echo "## Building up container ##"
docker build -t $FULL_IMAGE_NAME .

# Docker container is running? Stop it
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "## Stopping container ##"
    docker stop $CONTAINER_NAME
fi

# Docker container exists? Remove it
if [ $(docker ps -a -q -f name=$CONTAINER_NAME) ]; then
    echo "## Removing container ##"
    docker rm $CONTAINER_NAME
fi

# Docker run w/ volume. This prevents building the container if index.html file changes
echo "## Running detached container ##"
docker run -d --name $CONTAINER_NAME -p $HOST_PORT:$CONTAINER_PORT -v $(pwd)/$HTML_FILE:$NGINX_HTML_DIR/$HTML_FILE $FULL_IMAGE_NAME

#Output
echo "$ Docker container is running at: http://localhost:$HOST_PORT"
```

### Paso 4: Dar permisos de ejecución al script

Ejecutar el siguiente comando en la terminal para dar permisos de ejecución al script:

```sh
chmod +x deploy.sh
```

### Paso 5: Ejecutar el script

Ejecutar el script pasando el nombre del usuario Docker, el nombre de la imagen y la versión de la imagen como argumentos:

```sh
./deploy.sh [docker_user] [image_name] [image_version]
```

Por ejemplo, si el nombre de usuario Docker es `pepito`, el nombre de la imagen es `basic-webpage` y la versión de la imagen es `latest`, ejecutá:

```sh
./deploy.sh pepito basic-webpage latest
```

Esto crea y ejecuta una imagen Docker con el nombre `pepito/basic-webpage:latest`.

### Verificación

Abrir un navegador web e ir a `http://localhost:8080`. Deberías ver la página con el mensaje:

```
Hola, mi nombre es: [tu nombre]
```

## Añadir pruebas automatizadas

Un paso más que podemos hacer es agregar una comprobación automatizada mediante un script de bash. Para esto usaremos curl.

### Crear el script `test.sh`

Crear un archivo `test.sh` con el siguiente contenido:

```sh
#!/bin/bash

# URL a comprobar
URL="http://localhost:8080"

# Ejecutar la prueba
echo "## Running test ##"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $RESPONSE -eq 200 ]; then
    echo "OK: Page is alive!"
else
    echo "FAILED: Page is either not returning 200 or not responding at all."
    exit 1
fi
```

### Dar permisos de ejecución al script de prueba

Ejecutar el siguiente comando en la terminal para dar permisos de ejecución al script:

```sh
chmod +x test.sh
```

### Ejecutar el script de prueba

Ejecutar el script para verificar que la página web se está sirviendo correctamente:

```sh
./test.sh
```

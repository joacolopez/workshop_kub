# Proyecto de Docker Compose: Aplicación Flask con Redis

Este proyecto es un ejemplo sencillo de cómo usar Docker Compose para orquestar una aplicación web Flask que interactúa con un servicio Redis. La aplicación web mantiene un contador de visitas utilizando Redis para almacenar el número de visitas.

## Requisitos

- Docker
- Docker Compose

## Estructura del Proyecto

El proyecto contiene los siguientes archivos:

### `app.py`

Este archivo contiene el código de la aplicación Flask que interactúa con Redis. La aplicación tiene una única ruta que muestra cuántas veces ha sido vista la página.

```python
import time
import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
```
* app = Flask(__name__): Inicializa la aplicación Flask.
* cache = redis.Redis(host='redis', port=6379): Configura la conexión a Redis.
* get_hit_count: Función que incrementa el contador de visitas en Redis.
* hello: Ruta que muestra el contador de visitas.

### `requirements.txt`
Este archivo lista las dependencias necesarias para la aplicación Flask.
```
flask
redis
```
flask: Framework web ligero de Python.
redis: Cliente Redis para Python.

### `Dockerfile`
El Dockerfile define cómo construir la imagen Docker para la aplicación Flask.

```
FROM python:3.10-alpine
WORKDIR /code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask", "run", "--debug"]
```


* FROM python:3.10-alpine: Utiliza la imagen base de Python 3.10 en Alpine Linux.
* WORKDIR /code: Establece el directorio de trabajo en el contenedor.
* ENV FLASK_APP=app.py y ENV FLASK_RUN_HOST=0.0.0.0: Configura las variables de entorno para Flask.
* RUN apk add --no-cache gcc musl-dev linux-headers: Instala dependencias necesarias.
* COPY requirements.txt requirements.txt: Copia el archivo de requerimientos al contenedor.
* RUN pip install -r requirements.txt: Instala las dependencias de Python.
* EXPOSE 5000: Expone el puerto 5000.
* COPY . .: Copia el contenido del directorio actual al contenedor.
* CMD ["flask", "run", "--debug"]: Comando para iniciar la aplicación Flask.


### `compose.yaml`

Este archivo define los servicios para Docker Compose.
```
services:
  web:
    build: .
    ports:
      - "8000:5000"
  redis:
    image: "redis:alpine"
```
* web: Servicio que construye la imagen desde el Dockerfile y expone el puerto 8000 en la máquina host al puerto 5000 en el contenedor.
* redis: Servicio que utiliza una imagen pública de Redis desde Docker Hub.

## Uso


Para iniciar la aplicación, ejecuta los siguientes comandos en el directorio del proyecto:
```
docker-compose up 
```
Esto construirá las imágenes de Docker necesarias y levantará los servicios definidos en compose.yaml.

Para detener los servicios, usa el siguiente comando:


```
docker-compose down

```

## Acceso a la Aplicación
Una vez que los contenedores estén en funcionamiento, puedes acceder a la aplicación web en tu navegador en la siguiente URL: http://localhost:8000.



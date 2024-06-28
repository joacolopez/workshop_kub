# Workshop Contenedores - Ejercicio 02

Este ejercicio contiene una aplicación web sencilla utilizando Flask y Docker. La aplicación muestra un mensaje de bienvenida en la página principal.

## Estructura del ejercicio

```
~/path/to/exercise/
├── app.py
├── requirements.txt
└── Dockerfile
```

## Instrucciones para ejecutar el ejercicio

### 1. Crear el archivo `app.py`

Crear un archivo llamado `app.py` con el siguiente contenido:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hola, bienvenidos a mi pagina web"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 2. Crear el archivo `requirements.txt`

Crear un archivo llamado `requirements.txt` con el siguiente contenido:

```
Flask==2.0.1
Werkzeug==2.0.1
```

### 3. Crear el archivo `Dockerfile`

Crear un archivo llamado `Dockerfile` con el siguiente contenido:

```
# Pull python image
FROM python:3.9-slim

# Set app working directory 
WORKDIR /app

# Copy files to docker container
COPY app.py /app
COPY requirements.txt /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000
EXPOSE 5000

# app exec args
CMD ["python", "app.py"]
```

### 4. Construir y ejecutar la imagen Docker

Abre una terminal y navega al directorio donde se encuentra el proyecto. Ejecuta los siguientes comandos:

```sh
# Move to exercise directory
cd ~/path/to/exercise/

# Build docker image
docker build -t flask-app .

# Run docker image
docker run -d -p 5000:5000 flask-app
```

### 5. Probar que la aplicación está funcionando correctamente

Abrí un navegador web y navegá a `http://localhost:5000`. Deberías ver el mensaje "Hola, bienvenidos a mi pagina web".

## Documentación del proyecto

- [Documentación de Flask](https://flask.palletsprojects.com/)
- [Documentación de Docker](https://docs.docker.com/)
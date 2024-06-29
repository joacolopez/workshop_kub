# Capacitación Contenedores - Clase 2

## Descripción
Esta carpeta contiene los archivos utilizados en la segunda clase de la capacitación de contenedores. El objetivo de esta clase es aprender a utilizar Docker para crear y gestionar contenedores.

## Estructura de Carpetas
- `images/`: Contiene imágenes utilizadas en la aplicación demo.
- `demo.png`: Imagen demo utilizada en el index.html.
- `Dockerfile`: Archivo Dockerfile para crear la imagen del contenedor.
- `index.html`: Página HTML utilizada en la demo.

## Uso

### Configuración del Entorno
Antes de ejecutar la demo, asegúrate de tener Docker instalado en tu máquina. Documentación  [aquí](https://docs.docker.com/engine/install/).

### Construcción de la Imagen del Contenedor
Para construir la imagen del contenedor utilizando el `Dockerfile`, sigue estos pasos:

1. Abrí un terminal y navegá al directorio `clase2/credi-demo`:
    ```sh
    cd /ruta/a/tu/repositorio/clase2/credi-demo
    ```

2. Construye la imagen del contenedor:
    ```sh
    docker build -t credicoop-demo .
    ```

### Ejecución del Contenedor
Una vez construida la imagen, puedes ejecutar el contenedor con el siguiente comando:

```sh
docker run -d -p 8080:80 credicoop-demo
```

Este comando ejecutará el contenedor en segundo plano y mapeará el puerto 8080 de tu máquina al puerto 80 del contenedor.

### Acceso a la Aplicación
Abre tu navegador web y navega a `http://localhost:8080` para ver la aplicación demo.

## Detalles de los Archivos

### Dockerfile
El `Dockerfile` contiene las siguientes instrucciones:

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html
```

- `FROM nginx:latest`: Utiliza la imagen base de Nginx.
- `COPY index.html /usr/share/nginx/html`: Copia el archivo `index.html` al directorio de Nginx en el contenedor.

### index.html
El archivo `index.html` contiene una página HTML básica que muestra información de la capacitación. Aquí está el contenido del archivo:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Capacitación Credicoop</title>
    <style></style>
</head>
<body>
    <h1>Nueva versión del contenedor</h1>
    <p>Todo lo que se ve aquí en pantalla es modificable mediante el index.html</p>
    <p>Este index.html fue modificado durante el ejercicio</p>
    <p>Para ver el repositorio de código del contenedor entra al siguiente link
    <a href="https://github.com/joacolopez/workshop_kub/tree/main/clase1/credi-demo">Gitlab</a>.<br/>
    </p>
    <img src="images/demo.png" alt="imagen demo">
    <p><em>Gracias por confiar en nosotros</em></p>
</body>
</html>
```

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

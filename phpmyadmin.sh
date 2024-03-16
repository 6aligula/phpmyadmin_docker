#!/bin/bash

# Definiciones básicas
PROJECT_NAME="my_project"
NGINX_DIR="${PROJECT_NAME}/nginx"
FASTAPI_DIR="${PROJECT_NAME}/fastapi"

# Obtener la primera IP de la máquina
SERVER_IP=$(hostname -I | awk '{print $1}')

function crear_estructura_directorios() {
    echo "Creando estructura de directorios..."
    mkdir -p "${NGINX_DIR}" "${FASTAPI_DIR}" && return 0 || return 1
}

function configurar_nginx() {
    echo "Configurando Nginx..."
    cat <<EOF > "${NGINX_DIR}/default.conf"
server {
    listen 80;
    server_name ${PROJECT_NAME};

    location / {
        proxy_pass http://${SERVER_IP}:8000;
    }
}
EOF
    return 0
}

function crear_dockerfile_nginx() {
    echo "Creando Dockerfile para Nginx..."
    cat <<EOF > "${NGINX_DIR}/Dockerfile"
FROM nginx
COPY ./default.conf /etc/nginx/conf.d/default.conf
EOF
    return 0
}

function crear_aplicacion_fastapi() {
    echo "Creando aplicación FastAPI..."
   
    # Verificar si el directorio existe
    if [ ! -d "${FASTAPI_DIR}" ]; then
        echo "El directorio ${FASTAPI_DIR} no existe. Creándolo ahora..."
        mkdir -p "${FASTAPI_DIR}" || { echo "Error al crear el directorio ${FASTAPI_DIR}"; return 1; }
    fi

    # Crear el archivo main.py
echo "Creando aplicación FastAPI..."
   
    # Verificar si el directorio existe
    if [ ! -d "${FASTAPI_DIR}" ]; then
        echo "El directorio ${FASTAPI_DIR} no existe. Creándolo ahora..."
        mkdir -p "${FASTAPI_DIR}" || { echo "Error al crear el directorio ${FASTAPI_DIR}"; return 1; }
    fi

    # Crear el archivo main.py
cat <<EOF > "${FASTAPI_DIR}/main.py"
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Monta la carpeta 'static' en la ruta '/static'
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def read_root():
    return {"message": "Hola, mundo desde FastAPI"}
EOF

    # Crear la carpeta 'static' y un ejemplo de archivo HTML
    mkdir -p "${FASTAPI_DIR}/static"
    cat <<EOF > "${FASTAPI_DIR}/static/index.html"
<!DOCTYPE html>
<html>
<head>
    <title>Hola, mundo en FastAPI</title>
</head>
<body>
    <h1>Hola, mundo!</h1>
    <p>Esto es una página servida desde FastAPI usando archivos estáticos.</p>
</body>
</html>
EOF

    echo "Aplicación FastAPI creada exitosamente en ${FASTAPI_DIR}"
    return 0
}

function crear_dockerfile_fastapi() {
    echo "Creando Dockerfile para FastAPI..."
    cat <<EOF > "${FASTAPI_DIR}/Dockerfile"
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8
COPY . /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
EOF
    return 0
}

function crear_docker_compose() {
    if [ -f "${PROJECT_NAME}/docker-compose.yml" ]; then
        echo "El archivo docker-compose.yml ya existe."
        return 1
    else
        echo "Creando archivo docker-compose.yml..."
        cat <<EOF > "${PROJECT_NAME}/docker-compose.yml"
version: '3.8'

services:
  nginx:
    build: ./nginx
    ports:
      - "80:80"
    depends_on:
      - fastapi

  fastapi:
    build: ./fastapi
    ports:
      - "8000:80"

EOF
        return 0
    fi
}

function mostrar_mensaje_final() {
    echo "Proceso completado. Usa 'docker-compose up --build' para construir y arrancar los contenedores."
    return 0
}

function ejecutar_procesos() {
    echo "Ejecutando procesos..."
    cd "${PROJECT_NAME}" && docker-compose up --build
    return 0
}

# Control de flujo principal del script
crear_estructura_directorios && configurar_nginx && crear_dockerfile_nginx && crear_aplicacion_fastapi && crear_dockerfile_fastapi && crear_docker_compose && mostrar_mensaje_final && ejecutar_procesos || {
    echo "Error: El proceso falló. Verifica los mensajes de error anteriores para más detalles."
    exit 1
}
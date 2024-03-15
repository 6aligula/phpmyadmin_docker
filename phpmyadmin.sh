#!/bin/bash

# Definiciones básicas
PROJECT_NAME="my_project"
NGINX_DIR="${PROJECT_NAME}/nginx"
FASTAPI_DIR="${PROJECT_NAME}/fastapi"

crear_estructura_directorios() {
    echo "Creando estructura de directorios..."
    mkdir -p "${NGINX_DIR}" "${FASTAPI_DIR}" || exit 1
}

configurar_nginx() {
    echo "Configurando Nginx..."
    cat <<EOF > "${NGINX_DIR}/default.conf"
server {
    listen 80;
    server_name ${PROJECT_NAME};

    location / {
        proxy_pass http://fastapi:8000;
    }
}
EOF
}

crear_dockerfile_nginx() {
    echo "Creando Dockerfile para Nginx..."
    cat <<EOF > "${NGINX_DIR}/Dockerfile"
FROM nginx
COPY ./default.conf /etc/nginx/conf.d/default.conf
EOF
}

crear_aplicacion_fastapi() {
    echo "Creando aplicación FastAPI..."
    cat <<EOF > "${FASTAPI_DIR}/main.py"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}
EOF
}

crear_dockerfile_fastapi() {
    echo "Creando Dockerfile para FastAPI..."
    cat <<EOF > "${FASTAPI_DIR}/Dockerfile"
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8
COPY . /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
EOF
}

crear_docker_compose() {
    echo "Creando archivo docker-compose.yml..."
    cat <<EOF > "${PROJECT_NAME}/../docker-compose.yml"
# Aquí iría el contenido de tu archivo docker-compose, omitido para brevedad
EOF
}

mostrar_mensaje_final() {
    echo "Proceso completado. Usa 'docker-compose up --build' para construir y arrancar los contenedores."
}

# Ejecutar las funciones
crear_estructura_directorios
configurar_nginx
crear_dockerfile_nginx
crear_aplicacion_fastapi
crear_dockerfile_fastapi
crear_docker_compose
mostrar_mensaje_final

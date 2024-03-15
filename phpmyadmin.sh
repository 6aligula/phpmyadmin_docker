#!/bin/bash

# Definiciones básicas
PROJECT_DIR="server"
NGINX_DIR="${PROJECT_DIR}/nginx"
LOGS_DIR="${PROJECT_DIR}/logs/nginx"

function crear_estructura_directorios() {
    echo "Creando estructura de directorios..."
    mkdir -p "${NGINX_DIR}" "${LOGS_DIR}" || return 1
}

function configurar_nginx() {
    echo "Configurando Nginx..."
    # Suponiendo que ya tienes un 'nginx.conf' listo para ser copiado
    if [ -f ./nginx/nginx.conf ]; then
        cp ./nginx/nginx.conf "${NGINX_DIR}/nginx.conf"
    else
        echo "Archivo de configuración nginx.conf no encontrado. Asegúrate de tener uno en la carpeta nginx."
        return 1
    fi
    return 0
}

function crear_docker_compose() {
    echo "Creando archivo docker-compose.yml..."
    cat <<EOF > "${PROJECT_DIR}/docker-compose.yml"
version: '3.8'
services:
  web:
    build: .
    environment:
      - FLASK_ENV=development
      - FLASK_APP=app.py
    volumes:
      - .:/app
    command: flask run --host=0.0.0.0

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - web
EOF
    return 0
}

function mostrar_mensaje_final() {
    echo "Proceso completado. Usa 'docker-compose up --build' para construir y arrancar los contenedores."
    return 0
}

# Control de flujo principal del script
crear_estructura_directorios && configurar_nginx && crear_docker_compose && mostrar_mensaje_final || {
    echo "Error: El proceso falló. Verifica los mensajes de error anteriores para más detalles."
    exit 1
}

#!/bin/bash

# Definiciones básicas
PROJECT_NAME="my_project"
NGINX_DIR="${PROJECT_NAME}/nginx"
FASTAPI_DIR="${PROJECT_NAME}/fastapi"

# Crear la estructura de directorios del proyecto
mkdir -p "${NGINX_DIR}" "${FASTAPI_DIR}" || exit 1

# Nginx configuration
cat <<EOF > "${NGINX_DIR}/default.conf"
server {
    listen 80;
    server_name ${PROJECT_NAME};

    location / {
        proxy_pass http://fastapi:8000;
    }
}
EOF

# Dockerfile para Nginx
cat <<EOF > "${NGINX_DIR}/Dockerfile"
FROM nginx
COPY ./default.conf /etc/nginx/conf.d/default.conf
EOF

# FastAPI main.py
cat <<EOF > "${FASTAPI_DIR}/main.py"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}
EOF

# Dockerfile para FastAPI
cat <<EOF > "${FASTAPI_DIR}/Dockerfile"
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8
COPY . /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
EOF

# Crear docker-compose.yml en el directorio raíz del proyecto
cat <<EOF > "${PROJECT_NAME}/../docker-compose.yml"
version: '3'

services:
  nginx:
    build: ./${NGINX_DIR}
    ports:
      - "80:80"
    depends_on:
      - fastapi

  mysql:
    image: mysql:5.7
    volumes:
      - mysql_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: my_password
      MYSQL_DATABASE: my_database
      MYSQL_USER: my_user
      MYSQL_PASSWORD: my_password

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:5.1
    environment:
      PMA_HOST: mysql
      MYSQL_ROOT_PASSWORD: my_password
    ports:
      - "8080:80"

  fastapi:
    build: ./${FASTAPI_DIR}
    volumes:
      - ./${FASTAPI_DIR}:/app
    ports:
      - "8000:8000"
    depends_on:
      - mysql

volumes:
  mysql_data:
EOF

# Nota para el usuario final
echo "Estructura del proyecto creada. Usa 'docker-compose up --build' para construir y arrancar los contenedores."

#!/bin/bash

# Create the project directory structure
mkdir -p my_project/nginx my_project/fastapi
cd my_project

# Create the nginx configuration
cat <<EOF > nginx/default.conf
server {
    listen 80;
    server_name my_project;

    location / {
        proxy_pass http://fastapi:8000;
    }
}
EOF

# Create the Dockerfile for Nginx in the nginx directory
cat <<EOF > nginx/Dockerfile
FROM nginx
COPY ./default.conf /etc/nginx/conf.d/default.conf
EOF

# Create the Dockerfile for FastAPI in the fastapi directory
cat <<EOF > fastapi/Dockerfile
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8
COPY . /app
EOF

# Return to the root directory of the project to create docker-compose.yml
cd ..

# Create the docker-compose.yml file
cat <<EOF > docker-compose.yml
version: '3'

services:
  nginx:
    build: ./my_project/nginx
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
    build: ./my_project/fastapi
    volumes:
      - ./my_project/fastapi:/app
    ports:
      - "8000:8000"
    depends_on:
      - mysql

volumes:
  mysql_data:
EOF

# Build and run the containers
docker-compose up --build

# ¿Qué es docker?
Docker es una plataforma que permite **crear, distribuir y ejecutar aplicaciones en contenedores**. 
Un **contenedor** es una unidad ligera y portátil que incluye todo lo necesario para ejecutar una aplicación: código, dependencias, configuraciones, etc.
# Conceptos Básicos
| Concepto           | Descripción                                                   |
| ------------------ | ------------------------------------------------------------- |
| **Imagen**         | Plantilla lista para crear contenedores (como un ISO)         |
| **Contenedor**     | Instancia en ejecución de una imagen                          |
| **Dockerfile**     | Archivo con instrucciones para crear una imagen personalizada |
| **Docker Hub**     | Repositorio público de imágenes                               |
| **docker-compose** | Herramienta para definir y ejecutar múltiples contenedores    |

# Instalación de Docker  en Linux para sistemas basados en Debian
1. Copia y corre el siguiente conjunto de comandos:
	```
	# actualizar sistema
	sudo apt-get update
	# Instala dependencias necesarias
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	# Agrega la clave GPG oficial de Docker
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	# Agrega el repositorio de Docker
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	```
2. Instala Ultima versión de Docker
	```
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	```
3. Verifica que Docker esté instalado
	```
	docker --version
	```
 4. (Opcional) Permitir uso sin sudo
	```
	sudo usermod -aG docker $USER
	newgrp docker
	```
# Post-Instalación: Usar Docker sin sudo

Por defecto, el socket de Docker pertenece al usuario root. Para evitar escribir sudo antes de cada comando, sigue estos pasos:

Crear el grupo docker (si no existe):
```Bash
sudo groupadd docker
```
Añadir tu usuario al grupo:
```Bash
sudo usermod -aG docker $USER
```
Aplicar los cambios de grupo:
```Bash
newgrp docker
```
Verificar que funciona: Correr el siguiente comando sin sudo. Si muestra la versión, la configuración fue exitosa:
```Bash
docker version
```
# Comandos esenciales
- Ver imágenes disponibles
	```
	docker images
	```
- Descargar una imagen
	```
	docker pull nombre_imagen
	```
- Crear y correr un contenedor
	```
	docker run -d --name mi_contenedor -p 80:80 nginx
	```
- Ver contenedores en ejecución
	```
	docker ps
	```
- Ver todos los contenedores (incluso detenidos)
	```
	docker ps -a
	```
- Detener un contenedor
	```
	docker stop mi_contenedor
	```
- Eliminar un contenedor
	```
	docker rm mi_contenedor
	```
- Eliminar una imagen
	```
	docker rmi nombre_imagen
	```
- Entrar a un contenedor (modo terminal)
	```
	docker exec -it mi_contenedor bash
	```
- Ejemplo práctico con Base de Datos: Si tienes un contenedor de PostgreSQL, puedes entrar directamente a su consola de comandos de SQL:
```Bash
# Entrar directamente al cliente psql
docker exec -it pg-custom psql -U admin -d empresa
```
# Entrar directamente al cliente psql
docker exec -it pg-custom psql -U admin -d empresa
# Ejemplo de creación de contenedor con docker exec

```
docker run --name mi-postgres \
-e POSTGRES_USER=admin \
-e POSTGRES_PASSWORD=admin123 \
-e POSTGRES_DB=empresa \
-p 5432:5432 \
-d postgres:16
```
Luego entramos al contenedor con:
```
docker exec -it mi-postgres psql -U usuario -d midb
```
# Crea tu propia imagen Dockfile
Un Dockerfile es un archivo de texto plano que contiene una serie de instrucciones para automatizar la creación de imágenes de Docker. Estas instrucciones definen los pasos necesarios para construir un entorno consistente y reproducible para ejecutar una aplicación en un contenedor. En esencia, un Dockerfile actúa como una "receta" para construir una imagen de Docker. 
## Crea tu propio dockerfile
Si quieres crear una imagen como plantilla, primero debemos crear un archivo llamado dockerfile en el proyecto que quieres "dockerizar":
```
nano Dockerfile
```
Para luego pasar a editarlo.
En este caso de ejemplo crearemos una imagen que cuenta con node
1. Como primer paso debemos estructurar el proyecto a dockerizar
	```
	mi-proyecto/
	├── app/
	│   ├── Dockerfile
	│   ├── package.json
	│   ├── index.js
	│   └── .env
	├── docker-compose.yml

	```
2. Editaremos el dockerfile creado y agregaremos lo siguiente:
	```
	FROM node:18

	# Crear carpeta de trabajo
	WORKDIR /app

	# Copiar archivos de configuración
	COPY package*.json ./
	RUN npm install

	# Copiar el resto del código
	COPY . .

	# Exponer puerto
	EXPOSE 3000

	CMD ["npm", "start"]
	```
3. Construimos la imagen y la ejecutamos con un contenedor con:
	```
	# Construir la imagen
	docker build -t mi_app_node .
	# Ejecutarla en un contenedor
	docker run -d --name app -p 3000:3000 mi_app_node

	```
# Crea tu docker-compose
Docker Compose ==es una herramienta que facilita la definición, configuración y gestión de aplicaciones multicontenedor en Docker==. Utiliza un archivo YAML para definir los servicios, redes y volúmenes de la aplicación, permitiendo que todos los componentes se inicien y gestionen de manera coordinada con un solo comando.
## Crea tu propio docker-compose
primero, al igual que el dockerfile lo debemos crear pero este tendrá una extensión:
```
nano docker-compose.yml
```
para este caso utilizaremos el mismo proyecto que en dockerfile, en el archivo docker-compose.yml que creamos agregaremos node y postgress
```
version: '3.8'
services:
  web:
    build: ./app
    ports:
      - "3000:3000"
    env_file:
      - ./app/.env
    depends_on:
      - db
    volumes:
      - ./app:/app
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: mi_basededatos
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  pgdata:	
```

y ejecutamos con los siguientes comandos:
```
# Iniciar los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener y eliminar contenedores
docker-compose down
```
# Buenas Prácticas y Optimización
Para trabajar de manera profesional con Docker, es importante seguir ciertas reglas que mejoran la seguridad y el rendimiento.
## 1. Uso del archivo .dockerignore
Al igual que .gitignore, este archivo evita que archivos innecesarios se copien a la imagen (como la carpeta node_modules o archivos .env locales), reduciendo el tamaño de la imagen y evitando conflictos.
Ejemplo de .dockerignore:
```plaintext
node_modules
npm-debug.log
.git
.env
```
## 2. Diferencia entre Imagen y Contenedor
Es vital entender que las imágenes son inmutables y los contenedores son efímeros.

| Característica	<br> | Detalle                                                                              |
| ------------------- | ------------------------------------------------------------------------------------ |
| Inmutabilidad       | Las imágenes no cambian una vez construidas.                                         |
| Persistencia        | Si borras un contenedor, los datos internos se pierden, (usa Volumes para evitarlo). |
| Ligereza            | Docker comparte el Kernel del SO, a diferencia de las Máquinas Virtuales (VM).       |

## 3. Higiene del Sistema
Docker consume mucho espacio en disco con el tiempo. Usa estos comandos para mantener tu entorno limpio:
Eliminar recursos no utilizados (contenedores, redes e imágenes huérfanas):
```Bash
docker system prune
```
Eliminar volúmenes que no están siendo usados:
```Bash
docker volume prune
```
## 4. Seguridad básica

No root: Evita ejecutar procesos como usuario root dentro del contenedor si es posible.
Imágenes oficiales: Usa siempre imágenes oficiales de Docker Hub (como node:18-slim o postgres:alpine) para garantizar estabilidad y ligereza.
Variables de entorno: Nunca dejes contraseñas reales escritas directamente en el Dockerfile; usa siempre archivos .env o la sección environment en docker-compose.yml.
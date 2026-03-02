# Entorno Next.js, Variables de Entorno y Despliegue Continuo

**Módulo:** Semana 1 - Setup y Arquitectura
## 1. El Ecosistema Next.js y el App Router

React es una librería increíble para construir interfaces, pero no nos dice cómo enrutar páginas, manejar bases de datos o mejorar el SEO. Next.js es el framework construido sobre React que nos da todas estas herramientas listas para usar.

### El Paradigma del App Router
Desde su versión 13, Next.js introdujo el **App Router** (la carpeta `app/`). Este nuevo sistema cambia la forma en que pensamos sobre el renderizado:

* **Server Components por defecto:** Todo componente dentro de la carpeta `app/` se renderiza en el servidor (Backend) a menos que indiquemos lo contrario. Esto significa que pueden acceder a la base de datos directamente de forma segura y envían menos JavaScript al navegador (haciendo la app más rápida).
* **Client Components:** Si un componente necesita interactividad (como botones con `onClick`, usar estados con `useState` o efectos con `useEffect`), debemos agregar la directiva `"use client"` en la primera línea del archivo. Esto le dice a Next.js que ese pedazo de código debe ejecutarse en el navegador del usuario.

### Estructura de Carpetas del Proyecto Base
Al clonar nuestro repositorio de trabajo, encontrarán una estructura específica. Estos son los archivos clave:

* `app/layout.tsx`: Es el esqueleto principal de la aplicación. Aquí va el HTML base, el `<body>` y elementos globales como el Navbar o el Footer.
* `app/page.tsx`: Representa la ruta principal (`/` o el Home) de nuestra aplicación.
* `tailwind.config.ts`: El archivo donde configuraremos nuestros colores corporativos y tipografías para el diseño.
* `package.json`: El "manifiesto" del proyecto. Lista todas las dependencias (librerías) instaladas y los comandos (scripts) para correr el proyecto.

---

## 2. El Misterio de las Variables de Entorno (.env)

En el desarrollo de software, existen datos sensibles que **jamás** deben ser públicos: contraseñas de bases de datos, llaves secretas de APIs o tokens de autenticación.

### ¿Qué es un archivo .env?
Es un archivo de texto plano que vive en la raíz de tu proyecto y almacena "secretos" en formato `CLAVE=VALOR`. Tu código puede leer estos valores durante la ejecución, pero el archivo en sí nunca se sube a GitHub.

* **.env o .env.local:** Aquí pones tus secretos reales para trabajar en tu computadora. Este archivo **debe** estar ignorado en tu archivo `.gitignore`.
* **.env.example:** Es una plantilla que sí se sube a GitHub. Contiene los nombres de las claves necesarias, pero con valores vacíos o falsos. Sirve de guía para que otros desarrolladores sepan qué variables necesitan configurar al clonar el proyecto.

### La Regla de Oro en Next.js
Next.js tiene un sistema estricto de seguridad para las variables de entorno:

* **Variables privadas:** Si creas una variable llamada `DATABASE_URL="postgres://..."`, **solo** el código del servidor (Backend) podrá leerla. Si intentas usarla en un Client Component, Next.js te devolverá `undefined` para evitar que filtres tu contraseña a los navegadores de los usuarios.
* **Variables públicas:** Si necesitas que una variable esté disponible en el Frontend (por ejemplo, la URL pública de una API externa), **debes** agregarle el prefijo `NEXT_PUBLIC_`. Ejemplo: `NEXT_PUBLIC_API_KEY="12345"`.

---

## 3. Despliegue (Deploy) Automático en Vercel

Tener el proyecto en "localhost" es genial, pero el objetivo final es que los usuarios puedan usarlo. Para esto, utilizaremos **Vercel**, la plataforma en la nube creada por los mismos desarrolladores de Next.js.

### Por qué Vercel
Vercel ofrece un entorno de "Zero Configuration" (Cero Configuración) para Next.js. Entiende automáticamente cómo construir y servir nuestra aplicación en una red global (Edge Network) sin que tengamos que configurar servidores Linux manualmente.

### Pasos para el Deploy Inicial
1.  **Conexión:** Iniciar sesión en Vercel usando nuestra cuenta de GitHub.
2.  **Importación:** Seleccionar el repositorio del proyecto "Gestión de Tareas".
3.  **Configuración de Variables:** Antes de darle a "Deploy", Vercel nos pedirá que ingresemos las variables de entorno de producción (las mismas de nuestro `.env` local, pero para el entorno real).
4.  **Despliegue:** Al hacer clic en Deploy, Vercel descargará el código, instalará las dependencias (`npm install`), construirá el proyecto (`npm run build`) y nos dará una URL pública viva.

---

## 4. Integración Continua (CI) desde el Día 1

Configurar Vercel no es solo para tener un link final; es para establecer un flujo de **Integración Continua (CI)**. 

### ¿Qué significa esto para nuestro equipo?
A partir de hoy, cada vez que alguien haga un cambio, la nube trabajará por nosotros.

* **Deploy en Producción:** Cualquier código que se apruebe y se una (merge) a la rama `main` en GitHub, Vercel lo detectará automáticamente y actualizará la página web oficial en cuestión de minutos.
* **Preview Deployments (Entornos de Vista Previa):** Esta es la magia de Vercel. Cuando un desarrollador abra un Pull Request (PR) desde su rama (ej. `feature/modal-login`), Vercel creará una URL temporal y secreta **solo para ese código**. 

>[!IMPORTANT] Impacto en el flujo de trabajo: 
>Antes de aprobar el PR de un compañero, el equipo no solo leerá el código, sino que podrá hacer clic en el link de "Preview" que Vercel deja en GitHub y probar la funcionalidad viva en internet. ¡Si funciona bien en el Preview, es seguro unirlo a `main`!
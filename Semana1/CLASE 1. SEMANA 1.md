# Fundamentos, Entorno y Flujo de Trabajo Colaborativo

**Módulo:** Semana 1 - Setup y Arquitectura
## 1. La Arquitectura Fullstack (Modelo Cliente-Servidor)

En el desarrollo web moderno, una aplicación no es un solo bloque de código, sino una conversación constante entre dos entidades principales.

### El Cliente (Frontend)
Es todo lo que el usuario ve y con lo que interactúa. Vive en el navegador (Chrome, Safari, etc.).
* **Responsabilidades:** Renderizar la Interfaz de Usuario (UI), manejar eventos (clics, scroll, formularios), mantener el estado local y ofrecer una buena Experiencia de Usuario (UX).
* **Nuestras herramientas:** HTML, CSS (Tailwind), JavaScript/TypeScript, React y Next.js (Client Components).

### El Servidor (Backend)
Es el "cerebro" y el guardián de la aplicación. Vive en una computadora remota (en la nube) encendida 24/7.
* **Responsabilidades:** Procesar la lógica de negocio, validar datos, comunicarse con la Base de Datos, manejar la autenticación y servir archivos o datos al cliente.
* **Nuestras herramientas:** Node.js, Next.js (API Routes / Server Actions), ORMs y Bases de Datos.

### El Ciclo de Petición-Respuesta (Request/Response)
1.  El Cliente hace una **Petición (Request)** HTTP al Servidor (Ej: "Dame la lista de proyectos de este usuario").
2.  El Servidor recibe la petición, consulta la Base de Datos, procesa la información y devuelve una **Respuesta (Response)** (Ej: un JSON con los proyectos y un código de estado `200 OK`).

> [!INFO] Nota sobre Next.js:
> Tradicionalmente, Frontend y Backend vivían en repositorios separados. Next.js es un framework *Fullstack* porque nos permite escribir tanto el código del Cliente como el código del Servidor en el mismo proyecto, simplificando enormemente el despliegue y la tipificación de datos.

---

## 2. Setup del Entorno de Desarrollo

Para construir software profesional, necesitamos herramientas profesionales. No basta con un editor de texto básico.

### Node.js y npm
Node.js es un entorno de ejecución que nos permite correr JavaScript fuera del navegador (en nuestra computadora o en un servidor). 
* **npm (Node Package Manager):** Es el gestor de paquetes que viene con Node. Nos permite instalar librerías de terceros (como React, Tailwind, o Prisma) en lugar de reinventar la rueda.
* *Verificación en consola:* 
```bash
    node -v
    npm -v
```

### Visual Studio Code (VSCode)
Es el estándar de la industria. Para este curso, estandarizaremos nuestro entorno con las siguientes extensiones obligatorias:
1.  **ESLint:** Encuentra y arregla problemas en el código JavaScript/TypeScript en tiempo real.
2.  **Prettier - Code formatter:** Formatea el código automáticamente al guardar (adiós a las peleas por espacios o tabulaciones).
3.  **GitLens:** Nos permite ver quién escribió cada línea de código, en qué commit y por qué (esencial para trabajo en equipo).
4.  **Prisma:** (La usaremos más adelante) Autocompletado y resaltado de sintaxis para nuestra base de datos.

---

## 3. Flujo de Trabajo Colaborativo (Git y GitHub)

En este curso, no trabajaremos solos. Trabajarán en un único repositorio centralizado. Si todos editamos el código al mismo tiempo en la misma rama, el proyecto colapsará. Aquí entra el **Feature Branch Workflow** (flujo de trabajo de ramas de características) aísla el desarrollo de nuevas funcionalidades, correcciones o experimentos en ramas separadas creadas desde `main` o `master`. Esto permite trabajar en paralelo, realizar revisiones de código mediante _pull requests_ y mantener la rama principal siempre estable y lista para producción.
### Conceptos Clave
* **Git:** El motor local de control de versiones. Toma "fotografías" (commits) de tu código.
* **GitHub:** La plataforma en la nube donde guardamos nuestro código y colaboramos.
* **Rama `main` (o `master`):** Es código sagrado. Lo que está en `main` debe funcionar perfectamente porque es lo que está en producción (lo que ven los usuarios). **Nadie sube código directamente a `main` o `dev`.**

### El Flujo de Trabajo Diario
1.  **Sincronizar local:** Antes de empezar tu día, descargas los últimos cambios aprobados.
    ```bash
    git checkout main
    git pull origin main
    ```
2.  **Crear tu rama de trabajo:** Creas un universo paralelo para tu tarea específica.
    ```bash
    git checkout -b feature/nombre-de-tu-tarea
    # Ejemplo: git checkout -b feature/crear-modal-login
    ```
3.  **Trabajar y hacer Commits:** Escribes tu código y guardas tu progreso con mensajes descriptivos.
    ```bash
    git add .
    git commit -m "feat: agrega formulario de login con validaciones"
    ```
4.  **Subir tu rama a GitHub:**
    ```bash
    git push origin feature/nombre-de-tu-tarea
    ```

---

## 4. Pull Requests (PR) y Merge Conflicts

### Pull Requests (Peticiones de Integración)
Una vez que terminas tu tarea y subes tu rama, no la unes a `main` tú mismo. Abres un **Pull Request (PR)** en GitHub.
* Un PR es una petición formal a tu equipo: *"Terminé mi tarea, revisen mi código y si está bien, únanlo a `main`"*.
* En este curso, **yo (el instructor) y al menos un compañero de equipo deberemos aprobar el PR** antes de que se pueda integrar. Esto garantiza la calidad del código.

### Merge Conflicts (Conflictos de Fusión)
Ocurren cuando dos personas editaron *exactamente el mismo archivo y la misma línea* en diferentes ramas, y Git no sabe cuál versión conservar.
* **No entres en pánico:** Los conflictos son normales, no significa que rompiste nada.
* **Resolución en VSCode:** Al intentar hacer un merge (o un pull) y detectar conflicto, VSCode resaltará el código en colores y te dará opciones:
    * *Accept Current Change* (Mantener lo tuyo)
    * *Accept Incoming Change* (Mantener lo de tu compañero)
    * *Accept Both Changes* (Mantener ambos y tú arreglas la lógica)
* *Regla de oro:* Si no estás seguro de qué hace el código de tu compañero, **habla con él antes de resolver el conflicto**.

---

## 5. Presentación del Proyecto Final

Durante este mes, no haremos ejercicios aislados. Vamos a construir un **Sistema de Gestión de Tareas (tipo Trello o Jira)**.

* **El Escenario:** Somos una startup tecnológica. Yo soy el *Tech Lead / Product Manager* (líder técnico), y ustedes son los desarrolladores Fullstack.
* **Metodología:** Cada uno de ustedes será dueño de un "módulo" (ej. Autenticación, Creación de Tareas, Tableros, etc.). Desarrollarán desde la base de datos hasta la interfaz visual de esa funcionalidad.
* **Dinámica de Clase:** No me verán escribir código durante 2 horas. Las clases serán para explicar arquitectura, revisar sus Pull Requests en vivo (Code Review) y desbloquearlos de problemas complejos. Ustedes programarán de forma asíncrona basándose en las tareas asignadas.

> [!IMPORTANT] Tu primera tarea: 
> Clona el repositorio base que les he compartido en el chat, asegúrate de que puedes correrlo localmente (`npm run dev`) y explora la estructura de carpetas.
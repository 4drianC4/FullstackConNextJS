**Metodología:** Desarrollo por "Verticales" (Slices) y Code Review

## 1. Visión General del Proyecto

Construiremos desde cero una plataforma de gestión de proyectos basada en la metodología Kanban. Los usuarios podrán registrarse, crear espacios de trabajo, administrar tableros y mover tareas entre diferentes estados de progreso. 

El objetivo principal no es solo que el código funcione, sino simular un **entorno de trabajo real**. Todo el código se integrará en un único repositorio centralizado, y cada avance deberá ser revisado y aprobado mediante *Pull Requests*.

## 2. Stack Tecnológico

* **Frontend (Cliente):** Next.js (App Router), React, Tailwind CSS, Zustand (Estado global), React Hook Form + Zod (Formularios).
* **Backend (Servidor):** Next.js (Route Handlers / API Routes), Node.js.
* **Base de Datos y ORM:** PostgreSQL (alojado en Supabase/Neon), Prisma ORM.
* **Infraestructura y Herramientas:** Vercel (CI/CD y Hosting), GitHub (Control de versiones), Git, ESLint/Prettier.

## 3. Arquitectura y Metodología de Trabajo

Para evitar bloqueos y conflictos graves de código, utilizaremos el enfoque de **Desarrollo Vertical**. 

En lugar de que una persona haga "todo el frontend" y otra "todo el backend", cada desarrollador será dueño de una **funcionalidad completa de extremo a extremo (Fullstack)**.

### El Flujo de Vida de una Tarea (Feature Branch Workflow)
1.  **Asignación:** El desarrollador recibe su módulo (Ej: "Sistema de Comentarios").
2.  **Diseño DB:** Modifica el `schema.prisma` para agregar los modelos necesarios.
3.  **Backend:** Construye y prueba los endpoints RESTful (`POST`, `GET`, `DELETE`) usando Thunder Client.
4.  **Frontend:** Conecta el maquetado provisto con la API que acaba de crear.
5.  **Integración:** Abre un Pull Request (PR) en GitHub. El código solo se une a `main` tras la aprobación (Code Review) del Tech Lead (Instructor) y de sus compañeros.

---

## 4. Módulos de Desarrollo
El proyecto se divide en módulos aislados pero interconectados. Cada estudiante es responsable de uno de los siguientes:

1.  **Autenticación y Sesión:** Modelos de usuario y protección de rutas.
2.  **Espacios de Trabajo (Workspaces):** Contenedores principales de los equipos.
3.  **Tableros (Boards):** Creación y gestión visual de proyectos.
4.  **Columnas (Listas):** Estados personalizables (To-Do, Doing, Done).
5.  **Tareas (Core):** Creación y edición base de las tarjetas de trabajo.
6.  **Asignaciones y Fechas:** Lógica de `due dates` y responsables de tareas.
7.  **Sistema de Etiquetas (Tags):** Categorización visual mediante relaciones muchos-a-muchos.
8.  **Comentarios:** Historial de notas dentro de una tarea.
9.  **Buscador Global:** Endpoint de búsqueda indexada en toda la plataforma.
10. **Panel de Estadísticas (Analytics):** Dashboard de resumen de productividad del workspace.

---

## 5. Criterios de Éxito y Calificación

El proyecto se considerará exitoso y aprobado si cumple con:
* **Funcionalidad:** La característica asignada funciona en el entorno de producción (Vercel) sin errores de consola o caídas del servidor (`HTTP 500`).
* **Calidad de Código:** No hay variables sin usar, el tipado de TypeScript es estricto (cero `any`), y el código está formateado.
* **Colaboración:** El estudiante ha participado activamente en la revisión de al menos 2 Pull Requests de sus compañeros, dejando comentarios constructivos.
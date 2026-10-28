---
tipo: indice
aliases:
  - Inicio del curso
  - Fullstack con Next.js
tags:
  - curso/fullstack
---

# Desarrollo Fullstack con Next.js — Gestión de Discoteca

Curso práctico de **20 clases de 90 minutos** (30 horas presenciales), con tareas entre sesiones. Construiremos colaborativamente una aplicación pequeña y desplegada: backend primero, frontend después e integración al final, incluyendo Docker y desarrollo asistido por IA con OpenCode y NVIDIA.

> [!tip] Empieza por Obsidian
> Abre esta carpeta como bóveda y sigue [[Recursos/Obsidian - Guia del curso|la guía de navegación]]. Los índices, backlinks y etiquetas conectan clases, proyecto y recursos sin requerir plugins comunitarios.

## Descripción y objetivos

El curso presupone JavaScript, HTML y CSS. React y TypeScript se introducen desde un nivel inicial y se practican sobre el proyecto. El objetivo es comprender y entregar un MVP; no prometer dominio de todo el ecosistema en cuatro semanas.

Al finalizar podrás:

- Diseñar datos relacionales y aplicar migraciones con Prisma.
- Construir APIs REST con validación, autenticación y autorización.
- Organizar código mediante funcionalidades verticales.
- Crear interfaces React tipadas, formularios y flujos conectados al backend.
- Usar Docker para el entorno local y ejecutar la aplicación con Compose.
- Colaborar mediante ramas, PR, pruebas y controles de CI.
- Desplegar y verificar una aplicación con datos persistentes.
- Planificar, revisar y depurar cambios con OpenCode sin delegar la comprensión.

## Temario — exactamente 20 clases

### Semana 1 — Introducción y fundamentos del backend

[[Semana1/INDICE|Índice y entregable de la semana]]

- [[Semana1/CLASE 1|Clase 1]] — Introducción, entorno y trabajo colaborativo.
- [[Semana1/CLASE 2|Clase 2]] — TypeScript aplicado al backend.
- [[Semana1/CLASE 3|Clase 3]] — Docker I - PostgreSQL local.
- [[Semana1/CLASE 4|Clase 4]] — Modelado, Prisma y datos de prueba.
- [[Semana1/CLASE 5|Clase 5]] — HTTP, REST y primera funcionalidad vertical.

### Semana 2 — Desarrollo del backend

[[Semana2/INDICE|Índice y entregable de la semana]]

- [[Semana2/CLASE 6|Clase 6]] — CRUD, servicios y manejo de errores.
- [[Semana2/CLASE 7|Clase 7]] — Relaciones, reglas de negocio y transacciones.
- [[Semana2/CLASE 8|Clase 8]] — Autenticación y sesiones.
- [[Semana2/CLASE 9|Clase 9]] — Autorización y protección de operaciones.
- [[Semana2/CLASE 10|Clase 10]] — Pruebas e integración del backend.

### Semana 3 — Desarrollo del frontend

[[Semana3/INDICE|Índice y entregable de la semana]]

- [[Semana3/CLASE 11|Clase 11]] — React I - Componentes y props.
- [[Semana3/CLASE 12|Clase 12]] — React II y rutas de Next.js.
- [[Semana3/CLASE 13|Clase 13]] — Interfaz, Tailwind y accesibilidad.
- [[Semana3/CLASE 14|Clase 14]] — Formularios con React Hook Form y Zod.
- [[Semana3/CLASE 15|Clase 15]] — Consumo del backend y mutaciones.

### Semana 4 — Integración, Docker, IA y cierre

[[semana4/INDICE|Índice y entregable de la semana]]

- [[semana4/CLASE 16|Clase 16]] — Integración fullstack y pruebas de flujos.
- [[semana4/CLASE 17|Clase 17]] — Docker II, CI y despliegue.
- [[semana4/CLASE 18|Clase 18]] — IA I - Desarrollo con OpenCode y NVIDIA.
- [[semana4/CLASE 19|Clase 19]] — IA II - Depuración y revisión con OpenCode.
- [[semana4/CLASE 20|Clase 20]] — Presentación, evaluación y retrospectiva.

## Tecnologías

| Área | Elección del curso |
| --- | --- |
| Lenguaje y runtime | TypeScript 5, Node.js 22 (22.18 o superior dentro de esa línea) y npm |
| Aplicación | Next.js 16, App Router y React 19 |
| Interfaz | Tailwind CSS 4, componentes seleccionados de shadcn/ui |
| Formularios | React Hook Form 7, Zod 4 y resolvers compatibles |
| Datos | PostgreSQL 16, Prisma 7 y adaptador pg |
| Identidad | Auth.js / NextAuth 5 beta, credenciales del personal y bcryptjs |
| Calidad | ESLint, Vitest, un flujo con Playwright y GitHub Actions |
| Infraestructura | Docker Compose v2, Vercel y PostgreSQL alojado |
| IA | OpenCode 1 como agente; proveedor NVIDIA según acceso y cuota disponible |

[[Recursos/Stack y entorno|Instalación, scripts, versiones exactas y checklist del instructor]]. Las familias anteriores son una decisión docente; la aplicación debe fijar las versiones exactas y su lockfile. Auth.js 5 está tratado explícitamente como prerelease; no mezclar ejemplos v4/v5. Este repositorio es de apuntes: todavía no contiene una aplicación ejecutable ni su lockfile.

Zustand, TanStack Query, optimistic UI, modo oscuro y caché avanzada son ampliaciones, no requisitos de aprobación.

## Proyecto y arquitectura

[[Proyecto/1. Sistema de Gestion de Discoteca|Sistema de gestión de discoteca]]: usuarios y acceso, eventos, entradas e ingreso, catálogo de bebidas, ventas de barra y reservas de mesas. [[Proyecto/2. Tareas por funcionalidad|Tareas y equipos]] · [[Proyecto/6. Modelo de datos|Modelo de datos]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical y contratos]].

Cada alumno desarrolla una tarea de extremo a extremo dentro de su funcionalidad. La secuencia de enseñanza separa backend y frontend, pero la estructura del proyecto los reúne por dominio. No se asigna a una persona únicamente la base de datos y a otra únicamente la interfaz.

Fuera del MVP: pagos reales, facturación fiscal, inventario de ingredientes, QR, tiempo real y reportes avanzados. Los datos serán sintéticos.

## Requisitos y preparación

- JavaScript: funciones, arrays, objetos, módulos, promesas y async/await. HTML y CSS. Estos contenidos no se vuelven a enseñar.
- Terminal básica, Git, Node.js, editor, Docker y Obsidian.
- Cuentas de GitHub y del hosting/base elegidos; para IA, acceso a un proveedor NVIDIA disponible sin pago para la práctica.
- Trabajo fuera de clase: referencia de 45–60 minutos entre sesiones y más si la tarea lo requiere. Registrar bloqueos antes de la siguiente clase.

Hasta 18 alumnos; propuesta inicial de seis equipos de hasta tres, ajustable a inscritos. El instructor prepara el repositorio de aplicación, contratos y coordinación de migraciones. Los alumnos lo construyen durante el curso.

## Metodología y evaluación

Explicación breve, práctica guiada, tarea del módulo y PR revisado. La integración se revisa continuamente, con hitos al cerrar backend, frontend y despliegue. [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|Guía de contribución]] · [[Proyecto/5. Evaluacion y entregables|Rúbrica y entregables]].

La clase 1 introduce Obsidian. Las dos clases de IA enseñan a programar y revisar con OpenCode; no exigen añadir una API de IA al producto ni contratar un plan. Si falta cuota, hay una práctica equivalente de revisión sin inferencia.

## Mapa de recursos

- [[Recursos/Obsidian - Guia del curso|Obsidian: enlaces, propiedades y grafo local]].
- [[Recursos/Stack y entorno|Stack y entorno de la aplicación]].
- [[Recursos/Conceptos y conexiones|Mapa de conceptos y dependencias]].
- [[Recursos/Docker/Docker|Docker: clases y referencia]].
- [[Recursos/Fullstack con IA/Programemos como si estuviéramos en la matrix... o quizá si estamos|OpenCode y NVIDIA: clases y referencia]].
- [[Recursos/Creación local de proyectos/0. División para la creación del todo|Recetas de creación local]].

Los dibujos existentes se conservan como material visual complementario; pueden contener ejemplos de proyectos anteriores. El esquema y las notas actuales de Discoteca son la referencia del curso.

## Documentación oficial

[Next.js](https://nextjs.org/docs) · [React](https://react.dev/learn) · [TypeScript](https://www.typescriptlang.org/docs/) · [Prisma 7](https://www.prisma.io/docs/orm/v7) · [Auth.js](https://authjs.dev/) · [Tailwind](https://tailwindcss.com/docs) · [Zod](https://zod.dev/) · [Docker](https://docs.docker.com/) · [OpenCode](https://opencode.ai/docs/) · [NVIDIA](https://build.nvidia.com/) · [Obsidian](https://help.obsidian.md/).

> [!info] Alcance del repositorio
> Aquí están las clases, ejemplos y contratos para enseñar. El código, los secretos, los workflows y el despliegue del producto se crean en un repositorio de aplicación separado. Las recetas requieren probarse allí antes de cada edición.

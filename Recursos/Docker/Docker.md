---
tipo: mapa
tags:
  - backend/docker
---
# Docker — Mapa de estudio

[[README|Inicio]] · [[Recursos/Conceptos y conexiones|Conceptos]]

El contenido completo se encuentra en sus clases, con práctica, tarea y criterios:

- [[Semana1/CLASE 3|Docker I: PostgreSQL, puertos y persistencia]].
- [[semana4/CLASE 17|Docker II: Next.js, Compose, CI y despliegue]].
- [[Recursos/Stack y entorno|Variables, versiones y scripts]].

## Recordatorio

Usar `docker compose`, no asumir el binario antiguo `docker-compose`. Imagen no equivale a contenedor; una base persiste en un volumen. `depends_on` necesita `service_healthy` y un healthcheck para esperar disponibilidad, no solamente inicio.

Dentro de Compose la URL usa `db`; fuera usa `localhost` y el puerto publicado. Las contraseñas de `.env` siguen siendo secretos y no se copian a la imagen. `.dockerignore` evita incluirlas en el contexto de build.

No usar `down -v`, `volume prune` o `system prune --volumes` como limpieza rutinaria del curso: pueden destruir datos. Antes de borrar un volumen, identificar su uso y contar con copia si debe conservarse.

## Fuentes

[Instalación](https://docs.docker.com/engine/install/) · [Compose](https://docs.docker.com/compose/) · [Orden y salud](https://docs.docker.com/compose/how-tos/startup-order/) · [Next.js self-hosting](https://nextjs.org/docs/app/guides/self-hosting).

---
tipo: mapa
tags:
  - backend/docker
---
# Docker: una ballena para que el entorno deje de ser una leyenda local

[[README|Inicio]] · [[Recursos/Conceptos y conexiones|Conceptos]]

Si la aplicación funciona únicamente en la computadora del elegido, tenemos una anécdota, no un entorno reproducible. Estas clases explican cómo preparar el nuestro; incluyen práctica, tarea y criterios para comprobar que no fue suerte:

- [[Semana1/CLASE 3|Docker I: PostgreSQL, puertos y persistencia]].
- [[semana4/CLASE 17|Docker II: Next.js, Compose, CI y despliegue]].
- [[Recursos/Stack y entorno|Variables, versiones y scripts]].

## Recordatorio

La ballena transporta contenedores, no excusas. Conviene saber qué llevamos dentro antes de zarpar.

Usar `docker compose`, no asumir el binario antiguo `docker-compose`. Una imagen es la receta; el contenedor es la ejecución. Los datos de PostgreSQL se conservan en un volumen, porque «reinicié y desapareció todo» no es una política de almacenamiento.

`depends_on` necesita `service_healthy` y un healthcheck para esperar disponibilidad. Que PostgreSQL haya empezado a arrancar no significa que ya esté listo para recibir visitas.

Dentro de Compose la URL usa `db`; fuera usa `localhost` y el puerto publicado. Cada sitio tiene su dirección: llamar a tu propia puerta no conecta mágicamente con el vecino.

Las contraseñas de `.env` siguen siendo secretos y no se copian a la imagen. `.dockerignore` las deja fuera del contexto de build. Una caja con una ballena dibujada no convierte una contraseña pública en privada.

> [!warning] Limpiar no significa demoler
> No usar `down -v`, `volume prune` o `system prune --volumes` como limpieza rutinaria del curso: pueden destruir datos. Antes de borrar un volumen, identificar su uso y contar con copia si debe conservarse. La satisfacción de liberar espacio dura menos que volver a cargar toda la base a mano.

## Fuentes

Para consultar instrucciones sin depender del primo que una vez instaló Docker:

[Instalación](https://docs.docker.com/engine/install/) · [Compose](https://docs.docker.com/compose/) · [Orden y salud](https://docs.docker.com/compose/how-tos/startup-order/) · [Next.js self-hosting](https://nextjs.org/docs/app/guides/self-hosting).

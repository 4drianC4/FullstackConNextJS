---
tipo: clase
clase: 3
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 3 — Docker I - PostgreSQL local

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 2|Clase 2]] · [[Semana1/CLASE 4|Clase 4]] →

> [!abstract] Objetivo
> Levantar PostgreSQL reproduciblemente y conservar los datos aunque se recree el contenedor.

## Antes de empezar

Repasa [[Semana1/CLASE 2|Clase 2]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Imagen, contenedor y volumen

La imagen es la plantilla; el contenedor ejecuta un proceso; el volumen conserva datos fuera de la capa efímera del contenedor. Docker no es una máquina virtual completa. Docker Compose describe los servicios del entorno.

Instalar Docker Engine y el plugin Compose en Linux siguiendo [la guía oficial](https://docs.docker.com/engine/install/); en Windows/macOS usar la instalación oficial adecuada al equipo. No copiar un repositorio Debian con nombre de versión distinto al sistema real. Verificar:

```bash
docker version
docker compose version
```

En Linux, el grupo `docker` permite operaciones con privilegios equivalentes a root; no es solo una comodidad inocua. Si Docker Desktop está activo, seleccionar el contexto correcto.

### compose.yaml de la aplicación

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER:?define POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?define POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:?define POSTGRES_DB}
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 5s
      timeout: 5s
      retries: 10
volumes:
  pgdata:
```

Crear `.env` con valores locales propios, siguiendo [[Recursos/Stack y entorno|la plantilla de entorno]]. Los valores reales no se versionan.

```bash
docker compose up -d db
docker compose ps
docker compose logs db
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
docker compose down
```

`down` conserva el volumen. `down -v` lo elimina: no lo uses como forma habitual de reiniciar. Si el puerto 5432 está ocupado, publicar 5433 y actualizar la URL local. Cambiar una contraseña en `.env` no cambia automáticamente la de una base ya inicializada.

La aplicación se ejecuta por ahora en el host: `DATABASE_URL` utiliza `localhost`. Dentro de Compose utilizará `db`; lo retomamos en la clase 17.

## Práctica guiada

Crear la base, insertar un dato con SQL y comprobar que sigue después de down/up.

## Tarea para casa

Documentar comandos y solucionar un conflicto de puerto sin borrar datos. Subir compose.yaml y .env.example.

## Criterios de finalización

- [ ] La base aparece healthy.
- [ ] El volumen conserva datos.
- [ ] Puedes explicar localhost frente al nombre db.

## Conexiones

[[Recursos/Docker/Docker|Mapa de Docker]] · [[semana4/CLASE 17|Clase 17]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 2|Clase 2]] · [[Semana1/CLASE 4|Clase 4]] →

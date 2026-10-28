---
tipo: clase
clase: 17
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 17 — Docker II, CI y despliegue

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[semana4/CLASE 16|Clase 16]] · [[semana4/CLASE 18|Clase 18]] →

> [!abstract] Objetivo
> Ejecutar la aplicación en contenedores y preparar CI y un despliegue verificable.

## Antes de empezar

Repasa [[semana4/CLASE 16|Clase 16]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Next.js en Docker

Mantener `next.config.ts` y añadir `output: "standalone"`. El build necesita generar Prisma; configurar `build: prisma generate && next build`. La base debe ser accesible durante build solo si alguna página consulta datos al prerenderizar; para datos privados usar renderizado por petición y no ejecutar migraciones durante build.

Este Dockerfile parte de una aplicación con `public/`, package-lock y scripts del stack:

```dockerfile
FROM node:22-bookworm-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm ci
COPY . .
ARG DATABASE_URL=postgresql://unused:unused@localhost:5432/build_only
ENV DATABASE_URL=$DATABASE_URL
RUN npm run build

FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static ./.next/static
COPY --from=build --chown=node:node /app/public ./public
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

La URL ficticia solo permite cargar la configuración de Prisma al generar; no contiene credenciales reales ni permite ejecutar consultas. Si el build intenta consultar la base, corregir el renderizado en lugar de copiar secretos dentro de la imagen.

`.dockerignore`:

```text
node_modules
.next
.git
.env*
!.env.example
*.log
```

Añadir `web` al mismo `compose.yaml` de la clase 3:

```yaml
  web:
    build: .
    ports:
      - "127.0.0.1:3000:3000"
    environment:
      DATABASE_URL: ${DATABASE_URL_DOCKER:?define DATABASE_URL_DOCKER}
      AUTH_SECRET: ${AUTH_SECRET:?define AUTH_SECRET}
      APP_ORIGIN: http://localhost:3000
      AUTH_URL: http://localhost:3000
      AUTH_TRUST_HOST: "true"
    depends_on:
      db:
        condition: service_healthy
```

`DATABASE_URL_DOCKER` usa `db:5432`, con las mismas credenciales de PostgreSQL. Para este ensayo local confiamos en el host del contenedor; en producción configurar el dominio y proxy reales. No montar el código del host sobre los artefactos de producción.

```bash
docker compose up -d db
npx prisma migrate deploy
npm run db:seed
docker compose up --build -d web
docker compose logs web
```

Los comandos Prisma del host usan DATABASE_URL con localhost. El runtime usa db. El seed del ejemplo se prepara como script en la clase 4 y el stack. No volver a sembrar cuentas o datos de prueba en cada arranque de producción.

### CI en GitHub Actions

Crear `.github/workflows/ci.yml` **en el repositorio de aplicación**:

```yaml
name: CI
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: postgresql://unused:unused@localhost:5432/build_only
      AUTH_SECRET: ci-only-not-a-production-secret-0123456789
      APP_ORIGIN: http://localhost:3000
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npx prisma generate
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test
      - run: npm run build
```

Este job ejecuta pruebas puras; las de integración/E2E requieren además PostgreSQL de test, migraciones, seed y servidor. Configurar ese job con el instructor según los tests del grupo, sin apuntar a producción. El deploy automático no sustituye CI.

### Despliegue en Vercel

Conectar el repositorio de aplicación, configurar variables privadas y una base PostgreSQL alojada. Revisar límites del plan elegido antes de abrir cuentas. Usar una base separada para previews: las URLs de preview no son secretas por defecto.

Aplicar `prisma migrate deploy` una vez por entrega contra la base correcta, antes de activar código incompatible. Configurar origen/dominio, callbacks de autenticación y limitación de intentos; crear el primer administrador por un procedimiento controlado. Verificar login, permisos y persistencia después del despliegue. Docker es otro modo de ejecución, no algo que Vercel necesite para desplegar Next.js.

## Práctica guiada

Arrancar la aplicación mediante Compose y ejecutar controles desde un clon limpio.

## Tarea para casa

Desplegar, comprobar los flujos críticos y documentar variables, migraciones y recuperación. No incluir secretos en capturas.

## Criterios de finalización

- [ ] La imagen construye y usa usuario no root.
- [ ] CI ejecuta lint, tipos, tests y build.
- [ ] La URL desplegada permite los flujos autorizados.

## Conexiones

[[Semana1/CLASE 3|Clase 3]] · [[Recursos/Stack y entorno|Scripts y versiones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[semana4/CLASE 16|Clase 16]] · [[semana4/CLASE 18|Clase 18]] →

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

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 16|Clase 16]] · [[semana4/CLASE 18|Clase 18]] →

> [!abstract] Objetivo
> Ejecutar la aplicación en contenedores y preparar CI y un despliegue verificable.

## Antes de empezar

Repasa [[semana4/CLASE 16|Clase 16]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Desarrollo, build y ejecución productiva

El servidor de desarrollo prioriza edición rápida y mensajes útiles. El build genera artefactos preparados para ejecutar la aplicación. El runtime productivo utiliza esos artefactos con configuración de su entorno. No son tres nombres de un mismo comando.

Una imagen reproducible necesita dependencias, código y un procedimiento de build. Una imagen pequeña de runtime no debería llevar herramientas y archivos innecesarios para servir la aplicación. Un Dockerfile multi-stage permite construir en una etapa y copiar solo el resultado necesario a otra.

### Qué contiene standalone

La opción standalone prepara una salida de Next.js con archivos necesarios para ejecutar el servidor generado. Los assets de `.next/static` y `public` se copian por separado en nuestra receta. Si la aplicación no tiene public, crea esa carpeta con un archivo versionado antes del build o adapta la instrucción COPY a su estructura real.

El servidor escucha dentro del contenedor y la publicación del puerto lo hace accesible desde el host. `HOSTNAME=0.0.0.0` permite escuchar en las interfaces del contenedor. Que un proceso use un puerto no lo publica automáticamente hacia el exterior; Compose declara esa conexión.

### Build sin secretos reales

Generar Prisma requiere cargar su configuración. El ejemplo proporciona una URL ficticia para esa fase; no es una base que permita obtener datos. Si una página consulta PostgreSQL durante prerenderizado, el build fallará o requerirá otra estrategia.

Una página privada que necesita sesión y datos actuales no debe convertirse por accidente en un snapshot construido con credenciales de producción. Decide renderizado por petición y comprueba el recorrido. No soluciones un fallo de build copiando `.env` a una imagen pública.

### Configuración en ejecución

La imagen debe poder recibir DATABASE_URL, AUTH_SECRET y origen correcto cuando se ejecute. La misma aplicación en el host se conecta a localhost; dentro de Compose usa db. El secreto de sesión necesita ser consistente entre instancias del mismo entorno para que la verificación funcione.

Un valor público incorporado durante build puede quedar en los assets del navegador. Cambiar una variable después no garantiza modificar ese contenido ya construido. Clasifica cada variable por privacidad y momento de lectura antes de tratarla como un interruptor universal.

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

Este job ejecuta pruebas puras; las de integración/E2E requieren además PostgreSQL de test, migraciones, seed y servidor. Configura ese job con una base de prueba y los scripts necesarios para la suite del proyecto; no lo apuntes a producción. El deploy automático no sustituye CI.

### Despliegue en Vercel

Conectar el repositorio de aplicación, configurar variables privadas y una base PostgreSQL alojada. Revisar límites del plan elegido antes de abrir cuentas. Usar una base separada para previews: las URLs de preview no son secretas por defecto.

Aplicar `prisma migrate deploy` una vez por entrega contra la base correcta, antes de activar código incompatible. Configurar origen/dominio, callbacks de autenticación y limitación de intentos; crear el primer administrador por un procedimiento controlado. Verificar login, permisos y persistencia después del despliegue. Docker es otro modo de ejecución, no algo que Vercel necesite para desplegar Next.js.

### Leer el Dockerfile por responsabilidades

La etapa build instala dependencias con `npm ci` usando el lockfile. Copiar primero package files permite reutilizar esa capa mientras no cambien dependencias. Copiar código después evita reinstalar todo por cada edición de un componente.

`.dockerignore` reduce el contexto y excluye dependencias locales, artefactos anteriores y secretos. Si copiaras node_modules del host, podrías mezclar binarios o paquetes de otro entorno. El build debe producir sus propias dependencias con la configuración acordada.

La etapa runner copia artefactos con propiedad del usuario node y ejecuta el servidor sin root. Eso reduce privilegios del proceso, pero no corrige permisos de negocio ni vulnerabilidades de código. La seguridad de contenedor y la de aplicación son responsabilidades complementarias.

### Arranque no equivale a migración

Compose espera el healthcheck de la base antes de crear web, pero no aplica tablas por sí mismo. Las migraciones se ejecutan como un paso de entrega contra la base correcta. El runtime no tiene por qué incluir CLI y fuentes para hacerlo en cada arranque.

El seed de demostración no es parte de cada despliegue. Repetirlo sin una política puede recrear usuarios de prueba o alterar datos reales. Separa instalación inicial, migraciones de estructura y preparación de datos de test.

### CI y despliegue automático

```mermaid
flowchart TD
    P["Push o PR"] --> I["Instalación reproducible"]
    I --> Q["Lint, tipos y pruebas"]
    Q --> B["Build"]
    B --> C{"¿Controles correctos?"}
    C -->|No| F["Revisar fallo antes de integrar"]
    C -->|Sí| R["Revisión e integración"]
    R --> D["Migración y entrega controladas"]
    D --> V["Verificar producción"]
```

CI es la ejecución automatizada de controles sobre los cambios. Desplegar es poner una versión en un entorno accesible. Un hosting puede desplegar automáticamente sin que tus pruebas hayan demostrado nada; vincula la integración a los controles relevantes y comprueba su configuración real.

`lint` revisa reglas estáticas; `typecheck` comprueba compatibilidad de tipos; tests observan casos; build comprueba que puede generarse el artefacto. Ninguno sustituye a todos los demás. El job inicial no ejecuta E2E porque no prepara su servidor ni su base: no lo presentes como si lo hiciera.

### Entornos y bases separadas

Local, test, preview y producción necesitan configuraciones propias. Una preview es una versión temporal para revisar un PR, no necesariamente privada. No permitas que una revisión ejecute seed o migraciones experimentales sobre la base productiva.

Al desplegar en Vercel puedes utilizar su integración de Next.js sin Docker. El ejercicio Docker permite entender otra forma de ejecución. Elige el proveedor de PostgreSQL según acceso y condiciones disponibles y usa sus URLs de conexión recomendadas para runtime y migraciones.

### Verificar una entrega y recuperarse

Después de desplegar, comprueba salud, login, permisos, una escritura y su lectura posterior. Un build verde no demuestra que configuraste DATABASE_URL o APP_ORIGIN de producción correctamente. Registra la versión y conserva la evidencia del recorrido.

Si una versión falla, volver al artefacto anterior no deshace automáticamente una migración de base. Prefiere cambios compatibles por etapas y copias de datos cuando correspondan. No improvises un reset productivo para restaurar una pantalla. La nota [[Recursos/Conceptos/Pruebas CI y evidencias|CI y evidencias]] desarrolla esos límites.

### Caso desarrollado: preview funciona y producción rechaza el login

El build terminó y puedes abrir la página. El login o una mutación falla solo con el dominio público. Revisa configuración de origen y cookies antes de reescribir el formulario: APP_ORIGIN podría seguir siendo localhost o la URL de preview.

Comprueba el esquema HTTPS, host real, configuración de Auth.js y ruta de callbacks. Observa estado HTTP sin publicar la cookie. Si una mutación devuelve 403 por origen, el mismo body no cambiará ese resultado. Configura el entorno con el origen permitido correcto.

Después verifica DATABASE_URL de ese entorno. Una preview apuntada a producción puede hacer que pruebas de revisión escriban donde no deberían. Que ambos despliegues lean los mismos registros no demuestra una buena integración; puede revelar una separación de entornos ausente.

Confirma una escritura y lectura posteriores con datos sintéticos y permisos correctos. Si falla, conserva el estado y diagnostica. No ejecutes seed completo ni migrate reset sobre la base pública como primer intento de reparación.

El caso enseña por qué la entrega incluye algo más que generar archivos. Código, esquema, secretos y dominio deben combinarse de forma coherente. La evidencia de build y la del recorrido productivo responden preguntas diferentes.

## Práctica guiada

Arrancar la aplicación mediante Compose y ejecutar controles desde un clon limpio.

## Tarea para casa

Desplegar, comprobar los flujos críticos y documentar variables, migraciones y recuperación. No incluir secretos en capturas.

## Criterios de finalización

- [ ] La imagen construye y usa usuario no root.
- [ ] CI ejecuta lint, tipos, tests y build.
- [ ] La URL desplegada permite los flujos autorizados.

## Preguntas resueltas

**¿Una URL de deploy prueba que la app está lista?**

Hay que verificar configuración, acceso y recorridos reales con datos persistidos.

**¿El rollback de código deshace una migración?**

No. Código, esquema y datos tienen historias distintas que deben mantenerse compatibles.

**¿Vercel necesita mi contenedor Docker?**

La integración habitual de Next.js no lo necesita; son dos modos de ejecución que practicamos por separado.

## Para profundizar

[Next.js: self-hosting](https://nextjs.org/docs/app/guides/self-hosting) · [Compose](https://docs.docker.com/compose/) · [GitHub Actions](https://docs.github.com/en/actions).

## Conceptos clave de esta clase

- **Artefacto:** Resultado generado para ejecutar o entregar una versión.
- **Runtime:** Entorno y fase en que la aplicación construida se ejecuta.
- **Multi-stage:** Build con etapas separadas para preparar y ejecutar.
- **CI:** Controles automatizados que acompañan la integración de cambios.
- **Preview:** Entorno temporal de una versión para revisión.
- **Rollback de aplicación:** Retorno a una versión de código anterior; no revierte por sí solo datos o esquema.

## Conexiones

[[Semana1/CLASE 3|Clase 3]] · [[Recursos/Stack y entorno|Scripts y versiones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 16|Clase 16]] · [[semana4/CLASE 18|Clase 18]] →

---
tipo: referencia
tags:
  - curso/entorno
---
# Stack y entorno: reunir al equipo sin iniciar una guerra de versiones

[[README|Inicio]] · [[Semana1/CLASE 1|Preparación]] · [[Semana1/CLASE 4|Prisma]] · [[semana4/CLASE 17|Producción]]

## Familias elegidas

Estas son las piezas de la discoteca. Todas tienen trabajo; ninguna entró solo porque su logo se veía bonito en el README.

Node.js 22.18+ dentro de la línea 22, npm, TypeScript 5, Next.js 16, React 19, Tailwind 4, Prisma 7, PostgreSQL 16, Zod 4 y React Hook Form 7. No instalar todo con `latest`: «lo más nuevo» no es un plan de compatibilidad. Si clonas la aplicación del grupo, conserva su lockfile y utiliza npm ci para instalar el árbol acordado. Si creas una aplicación nueva, registra las versiones resueltas y verifica la compatibilidad antes de continuar. Prisma CLI, cliente y adaptador comparten versión exacta.

Auth.js/NextAuth 5 se usa como prerelease de forma explícita. La instalación `next-auth@beta` resuelve una versión al preparar la edición; guardarla exacta y probar login, logout, sesión, roles, build y deploy. No usar `withAuth` ni combinar su configuración con NextAuth 4. Si cambias de versión, revisa también los ejemplos de configuración, sesión y permisos; una migración no se resuelve mezclando imports hasta que el editor se canse.

## Crear el repositorio de aplicación

Desde una carpeta distinta a esta bóveda. Los apuntes explican cómo montar la discoteca; no necesitan convertirse en la discoteca con `node_modules` incluido:

```bash
npx create-next-app@16 discoteca --typescript --eslint --tailwind --app --src-dir --use-npm --import-alias '@/*'
cd discoteca
npm install --save-exact server-only zod@4 react-hook-form@7 @hookform/resolvers bcryptjs
npm install --save-exact @prisma/client@7 @prisma/adapter-pg@7 pg dotenv
npm install -D --save-exact prisma@7 tsx @types/pg vitest @playwright/test
npm install --save-exact next-auth@beta
```

Revisar las versiones resueltas en package.json y package-lock; mantener React/React DOM compatibles con el template. No activar funciones experimentales adicionales para este curso: ya tendremos suficientes sorpresas con nuestros propios bugs. Registra en el README de tu aplicación las versiones de scaffolding, shadcn y OpenCode utilizadas para poder repetir los pasos.

Puedes conservar la página inicial del template mientras construyes rutas HTTP, antes de estudiar React. Prepara las carpetas y scripts indicados y añade los servicios del negocio a medida que completes las clases. El template trae una página de bienvenida, no un administrador nocturno que cierre las ventas por nosotros.

## Scripts acordados

Integrar en los scripts existentes de `package.json`, sin borrar el resto. Aquí cada comando tiene oficio; `build` no va a hacer también la tarea de sus compañeros por buena voluntad:

```json
{
  "dev": "next dev",
  "build": "prisma generate && next build",
  "start": "next start",
  "lint": "eslint .",
  "typecheck": "tsc --noEmit",
  "test": "vitest run",
  "test:e2e": "playwright test",
  "db:generate": "prisma generate",
  "db:migrate": "prisma migrate dev",
  "db:deploy": "prisma migrate deploy",
  "db:seed": "prisma db seed"
}
```

Separar tests: en `vitest.config.ts`, `defineConfig({ test: { include: ["src/**/*.test.ts"] } })`, importando `defineConfig` de `vitest/config`. Así Vitest no intenta ejecutar los specs de Playwright: compartir proyecto no significa presentarse al examen del vecino. Configurar Playwright con `testDir: "./tests"`, `use.baseURL` local y servidor de test. La base E2E es distinta de la de desarrollo. Las pruebas necesitan libertad para preparar y limpiar datos sin convertir tu trabajo de ayer en un recuerdo.

Next.js 16 no ejecuta lint como parte del build: el script y CI deben hacerlo explícitamente. El alias `@/*` apunta a `./src/*`. Mantener `strict: true`.

## Plantilla .env.example

Esto es una plantilla, no una colección de contraseñas listas para internet. Si tu contraseña real sigue siendo `CAMBIAR_LOCALMENTE`, el archivo intentó avisarte.

```dotenv
POSTGRES_USER=discoteca
POSTGRES_PASSWORD=CAMBIAR_LOCALMENTE
POSTGRES_DB=discoteca
DATABASE_URL=postgresql://discoteca:CAMBIAR_LOCALMENTE@localhost:5432/discoteca
DATABASE_URL_DOCKER=postgresql://discoteca:CAMBIAR_LOCALMENTE@db:5432/discoteca
AUTH_SECRET=GENERAR_LOCALMENTE
APP_ORIGIN=http://localhost:3000
SEED_ADMIN_EMAIL=admin@example.test
SEED_ADMIN_PASSWORD=DEFINIR_LOCALMENTE
```

No son credenciales para un servidor público. Las URLs deben codificar caracteres especiales de usuario/contraseña. Un `.env` no viaja a Git: añadir `.env*`, excepción `!.env.example`, node_modules y .next a `.gitignore` del **repositorio de aplicación**.

No usar `NEXT_PUBLIC_` para claves privadas: el prefijo hace el valor accesible al navegador. Es ponerlo en el cartel de entrada, no esconderlo debajo del escritorio. PostgreSQL, Auth.js y NVIDIA tienen secretos privados. La clave de OpenCode se conecta fuera del repositorio; no forma parte de las variables del producto.

## Instalar una copia y reconocer sus archivos

Si recibes el repositorio del grupo ya creado, clónalo y ejecuta `npm ci` desde la carpeta que contiene package.json y package-lock.json. Este comando instala lo registrado en el lockfile; no sirve para decidir dependencias nuevas. Usa `npm install` cuando añadas deliberadamente una dependencia y revisa ambos archivos modificados.

`dependencies` contiene paquetes necesarios para la aplicación; `devDependencies` contiene herramientas de desarrollo o construcción. Que Prisma CLI sea de desarrollo no significa que pueda faltar en la etapa que genera el cliente y construye la imagen. El runtime standalone recibe el resultado ya preparado.

El alias `@/*` es una regla del proyecto para resolver módulos desde src. No es una dirección web ni un paquete que npm pueda instalar. Las herramientas de test necesitan su resolución o imports relativos coherentes.

## Comprobar el entorno paso a paso

1. Confirma Node y npm con `node --version` y `npm --version`.
2. Comprueba Docker y Compose y arranca solo db como explica la clase 3.
3. Copia los nombres de .env.example a tu archivo local y completa valores propios.
4. Aplica migraciones, genera Prisma y ejecuta seed en la base de desarrollo.
5. Arranca la aplicación, consulta salud y prueba un recorrido con datos sintéticos.
6. Ejecuta tipos, lint, tests y build. Si una herramienta falla, lee el primer error relevante antes de continuar.

Estos pasos son para preparar y diagnosticar tu copia. Las credenciales reales no se incluyen en un PR ni en una captura de ayuda. El seed puede necesitar variables adicionales según los fixtures del equipo; cada una debe estar documentada sin su valor privado.

## Documentación

Cuando un comando se comporte distinto, consulta la fuente antes de iniciar la ceremonia de borrar carpetas. La documentación puede haber cambiado; los mensajes de error tampoco se redactan únicamente para arruinarnos el día.

[Instalación Next.js](https://nextjs.org/docs/app/getting-started/installation) · [Prisma 7 PostgreSQL](https://www.prisma.io/docs/v7/prisma-orm/quickstart/postgresql) · [Auth.js instalación](https://authjs.dev/getting-started/installation) · [Compose y salud](https://docs.docker.com/compose/how-tos/startup-order/) · [OpenCode 1](https://docs.opencode.ai/docs/) · [Proveedor NVIDIA](https://docs.opencode.ai/docs/providers/#nvidia).

Estas referencias corresponden a las familias elegidas. Si una página muestra ejemplos de una versión mayor distinta, utiliza su selector de versión antes de copiar código. Conserva Prisma 7 y OpenCode 1 en los recorridos de estos apuntes.

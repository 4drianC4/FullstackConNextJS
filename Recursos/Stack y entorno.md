---
tipo: referencia
tags:
  - curso/entorno
---
# Stack y entorno

[[README|Inicio]] · [[Semana1/CLASE 1|Preparación]] · [[Semana1/CLASE 4|Prisma]] · [[semana4/CLASE 17|Producción]]

## Familias elegidas

Node.js 22.18+ dentro de la línea 22, npm, TypeScript 5, Next.js 16, React 19, Tailwind 4, Prisma 7, PostgreSQL 16, Zod 4 y React Hook Form 7. No instalar todo con `latest`: el instructor prepara y verifica un lockfile exacto de la aplicación antes de entregar el repositorio a alumnos. Prisma CLI, cliente y adaptador comparten versión exacta.

Auth.js/NextAuth 5 se usa como prerelease de forma explícita. La instalación `next-auth@beta` resuelve una versión al preparar la edición; guardarla exacta y probar login, logout, sesión, roles, build y deploy. No usar `withAuth` ni combinar su configuración con NextAuth 4. Si cambia la librería elegida, actualizar primero todas las recetas relacionadas; no pedir a los alumnos improvisar la migración.

## Crear el repositorio de aplicación

Desde una carpeta distinta a esta bóveda:

```bash
npx create-next-app@16 discoteca --typescript --eslint --tailwind --app --src-dir --use-npm --import-alias '@/*'
cd discoteca
npm install --save-exact server-only zod@4 react-hook-form@7 @hookform/resolvers bcryptjs
npm install --save-exact @prisma/client@7 @prisma/adapter-pg@7 pg dotenv
npm install -D --save-exact prisma@7 tsx @types/pg vitest @playwright/test
npm install --save-exact next-auth@beta
```

Revisar las versiones resueltas en package.json y package-lock; mantener React/React DOM compatibles con el template. No activar funciones experimentales adicionales para este curso. El instructor registra las versiones exactas de herramientas de scaffolding, shadcn y OpenCode que probó.

El template vacío permite enseñar backend antes de React: se mantiene la página inicial generada mientras se construyen rutas HTTP. El instructor prepara carpetas y scripts; los servicios del negocio se implementan en clase.

## Scripts acordados

Integrar en los scripts existentes de `package.json`, sin borrar el resto:

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

Separar tests: en `vitest.config.ts`, `defineConfig({ test: { include: ["src/**/*.test.ts"] } })`, importando `defineConfig` de `vitest/config`. Así Vitest no intenta ejecutar los specs de Playwright. Configurar Playwright con `testDir: "./tests"`, `use.baseURL` local y servidor de test. La base E2E es distinta de la de desarrollo.

Next.js 16 no ejecuta lint como parte del build: el script y CI deben hacerlo explícitamente. El alias `@/*` apunta a `./src/*`. Mantener `strict: true`.

## Plantilla .env.example

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

No usar `NEXT_PUBLIC_` para claves privadas: el prefijo hace el valor accesible al navegador. PostgreSQL, Auth.js y NVIDIA tienen secretos privados. La clave de OpenCode se conecta fuera del repositorio; no forma parte de las variables del producto.

## Preparación del instructor antes de cada edición

- [ ] Crear el repositorio de aplicación y fijar versiones exactas y lockfile.
- [ ] Ejecutar desde un clon limpio: npm ci, Prisma generate, migraciones y seed.
- [ ] Ejecutar lint, tipos, pruebas y build con esas versiones.
- [ ] Probar credenciales, errores, cookies, roles y origen de las APIs.
- [ ] Construir la imagen y verificar que la base conserva datos.
- [ ] Probar hosting y base elegidos, límites, previews y origen real.
- [ ] Verificar OpenCode 1, proveedor NVIDIA y un modelo con herramientas, sin facturación.
- [ ] Registrar fecha, versiones exactas y resultados en el README de la aplicación.

No hay lockfile ni aplicación en este repositorio de material. Por ello las comprobaciones de ejecución anteriores son tareas de preparación, no resultados ya obtenidos al editar los apuntes.

## Documentación consultada

[Instalación Next.js](https://nextjs.org/docs/app/getting-started/installation) · [Prisma 7 PostgreSQL](https://www.prisma.io/docs/v7/prisma-orm/quickstart/postgresql) · [Auth.js instalación](https://authjs.dev/getting-started/installation) · [Compose y salud](https://docs.docker.com/compose/how-tos/startup-order/) · [OpenCode 1](https://opencode.ai/docs/) · [Proveedor NVIDIA](https://opencode.ai/docs/providers/#nvidia).

Revisión editorial: 28 de octubre de 2026. Son referencias para las familias elegidas, no una promesa de que futuras versiones conservarán las mismas APIs.

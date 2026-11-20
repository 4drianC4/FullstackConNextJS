---
name: arquitectura-vertical-discoteca
description: Diseña y monta la arquitectura base del proyecto Discoteca (Next.js 16 + TypeScript, monolito con vertical slices donde cada módulo tiene frontend/ y backend/). Úsala al crear el repositorio de aplicación desde cero, al añadir un módulo nuevo (users, events, admissions, drinks, bar-sales, reservations), al decidir dónde va un archivo o al revisar si un import rompe las fronteras entre módulos.
---

# Arquitectura base: monolito Next.js con vertical slices

Esta skill traduce los apuntes del curso (README, `Proyecto/4. Arquitectura vertical y contratos`, `Proyecto/6. Modelo de datos`, `Recursos/Stack y entorno` y las clases 3–17) en una receta para montar el repositorio de aplicación. Cuando haya duda, los apuntes mandan; esta skill solo los ordena.

## Principios (no negociables)

1. **Un repo, una app Next.js.** Backend (Route Handlers) y frontend (App Router) conviven en el mismo proyecto y despliegue. Nada de microservicios ni workspaces.
2. **Se organiza por dominio, no por capa.** Todo lo de "eventos" vive en `src/features/events/`. Dentro de cada módulo hay exactamente dos apartados: `backend/` y `frontend/`, unidos por un **contrato puro** (`<entidad>.schema.ts`) en la raíz del módulo.
3. **`src/app/` es solo enrutado.** `route.ts` re-exporta controladores; `page.tsx` compone componentes del módulo. Cero lógica de negocio en `app/`.
4. **Las dependencias fluyen en un solo sentido.**
   - HTTP: `app/api/**/route.ts` → `backend/*.controller.ts` → (`requireRoles` + schema Zod) → `backend/*.service.ts` → Prisma.
   - UI: `app/**/page.tsx` → `frontend/*.tsx` → contrato + `fetch` a la API (o, en Server Components, el servicio tras autorizar).
5. **El frontend nunca importa backend** (ni `prisma`, ni `auth`, ni `access`). Todo archivo de backend empieza con `import "server-only"`.
6. **Sin ceremonia.** Nada de repositorios, fábricas ni contenedores de inyección "por patrón". Controller + service + schema basta.

## Árbol objetivo

```text
discoteca/
├─ prisma/
│  ├─ schema.prisma          # modelo común (Proyecto/6)
│  ├─ migrations/
│  └─ seed.ts                # cliente propio, sin server-only
├─ prisma.config.ts          # URL de la base (Prisma 7)
├─ src/
│  ├─ app/                   # SOLO rutas
│  │  ├─ api/
│  │  │  ├─ health/route.ts
│  │  │  ├─ auth/[...nextauth]/route.ts
│  │  │  ├─ events/route.ts            # export { getEvents as GET, postEvent as POST }
│  │  │  └─ events/[id]/route.ts       # export { patchEvent as PATCH }
│  │  ├─ login/page.tsx
│  │  ├─ dashboard/layout.tsx
│  │  ├─ dashboard/events/page.tsx
│  │  ├─ layout.tsx
│  │  └─ globals.css
│  ├─ features/
│  │  ├─ users/
│  │  ├─ events/
│  │  │  ├─ event.schema.ts            # CONTRATO: Zod de entrada + DTO de salida + tipos
│  │  │  ├─ event.schema.test.ts
│  │  │  ├─ backend/
│  │  │  │  ├─ event.controller.ts     # HTTP ↔ dominio: guard, origin, parse, apiError
│  │  │  │  └─ event.service.ts        # reglas + Prisma (server-only)
│  │  │  └─ frontend/
│  │  │     ├─ event-api.ts            # fetch tipado a /api/events
│  │  │     ├─ event-form.tsx          # "use client" + RHF + zodResolver
│  │  │     ├─ event-list.tsx
│  │  │     └─ events-panel.tsx        # compone form + list (revision/onSaved)
│  │  ├─ admissions/
│  │  ├─ drinks/                       # categorías + bebidas
│  │  ├─ bar-sales/
│  │  └─ reservations/                 # mesas + reservas
│  ├─ shared/                          # infraestructura transversal (no dominio)
│  │  ├─ lib/prisma.ts                 # server-only
│  │  ├─ lib/api-error.ts              # ApiError + apiError(): formato { error, issues? }
│  │  ├─ lib/access.ts                 # requireRoles / requirePageRoles (server-only)
│  │  ├─ lib/permissions.ts            # canAccess(): función pura testeable
│  │  ├─ lib/origin.ts                 # requireSameOrigin (CSRF)
│  │  ├─ lib/api-client.ts             # fetchJson() para el navegador
│  │  └─ ui/                           # componentes shadcn/ui
│  ├─ generated/prisma/                # cliente generado (no editar, en .gitignore)
│  ├─ types/next-auth.d.ts
│  └─ auth.ts                          # Auth.js v5 (Credentials + JWT)
├─ tests/                              # Playwright (E2E)
├─ compose.yaml  Dockerfile  .dockerignore
├─ .env.example  .github/workflows/ci.yml
├─ eslint.config.mjs  vitest.config.ts  playwright.config.ts  next.config.ts
└─ package.json  package-lock.json
```

Mapa módulo → modelos → rutas (de `Proyecto/4`):

| Módulo | Modelos Prisma | Rutas API | Pantallas |
| --- | --- | --- | --- |
| `users` | User | `/api/users`, `/api/users/[id]` | `/login`, `/dashboard/users` |
| `events` | Event | `/api/events`, `/api/events/[id]` | `/dashboard/events` |
| `admissions` | Admission | `/api/admissions`, `/api/admissions/[id]/check-in` | `/dashboard/admissions` |
| `drinks` | Category, Drink | `/api/categories`, `/api/drinks`, `/api/drinks/[id]` | `/dashboard/drinks` |
| `bar-sales` | BarSale, BarSaleItem | `/api/bar-sales`, `/api/bar-sales/[id]` | `/dashboard/bar-sales` |
| `reservations` | ClubTable, Reservation | `/api/tables`, `/api/reservations`, `/api/reservations/[id]` | `/dashboard/reservations` |

## Qué va en cada apartado

**Contrato (`<entidad>.schema.ts`, raíz del módulo)** — puro: solo `zod` y tipos. Esquemas de entrada `.strict()` (nunca aceptan `role`, `totalCents`, contadores, actor), esquema del DTO de respuesta (fechas como string ISO) y `z.infer`. Es lo único que importan *ambos* lados. Equivale a la carpeta `shared/` del módulo en los apuntes; aquí es un archivo para respetar los dos apartados.

**`backend/`** — `import "server-only"` en la primera línea.
- `*.controller.ts`: una función por verbo (`getEvents`, `postEvent`, `patchEvent`). Orden fijo: `requireRoles` → `requireSameOrigin` (mutaciones) → `await context.params` + `z.uuid()` → `schema.parse(await request.json())` → servicio → `Response.json(dto, { status })`. Todo dentro de `try/catch (error: unknown) { return apiError(error) }`.
- `*.service.ts`: reglas de negocio y Prisma. Siempre `select` público (nunca `passwordHash`), condiciones dentro de la escritura (`updateMany` + `count`), transacciones para aforo/ventas, actor recibido como parámetro (viene del guard, no del body). Lanza `ApiError(409, …)` para conflictos de negocio.
- Tests de integración de servicios aquí (`*.test.ts`) contra base de test.

**`frontend/`**
- `*-api.ts`: funciones `listEvents()`, `createEvent(input)` que usan `fetchJson` y validan la respuesta con el DTO del contrato. Sin `server-only`.
- Componentes: `"use client"` solo donde hay estado o handlers. Formularios con React Hook Form + `zodResolver(<schema de entrada>)`; estados carga/vacío/error; `role="status"`/`role="alert"`; labels y foco. UI base desde `@/shared/ui`.
- Sin optimistic UI en entradas/ventas: confirmar con el servidor y recargar (`revision` + `onSaved`).

**`src/app/`** — `route.ts` = una línea de re-export. `page.tsx` = Server Component que autoriza con `requirePageRoles` y renderiza el panel del módulo (o lee el servicio directamente sin fetch a sí mismo).

## Reglas de imports entre módulos

| Desde \ Hacia | contrato propio | backend propio | frontend propio | backend de otro módulo | frontend de otro módulo | `shared/lib` servidor | `shared/ui`, `api-client` |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contrato | – | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| backend | ✓ | ✓ | ✗ | ✓ solo servicios acordados en contrato | ✗ | ✓ | ✗ |
| frontend | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ |
| `app/` | ✓ | ✓ (controladores, servicios en pages) | ✓ | ✓ | ✓ | ✓ | ✓ |

- Dentro de un módulo usa imports relativos (`../event.schema`); entre módulos y hacia `shared` usa `@/`.
- Un módulo puede **leer** contratos de otro (p. ej. `admissions` usa `eventIdSchema`). Si necesita escribir en tablas ajenas (p. ej. `admissions` incrementa `Event.admissionCount` en su transacción), queda documentado en el contrato del Issue.
- Estas reglas se hacen cumplir con ESLint: ver `references/estructura-y-reglas.md`.

## Procedimiento A — Crear el repositorio base

Sigue el orden; cada paso deja algo verificable. Plantillas completas en `references/plantillas-base.md`.

1. **Scaffold** (fuera de la bóveda), con versiones exactas:
   ```bash
   npx create-next-app@16 discoteca --typescript --eslint --tailwind --app --src-dir --use-npm --import-alias '@/*'
   ```
   ```bash
   cd discoteca && npm install --save-exact server-only zod@4 react-hook-form@7 @hookform/resolvers bcryptjs @prisma/client@7 @prisma/adapter-pg@7 pg dotenv next-auth@beta
   ```
   ```bash
   npm install -D --save-exact prisma@7 tsx @types/pg vitest @playwright/test
   ```
   Registra en el README las versiones resueltas (Auth.js 5 es beta: fijarla exacta).
2. **Carpetas**: crea `src/features/{users,events,admissions,drinks,bar-sales,reservations}/{backend,frontend}`, `src/shared/{lib,ui}`, `src/types`, `tests`.
3. **Config**: `package.json` scripts, `tsconfig` con `strict: true`, `vitest.config.ts` (`src/**/*.test.ts`), `playwright.config.ts` (`testDir: "./tests"`), `next.config.ts` con `output: "standalone"`, `eslint.config.mjs` con fronteras, `.gitignore` (`.env*`, `!.env.example`, `src/generated`).
4. **Entorno**: `.env.example` + `compose.yaml` (solo `db`) → `docker compose up -d db`.
5. **Datos**: `prisma.config.ts`, `prisma/schema.prisma` (copiar de `Proyecto/6`), `npx prisma migrate dev --name initial`, `prisma/seed.ts`, `npm run db:seed`.
6. **Infraestructura compartida**: `shared/lib/{prisma,api-error,permissions,access,origin,api-client}.ts`, `src/auth.ts`, `types/next-auth.d.ts`, `app/api/auth/[...nextauth]/route.ts`, `app/api/health/route.ts`.
7. **Slice de referencia**: implementa `events` completo (plantilla en `references/plantilla-slice.md`) como modelo para los demás equipos.
8. **Esqueletos del resto**: `bash .claude/skills/arquitectura-vertical-discoteca/scripts/new-slice.sh <modulo> <entidad>` por cada módulo (p. ej. `bar-sales bar-sale`), o crea las carpetas a mano.
9. **Calidad y entrega**: `.github/workflows/ci.yml`, `Dockerfile`, `.dockerignore`, servicio `web` en Compose.
10. **Verificar** (ver abajo) y abrir el primer PR `feat/base-architecture`.

## Procedimiento B — Añadir una funcionalidad a un módulo

1. Issue con contrato: request/response, códigos HTTP (200/201/400/401/403/404/409), permisos (matriz ADMIN/STAFF), reglas, fixtures, estados de pantalla.
2. Contrato → `<entidad>.schema.ts` + test del esquema.
3. Servicio → controlador → `app/api/.../route.ts` (re-export).
4. Probar por `curl` con y sin sesión, con `Origin`, con body inválido y campo extra.
5. `frontend/<entidad>-api.ts` → componentes → `app/dashboard/.../page.tsx`.
6. `npm run lint && npm run typecheck && npm test && npm run build`; PR pequeño en `feat/<modulo>-<accion>`.

## Convenciones

- TypeScript estricto, sin `any`; errores externos como `unknown`.
- Archivos kebab-case (`event-form.tsx`, `bar-sale.service.ts`); tipos/componentes PascalCase; variables camelCase.
- Sufijos: `.schema.ts`, `.controller.ts`, `.service.ts`, `-api.ts`, `.test.ts`.
- Dinero en centavos `Int` (`priceCents`, `unitPriceCents`, `totalCents`); fechas ISO con zona en contratos; mostrar en `America/La_Paz`.
- Errores HTTP siempre `{ "error": string, "issues"?: [...] }`. Nunca stack, SQL, cookies ni credenciales.
- Next.js 16: `params` es `Promise`; `proxy.ts` (antes middleware) solo para redirecciones, **nunca** como única barrera de permisos.
- Fuera del MVP (no meter en la base): Zustand, TanStack Query, optimistic UI, tiempo real, QR, pagos.

## Verificación de la base

```bash
docker compose up -d db && npm run db:migrate && npm run db:seed
```
```bash
npm run lint && npm run typecheck && npm test && npm run build
```
```bash
curl -i http://localhost:3000/api/health
```
Además: `GET /api/events` sin sesión → 401; con STAFF → 200; `POST` con STAFF → 403; `POST` sin `Origin` → 403; un archivo de `frontend/` que importe `../backend/...` debe hacer fallar `npm run lint`.

## Referencias de esta skill

- `references/estructura-y-reglas.md` — justificación de la estructura, configuración ESLint de fronteras, dependencias entre módulos y errores típicos.
- `references/plantillas-base.md` — código de configuración e infraestructura compartida (scripts, Prisma, auth, access, api-error, Compose, Docker, CI).
- `references/plantilla-slice.md` — módulo `events` completo de punta a punta, para copiar como patrón.
- `scripts/new-slice.sh` — genera el esqueleto de un módulo nuevo.

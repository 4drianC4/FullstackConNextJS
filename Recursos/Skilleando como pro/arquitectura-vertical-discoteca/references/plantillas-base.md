# Plantillas de configuración e infraestructura compartida

Todo el código sale de los apuntes (clases 3, 4, 6, 8, 9, 17 y `Recursos/Stack y entorno`), reunido aquí. Ajusta solo lo marcado.

## package.json — scripts

Integrar con los existentes:

```json
{
  "scripts": {
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
}
```

## .gitignore (añadir)

```text
.env*
!.env.example
src/generated/
```

## .env.example

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

Nunca `NEXT_PUBLIC_` para secretos.

## next.config.ts

```ts
import type { NextConfig } from "next";
const nextConfig: NextConfig = {
  output: "standalone",
};
export default nextConfig;
```

## vitest.config.ts

```ts
import { defineConfig } from "vitest/config";
import { fileURLToPath } from "node:url";
export default defineConfig({
  resolve: { alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) } },
  test: { include: ["src/**/*.test.ts"] },
});
```

## playwright.config.ts

```ts
import { defineConfig } from "@playwright/test";
export default defineConfig({
  testDir: "./tests",
  use: { baseURL: "http://localhost:3000" },
  webServer: { command: "npm run build && npm run start", url: "http://localhost:3000/api/health", reuseExistingServer: true },
});
```

La base E2E es distinta de la de desarrollo.

## compose.yaml

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
  web:                      # se añade en la clase 17
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
volumes:
  pgdata:
```

## Prisma

`prisma.config.ts`:

```ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations", seed: "tsx prisma/seed.ts" },
  datasource: { url: env("DATABASE_URL") },
});
```

`prisma/schema.prisma` y `prisma/seed.ts`: copiar literalmente de `Proyecto/6. Modelo de datos`. El generator usa `provider = "prisma-client"` y `output = "../src/generated/prisma"`.

## src/shared/lib/prisma.ts

```ts
import "server-only";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@/generated/prisma/client";
const connectionString = process.env.DATABASE_URL;
if (!connectionString) throw new Error("Falta DATABASE_URL");
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  adapter: new PrismaPg({ connectionString }),
});
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## src/shared/lib/api-error.ts

```ts
import { ZodError } from "zod";
import { Prisma } from "@/generated/prisma/client";
export class ApiError extends Error {
  constructor(public status: number, message: string) { super(message); }
}
export function apiError(error: unknown): Response {
  if (error instanceof ApiError)
    return Response.json({ error: error.message }, { status: error.status });
  if (error instanceof ZodError)
    return Response.json({ error: "Datos inválidos", issues: error.issues }, { status: 400 });
  if (error instanceof SyntaxError)
    return Response.json({ error: "JSON inválido" }, { status: 400 });
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === "P2002") return Response.json({ error: "El registro ya existe" }, { status: 409 });
    if (error.code === "P2025") return Response.json({ error: "Registro no encontrado" }, { status: 404 });
    if (error.code === "P2003") return Response.json({ error: "Relación inválida o registro en uso" }, { status: 409 });
  }
  console.error("Fallo interno de la operación"); // sin body, cookies ni credenciales
  return Response.json({ error: "Error interno" }, { status: 500 });
}
```

> `api-error.ts` importa el cliente generado de Prisma, así que es solo de servidor: ESLint lo prohíbe en `frontend/` (está en la lista `serverOnlyInfra`). El navegador usa `HttpError` de `api-client.ts`.

## src/shared/lib/permissions.ts

```ts
export type Role = "ADMIN" | "STAFF";
export function canAccess(role: Role, allowed: readonly Role[]) {
  return allowed.includes(role);
}
```

## src/shared/lib/access.ts

```ts
import "server-only";
import { redirect } from "next/navigation";
import { auth } from "@/auth";
import { prisma } from "@/shared/lib/prisma";
import { ApiError } from "./api-error";
import { canAccess, type Role } from "./permissions";

/** Para controladores: lanza 401/403 que apiError convierte en JSON. */
export async function requireRoles(allowed: readonly Role[]) {
  const session = await auth();
  if (!session?.user.id) throw new ApiError(401, "Inicia sesión");
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { id: true, role: true, active: true },
  });
  if (!user || !user.active) throw new ApiError(401, "Sesión no válida");
  if (!canAccess(user.role, allowed)) throw new ApiError(403, "Sin permiso");
  return user;
}

/** Para páginas (Server Components): sin sesión redirige a /login; 403 llega a error.tsx. */
export async function requirePageRoles(allowed: readonly Role[]) {
  try {
    return await requireRoles(allowed);
  } catch (error: unknown) {
    if (error instanceof ApiError && error.status === 401) redirect("/login");
    throw error;
  }
}
```

## src/shared/lib/origin.ts

```ts
import "server-only";
import { ApiError } from "./api-error";
export function requireSameOrigin(request: Request) {
  const expected = process.env.APP_ORIGIN;
  if (!expected || request.headers.get("origin") !== new URL(expected).origin)
    throw new ApiError(403, "Origen no permitido");
}
```

## src/shared/lib/api-client.ts (navegador)

```ts
import type { z } from "zod";

export class HttpError extends Error {
  constructor(
    public status: number,
    message: string,
    public issues?: { path: (string | number)[]; message: string }[],
  ) { super(message); }
}

export async function fetchJson<T extends z.ZodType>(
  url: string,
  schema: T,
  init?: RequestInit,
): Promise<z.infer<T>> {
  const response = await fetch(url, {
    cache: "no-store",
    ...init,
    headers: { "Content-Type": "application/json", ...init?.headers },
  });
  const isJson = response.headers.get("content-type")?.includes("application/json");
  const body: unknown = isJson ? await response.json() : null;
  if (!response.ok) {
    const data = (body ?? {}) as { error?: string; issues?: HttpError["issues"] };
    throw new HttpError(response.status, data.error ?? `Error ${response.status}`, data.issues);
  }
  return schema.parse(body);
}
```

## src/auth.ts

```ts
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "@/shared/lib/prisma";
const loginSchema = z.object({
  email: z.email(),
  password: z.string().min(8).refine((s) => new TextEncoder().encode(s).length <= 72),
});
export const { handlers, auth, signIn, signOut } = NextAuth({
  session: { strategy: "jwt", maxAge: 8 * 60 * 60 },
  pages: { signIn: "/login" },
  providers: [Credentials({
    credentials: { email: {}, password: {} },
    async authorize(raw) {
      const parsed = loginSchema.safeParse(raw);
      if (!parsed.success) return null;
      const user = await prisma.user.findUnique({ where: { email: parsed.data.email.toLowerCase() } });
      if (!user || !user.active) return null;
      if (!await bcrypt.compare(parsed.data.password, user.passwordHash)) return null;
      return { id: user.id, name: user.name, email: user.email };
    },
  })],
  callbacks: {
    jwt({ token, user }) { if (user) token.sub = user.id; return token; },
    session({ session, token }) { if (token.sub) session.user.id = token.sub; return session; },
  },
});
```

`src/types/next-auth.d.ts`:

```ts
import type { DefaultSession } from "next-auth";
declare module "next-auth" {
  interface Session { user: { id: string } & DefaultSession["user"]; }
}
```

`src/app/api/auth/[...nextauth]/route.ts`:

```ts
import { handlers } from "@/auth";
export const { GET, POST } = handlers;
```

`src/app/api/health/route.ts`:

```ts
export async function GET() {
  return Response.json({ status: "ok" });
}
```

## Layouts

`src/app/dashboard/layout.tsx`:

```tsx
import type { ReactNode } from "react";
import Link from "next/link";
import { requirePageRoles } from "@/shared/lib/access";
export default async function DashboardLayout({ children }: { children: ReactNode }) {
  await requirePageRoles(["ADMIN", "STAFF"]);
  return (
    <>
      <nav aria-label="Principal" className="flex gap-4 p-4">
        <Link href="/dashboard/events">Eventos</Link>
        <Link href="/dashboard/admissions">Entradas</Link>
        <Link href="/dashboard/drinks">Bebidas</Link>
        <Link href="/dashboard/bar-sales">Ventas</Link>
        <Link href="/dashboard/reservations">Reservas</Link>
        <Link href="/dashboard/users">Usuarios</Link>
      </nav>
      <main className="p-4">{children}</main>
    </>
  );
}
```

El layout mejora la experiencia, pero **no** sustituye el guard de cada página ni de cada endpoint.

`/login` lo implementa el módulo `users` en `features/users/frontend/login-form.tsx` (Client Component con `signIn("credentials", { email, password, redirect: false })` de `next-auth/react`); `src/app/login/page.tsx` solo lo renderiza.

## shadcn/ui

```bash
npx shadcn@latest init
```
```bash
npx shadcn@latest add button input label dialog
```

En `components.json` apunta `aliases.ui` a `@/shared/ui` (y `utils` a `@/shared/lib/utils`). Acento violeta, superficies oscuras, foco visible.

## Dockerfile

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

`.dockerignore`:

```text
node_modules
.next
.git
.env*
!.env.example
*.log
```

## .github/workflows/ci.yml

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

Los tests de integración/E2E necesitan un job aparte con PostgreSQL de test; nunca contra producción.

---
tipo: clase
clase: 4
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 4 — Modelado, Prisma y datos de prueba

[[README|Inicio]] · [[Semana1/INDICE|Semana 1]] · ← [[Semana1/CLASE 3|Clase 3]] · [[Semana1/CLASE 5|Clase 5]] →

> [!abstract] Objetivo
> Definir el modelo común y consultar PostgreSQL mediante Prisma 7.

## Antes de empezar

Repasa [[Semana1/CLASE 3|Clase 3]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Diseñar antes de programar

Identificar entidades, PK, FK, relaciones 1:N, restricciones únicas e índices. SQL no es inferior a un ORM: Prisma aporta consultas tipadas, pero seguimos necesitando entender integridad y transacciones. Un UUID no sustituye un control de acceso.

Leer [[Proyecto/6. Modelo de datos|el esquema común completo]]. Todos usan el mismo modelo. Cada equipo propone cambios, pero el instructor coordina las migraciones para evitar historiales incompatibles.

### Instalar y configurar

Seguir [[Recursos/Stack y entorno|la familia de versiones del curso]]; Prisma CLI, cliente y adaptador deben compartir versión exacta en el lockfile de la aplicación.

```bash
npm install --save-exact @prisma/client@7 @prisma/adapter-pg@7 pg dotenv
npm install -D --save-exact prisma@7 tsx @types/pg
```

`prisma/schema.prisma` comienza con:

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}
datasource db {
  provider = "postgresql"
}
```

En Prisma 7 la URL va en `prisma.config.ts`:

```ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations", seed: "tsx prisma/seed.ts" },
  datasource: { url: env("DATABASE_URL") },
});
```

Completar con los modelos de la nota del proyecto. Después:

```bash
npx prisma migrate dev --name initial
npx prisma generate
npx prisma db seed
```

El seed se ejecuta explícitamente. `migrate dev` es para desarrollo; en producción se aplican migraciones revisadas con `migrate deploy`.

### Cliente compartido

Crear `src/shared/lib/prisma.ts`:

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

Reutiliza el cliente durante las recargas de desarrollo. No elimina la necesidad de controlar el pool en producción. Ver la receta de seed en el modelo común.

## Práctica guiada

Generar la migración inicial y listar bebidas con Prisma Studio o un script de servidor.

## Tarea para casa

Crear fixtures de tu funcionalidad, con IDs conocidos y relaciones válidas. Revisar con otro equipo el contrato.

## Criterios de finalización

- [ ] El esquema valida y el cliente genera.
- [ ] La base se reconstruye con migraciones y seed.
- [ ] No se guardan contraseñas en texto plano.

## Conexiones

[[Proyecto/6. Modelo de datos|Modelo y seed]] · [[Semana2/CLASE 7|Clase 7]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana1/INDICE|Semana 1]] · ← [[Semana1/CLASE 3|Clase 3]] · [[Semana1/CLASE 5|Clase 5]] →

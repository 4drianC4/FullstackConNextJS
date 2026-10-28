---
tipo: clase
clase: 6
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 6 — CRUD, servicios y manejo de errores

[[README|Inicio]] · [[Semana2/INDICE|Semana 2]] · ← [[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 7|Clase 7]] →

> [!abstract] Objetivo
> Implementar CRUD con capas pequeñas y respuestas de error predecibles.

## Antes de empezar

Repasa [[Semana1/CLASE 5|Clase 5]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Servicio de eventos

```ts
// src/features/events/backend/event.service.ts
import "server-only";
import { prisma } from "@/shared/lib/prisma";
import type { CreateEventInput } from "../shared/event.schema";
export function createEvent(input: CreateEventInput) {
  return prisma.event.create({
    data: { ...input, startsAt: new Date(input.startsAt) },
    select: { id: true, name: true, startsAt: true, capacity: true, status: true },
  });
}
export function listEvents() {
  return prisma.event.findMany({
    select: { id: true, name: true, startsAt: true, capacity: true, status: true },
    orderBy: [{ startsAt: "desc" }, { id: "asc" }],
    take: 50,
  });
}
```

El límite evita devolver toda la tabla; la paginación completa es ampliación. Antes de publicar, los controladores deben incorporar los guards de la clase 9.

### Errores compartidos

Crear `src/shared/lib/api-error.ts`:

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
    if (error.code === "P2002")
      return Response.json({ error: "El registro ya existe" }, { status: 409 });
    if (error.code === "P2025")
      return Response.json({ error: "Registro no encontrado" }, { status: 404 });
    if (error.code === "P2003")
      return Response.json({ error: "Relación inválida o registro en uso" }, { status: 409 });
  }
  // Registrar contexto técnico en servidor sin body, cookies ni credenciales.
  console.error("Fallo interno de la operación");
  return Response.json({ error: "Error interno" }, { status: 500 });
}
```

### Controlador y ruta

```ts
// src/features/events/backend/event.controller.ts
import { createEventSchema } from "../shared/event.schema";
import { createEvent, listEvents } from "./event.service";
import { apiError } from "@/shared/lib/api-error";
export async function postEvent(request: Request) {
  try {
    // En clase 9: await requireRoles(["ADMIN"]), antes de leer el body.
    const input = createEventSchema.parse(await request.json());
    return Response.json(await createEvent(input), { status: 201 });
  } catch (error: unknown) { return apiError(error); }
}
export async function getEvents() {
  try {
    // En clase 9: await requireRoles(["ADMIN", "STAFF"]).
    return Response.json(await listEvents());
  } catch (error: unknown) { return apiError(error); }
}
```

```ts
// src/app/api/events/route.ts
export { getEvents as GET, postEvent as POST } from "@/features/events/backend/event.controller";
```

Para `/api/events/[id]`, Next.js 16 entrega `params` asíncronos: `const { id } = await context.params`, con tipo `{ params: Promise<{ id: string }> }`. Validar el ID, devolver 404 si no existe y usar un esquema PATCH con al menos un campo.

No borrar ventas ni entradas consumidas: conservar el historial. Una bebida en uso se desactiva con `available: false`; borrar un evento con dependencias devuelve 409.

## Práctica guiada

Completar GET/POST de eventos y probar 201, 400 y 500 controlado sin filtrar detalles.

## Tarea para casa

Implementar lectura, edición y política de borrado/desactivación del módulo. Añadir ejemplos de requests al PR.

## Criterios de finalización

- [ ] No se mezclan rutas y persistencia.
- [ ] Los errores tienen códigos coherentes.
- [ ] Las respuestas seleccionan campos explícitos.

## Conexiones

[[Semana2/CLASE 9|Clase 9]] · [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|Convenciones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana2/INDICE|Semana 2]] · ← [[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 7|Clase 7]] →

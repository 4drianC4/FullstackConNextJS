# Slice de referencia: módulo `events` de punta a punta

Es el patrón que copian los demás módulos. Reúne el código de las clases 5, 6, 9, 10, 12, 14 y 15 ya colocado en la estructura `contrato / backend / frontend`.

```text
src/features/events/
├─ event.schema.ts
├─ event.schema.test.ts
├─ backend/event.controller.ts
├─ backend/event.service.ts
└─ frontend/{event-api.ts, event-form.tsx, event-list.tsx, events-panel.tsx}
src/app/api/events/route.ts
src/app/api/events/[id]/route.ts
src/app/dashboard/events/page.tsx
```

## 1. Contrato — `src/features/events/event.schema.ts`

```ts
import { z } from "zod";

// Entrada (lo que el cliente PUEDE enviar)
export const createEventSchema = z.object({
  name: z.string().trim().min(3).max(100),
  startsAt: z.iso.datetime({ offset: true }),
  capacity: z.number().int().min(1).max(10000),
}).strict();
export type CreateEventInput = z.infer<typeof createEventSchema>;

export const updateEventSchema = createEventSchema.partial().refine(
  (value) => Object.keys(value).length > 0,
  { message: "Debes enviar al menos un campo" },
);
export type UpdateEventInput = z.infer<typeof updateEventSchema>;

export const eventIdSchema = z.uuid();

// Salida (lo que el servidor DEVUELVE). Fechas JSON = string.
export const eventStatusSchema = z.enum(["DRAFT", "OPEN", "CLOSED"]);
export const eventDtoSchema = z.object({
  id: z.string(),
  name: z.string(),
  startsAt: z.string(),
  capacity: z.number(),
  status: eventStatusSchema,
});
export const eventListSchema = z.array(eventDtoSchema);
export type EventDto = z.infer<typeof eventDtoSchema>;
```

## 2. Test del contrato — `src/features/events/event.schema.test.ts`

```ts
import { describe, expect, it } from "vitest";
import { createEventSchema } from "./event.schema";

const valid = { name: "Noche Disco", startsAt: "2026-12-05T22:00:00-04:00", capacity: 100 };

describe("createEventSchema", () => {
  it("acepta un evento válido", () => {
    expect(createEventSchema.safeParse(valid).success).toBe(true);
  });
  it("rechaza capacidad cero", () => {
    expect(createEventSchema.safeParse({ ...valid, capacity: 0 }).success).toBe(false);
  });
  it("rechaza campos extra como status", () => {
    expect(createEventSchema.safeParse({ ...valid, status: "OPEN" }).success).toBe(false);
  });
});
```

## 3. Servicio — `src/features/events/backend/event.service.ts`

```ts
import "server-only";
import { prisma } from "@/shared/lib/prisma";
import { ApiError } from "@/shared/lib/api-error";
import type { CreateEventInput, UpdateEventInput } from "../event.schema";

const publicEvent = { id: true, name: true, startsAt: true, capacity: true, status: true } as const;

export function createEvent(input: CreateEventInput) {
  return prisma.event.create({
    data: { name: input.name, capacity: input.capacity, startsAt: new Date(input.startsAt) },
    select: publicEvent,
  });
}

export function listEvents() {
  return prisma.event.findMany({
    select: publicEvent,
    orderBy: [{ startsAt: "desc" }, { id: "asc" }],
    take: 50,
  });
}

export async function updateDraftEvent(id: string, input: UpdateEventInput) {
  return prisma.$transaction(async (tx) => {
    const changed = await tx.event.updateMany({
      where: { id, status: "DRAFT" }, // la regla va DENTRO de la escritura
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.capacity !== undefined ? { capacity: input.capacity } : {}),
        ...(input.startsAt !== undefined ? { startsAt: new Date(input.startsAt) } : {}),
      },
    });
    if (changed.count !== 1) throw new ApiError(409, "Evento inexistente o fuera de edición");
    return tx.event.findUniqueOrThrow({ where: { id }, select: publicEvent });
  });
}
```

## 4. Controlador — `src/features/events/backend/event.controller.ts`

```ts
import "server-only";
import { createEventSchema, eventIdSchema, updateEventSchema } from "../event.schema";
import { createEvent, listEvents, updateDraftEvent } from "./event.service";
import { requireRoles } from "@/shared/lib/access";
import { requireSameOrigin } from "@/shared/lib/origin";
import { apiError } from "@/shared/lib/api-error";

type IdContext = { params: Promise<{ id: string }> };

export async function getEvents() {
  try {
    await requireRoles(["ADMIN", "STAFF"]);
    return Response.json(await listEvents());
  } catch (error: unknown) { return apiError(error); }
}

export async function postEvent(request: Request) {
  try {
    await requireRoles(["ADMIN"]);       // 1. identidad y rol
    requireSameOrigin(request);           // 2. CSRF
    const input = createEventSchema.parse(await request.json()); // 3. contrato
    return Response.json(await createEvent(input), { status: 201 }); // 4. reglas + datos
  } catch (error: unknown) { return apiError(error); }
}

export async function patchEvent(request: Request, context: IdContext) {
  try {
    await requireRoles(["ADMIN"]);
    requireSameOrigin(request);
    const { id } = await context.params;
    const eventId = eventIdSchema.parse(id);
    const input = updateEventSchema.parse(await request.json());
    return Response.json(await updateDraftEvent(eventId, input));
  } catch (error: unknown) { return apiError(error); }
}
```

## 5. Rutas — solo re-exportan

```ts
// src/app/api/events/route.ts
export { getEvents as GET, postEvent as POST } from "@/features/events/backend/event.controller";
```

```ts
// src/app/api/events/[id]/route.ts
export { patchEvent as PATCH } from "@/features/events/backend/event.controller";
```

## 6. Cliente HTTP del módulo — `src/features/events/frontend/event-api.ts`

```ts
import { fetchJson } from "@/shared/lib/api-client";
import { eventDtoSchema, eventListSchema, type CreateEventInput } from "../event.schema";

export function fetchEvents(signal?: AbortSignal) {
  return fetchJson("/api/events", eventListSchema, { signal });
}

export function submitEvent(input: CreateEventInput) {
  return fetchJson("/api/events", eventDtoSchema, { method: "POST", body: JSON.stringify(input) });
}
```

El navegador del mismo origen envía `Origin` automáticamente en el POST; `requireSameOrigin` lo valida.

## 7. Utilidad de fechas (cliente) — `src/shared/lib/dates.ts`

```ts
export function localDateTimeToIso(value: string): string | null {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString();
}

export function formatEventDate(iso: string) {
  return new Intl.DateTimeFormat("es-BO", {
    dateStyle: "medium", timeStyle: "short", timeZone: "America/La_Paz",
  }).format(new Date(iso));
}
```

## 8. Formulario — `src/features/events/frontend/event-form.tsx`

```tsx
"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { HttpError } from "@/shared/lib/api-client";
import { localDateTimeToIso } from "@/shared/lib/dates";
import { Button } from "@/shared/ui/button";
import { Input } from "@/shared/ui/input";
import { Label } from "@/shared/ui/label";
import { createEventSchema, type CreateEventInput } from "../event.schema";
import { submitEvent } from "./event-api";

const fields = ["name", "startsAt", "capacity"] as const;

export function EventForm({ onSaved }: { onSaved: () => void }) {
  const [message, setMessage] = useState("");
  const { register, handleSubmit, reset, setError, formState: { errors, isSubmitting } } =
    useForm<CreateEventInput>({ resolver: zodResolver(createEventSchema) });

  const submit = handleSubmit(async (input) => {
    setMessage("");
    try {
      await submitEvent(input);
      reset();                  // solo tras éxito confirmado
      setMessage("Evento guardado");
      onSaved();
    } catch (error: unknown) {
      if (error instanceof HttpError) {
        for (const issue of error.issues ?? []) {
          const field = fields.find((f) => f === issue.path[0]);
          if (field) setError(field, { message: issue.message });
        }
        setMessage(error.status === 401 ? "Tu sesión expiró, vuelve a iniciar sesión." : error.message);
      } else {
        setMessage("No se pudo conectar con el servidor");
      }
    }
  });

  return (
    <form onSubmit={submit} noValidate className="grid max-w-md gap-3">
      <Label htmlFor="event-name">Nombre</Label>
      <Input id="event-name" {...register("name")} aria-invalid={!!errors.name} aria-describedby="event-name-error" />
      <p id="event-name-error" className="text-sm">{errors.name?.message}</p>

      <Label htmlFor="event-date">Fecha y hora</Label>
      <Input id="event-date" type="datetime-local"
        {...register("startsAt", { setValueAs: (v: string) => localDateTimeToIso(v) ?? "" })}
        aria-invalid={!!errors.startsAt} aria-describedby="event-date-error" />
      <p id="event-date-error" className="text-sm">{errors.startsAt?.message}</p>

      <Label htmlFor="event-capacity">Capacidad</Label>
      <Input id="event-capacity" type="number"
        {...register("capacity", { valueAsNumber: true })}
        aria-invalid={!!errors.capacity} aria-describedby="event-capacity-error" />
      <p id="event-capacity-error" className="text-sm">{errors.capacity?.message}</p>

      <Button disabled={isSubmitting} type="submit">{isSubmitting ? "Guardando…" : "Guardar"}</Button>
      <p role="status">{message}</p>
    </form>
  );
}
```

## 9. Listado — `src/features/events/frontend/event-list.tsx`

```tsx
"use client";
import { useEffect, useState } from "react";
import { formatEventDate } from "@/shared/lib/dates";
import type { EventDto } from "../event.schema";
import { fetchEvents } from "./event-api";

export function EventList({ revision }: { revision: number }) {
  const [events, setEvents] = useState<EventDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true); setError("");
    fetchEvents(controller.signal)
      .then((data) => { if (!controller.signal.aborted) setEvents(data); })
      .catch((err: unknown) => {
        if (!controller.signal.aborted) setError(err instanceof Error ? err.message : "Error de conexión");
      })
      .finally(() => { if (!controller.signal.aborted) setLoading(false); });
    return () => controller.abort();
  }, [revision]);

  if (loading) return <p role="status">Cargando…</p>;
  if (error) return <p role="alert">{error}</p>;
  if (events.length === 0) return <p>No hay eventos.</p>;
  return (
    <ul className="grid gap-2">
      {events.map((event) => (
        <li key={event.id}>
          {event.name} · {formatEventDate(event.startsAt)} · {event.capacity} plazas · <span>{event.status}</span>
        </li>
      ))}
    </ul>
  );
}
```

## 10. Panel del módulo — `src/features/events/frontend/events-panel.tsx`

```tsx
"use client";
import { useState } from "react";
import { EventForm } from "./event-form";
import { EventList } from "./event-list";

export function EventsPanel({ canManage }: { canManage: boolean }) {
  const [revision, setRevision] = useState(0);
  return (
    <section className="grid gap-6">
      <h1 className="text-2xl font-semibold">Eventos</h1>
      {canManage && <EventForm onSaved={() => setRevision((r) => r + 1)} />}
      <EventList revision={revision} />
    </section>
  );
}
```

`canManage` solo decide qué se **muestra**; el permiso real lo aplica `postEvent` en el servidor.

## 11. Página — `src/app/dashboard/events/page.tsx`

```tsx
import { requirePageRoles } from "@/shared/lib/access";
import { EventsPanel } from "@/features/events/frontend/events-panel";

export default async function EventsPage() {
  const user = await requirePageRoles(["ADMIN", "STAFF"]);
  return <EventsPanel canManage={user.role === "ADMIN"} />;
}
```

Variante de solo lectura sin fetch cliente: la página puede llamar `listEvents()` del servicio tras `requirePageRoles` y pasar los datos serializados (`startsAt.toISOString()`) a un componente.

## 12. Comprobación del slice

```bash
curl -i http://localhost:3000/api/events
```
→ 401 sin sesión.

```bash
curl -i http://localhost:3000/api/events -H 'Content-Type: application/json' -H 'Origin: http://localhost:3000' -d '{"name":"Noche Disco","startsAt":"2026-12-05T22:00:00-04:00","capacity":100,"status":"OPEN"}'
```
→ 401 sin sesión; con cookie de ADMIN → 400 por el campo extra `status`; sin `status` → 201.

## Adaptar a otro módulo

| Módulo | Diferencias clave respecto a `events` |
| --- | --- |
| `users` | Select sin `passwordHash`; `bcrypt.hash(password, 12)`; desactivar con PATCH `active:false`; `login-form.tsx` usa `signIn` de `next-auth/react` |
| `admissions` | Transacción: `tx.event.updateMany` condicional sobre aforo + `tx.admission.create`; check-in con `updateMany({ where: { id, checkedInAt: null } })` y ruta `POST /api/admissions/[id]/check-in` |
| `drinks` | Dos entidades (category, drink); `priceCents` entero; desactivar en vez de borrar |
| `bar-sales` | El servicio recibe `actor` de `requireRoles`; total calculado en servidor; idempotencia con `requestKey` + `requestHash` (algoritmo de `Proyecto/6`); el frontend conserva la clave en reintentos |
| `reservations` | Dos entidades (table, reservation); P2002 por `@@unique([eventId, tableId])` → 409; DELETE solo ADMIN y antes del evento |

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

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 7|Clase 7]] →

> [!abstract] Objetivo
> Implementar CRUD con capas pequeñas y respuestas de error predecibles.

## Antes de empezar

Repasa [[Semana1/CLASE 5|Clase 5]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### De una ruta que responde a una funcionalidad mantenible

CRUD significa crear, consultar, actualizar y eliminar. No define por sí solo las reglas del recurso. Crear un evento debe producir datos coherentes; editarlo puede estar restringido por su estado; borrarlo puede romper referencias de entradas. Antes de programar cuatro funciones idénticas, escribe qué comportamientos permite el producto.

La arquitectura vertical conserva esas decisiones dentro de eventos. El controlador conoce HTTP; el servicio conoce el comportamiento; el contrato define los datos. Prisma conoce persistencia, pero no puede decidir por nosotros si es razonable cerrar un evento o cambiar su capacidad.

### La entrada y la salida son contratos diferentes

Al crear recibimos nombre, fecha y capacidad. El servidor añade identidad, timestamps, estado inicial y contador. No aceptar un objeto completo del modelo como entrada reduce la superficie que alguien puede modificar.

Al responder seleccionamos datos públicos. Un listado de eventos no necesita mostrar todos sus campos internos ni todas las entradas. Un `select` explícito facilita revisar lo que sale. El cliente TypeScript puede inferir esa selección, pero el contrato HTTP sigue representando fechas como strings.

### Consultar varios o un solo registro

`findMany` devuelve una lista, incluso vacía. `findUnique` busca por una identidad o clave única y puede devolver null. Son resultados diferentes: no tener eventos en un listado no es lo mismo que pedir un ID que no existe.

Para un detalle, responde 404 cuando falte el recurso. Para un listado sin resultados, responde 200 con `[]`. Establece un orden determinista antes de limitar; si dos eventos comparten fecha, el ID como segundo criterio evita un orden indefinido.

### Edición parcial sin aceptar cualquier cosa

Un esquema de actualización puede reutilizar campos y volverlos opcionales, pero tiene que impedir un objeto vacío. Además debe distinguir omitir un campo de enviarlo como null. En nuestro evento, el nombre no puede vaciarse ni la capacidad pasar a negativa.

Las reglas que dependen del estado actual se verifican en el servicio. Validar `capacity: 100` no permite asumir que el evento todavía está en DRAFT. La próxima clase explica cómo evitar una carrera entre comprobar el estado y escribir el cambio.

### El dibujo como mapa del CRUD

Consulta [[pasosPeticion.excalidraw|el recorrido dibujado de una petición]]. Al leer el código de abajo, identifica qué función corresponde a ruta, controlador, DTO/contrato, servicio y ORM. La respuesta atraviesa esas responsabilidades de regreso; devolver el body sin confirmar la escritura no completa el recorrido.

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

El límite evita devolver toda la tabla; la paginación completa es ampliación.

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

Para `/api/events/[id]`, Next.js 16 entrega `params` asíncronos: `const { id } = await context.params`, con tipo `{ params: Promise<{ id: string }> }`. Más abajo están el detalle con 404, la edición, los cambios de estado y el borrado.

No borrar ventas ni entradas consumidas: conservar el historial. Una bebida en uso se desactiva con `available: false`; borrar un evento con dependencias devuelve 409.

### Completar una edición sobre el mismo contrato

Este ejemplo modifica eventos únicamente en DRAFT. Añade al archivo de esquemas:

```ts
export const updateEventSchema = createEventSchema.partial().refine(
  (value) => Object.keys(value).length > 0,
  { message: "Debes enviar al menos un campo" },
);
export type UpdateEventInput = z.infer<typeof updateEventSchema>;
```

Al servicio de eventos añade los imports de `ApiError` y `UpdateEventInput`, y esta función:

```ts
export async function updateDraftEvent(id: string, input: UpdateEventInput) {
  return prisma.$transaction(async (tx) => {
    const changed = await tx.event.updateMany({
      where: { id, status: "DRAFT" },
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.capacity !== undefined ? { capacity: input.capacity } : {}),
        ...(input.startsAt !== undefined ? { startsAt: new Date(input.startsAt) } : {}),
      },
    });
    if (changed.count !== 1) throw new ApiError(409, "Evento inexistente o fuera de edición");
    return tx.event.findUniqueOrThrow({
      where: { id },
      select: { id: true, name: true, startsAt: true, capacity: true, status: true },
    });
  });
}
```

La condición forma parte de la escritura, no de una consulta anterior. La transacción mantiene la edición y la lectura del resultado en la misma operación. `count` indica si una fila cumplió el filtro. En este contrato el fallo combina inexistencia y estado no editable como conflicto; si necesitas distinguir 404, documenta cómo lo harás sin perder la condición al escribir.

Conecta el servicio desde un controlador que espere params, valide `id` con `z.uuid()`, valide body y transforme errores con `apiError`.

### Conectar PATCH sin perder la organización vertical

Esta es la versión integrada del controlador, que ya usa los guards de la clase 9 (`requireRoles`, `requireSameOrigin`). Mientras estudias esta clase, identifica el recorrido; hasta tener autenticación, las escrituras sin permiso solo se prueban en local y nunca se publican. Los controladores de abajo siguen el mismo patrón.

Integra estos imports con los existentes en `src/features/events/backend/event.controller.ts`; no dupliques los que ya tiene el archivo:

```ts
import { z } from "zod";
import { updateEventSchema } from "../shared/event.schema";
import { updateDraftEvent } from "./event.service";
import { requireRoles } from "@/shared/lib/access";
import { requireSameOrigin } from "@/shared/lib/origin";
// apiError ya está importado en el controlador inicial.

export async function patchEvent(
  request: Request,
  context: { params: Promise<{ id: string }> },
) {
  try {
    await requireRoles(["ADMIN"]);
    requireSameOrigin(request);
    const { id } = await context.params;
    const eventId = z.uuid().parse(id);
    const input = updateEventSchema.parse(await request.json());
    return Response.json(await updateDraftEvent(eventId, input));
  } catch (error: unknown) { return apiError(error); }
}
```

La ruta dinámica queda pequeña, como el punto de entrada de GET/POST:

```ts
// src/app/api/events/[id]/route.ts
export { patchEvent as PATCH } from "@/features/events/backend/event.controller";
```

Observa tres validaciones distintas: el ID identifica el recurso con formato UUID, el body expresa los campos editables y el servicio exige estado DRAFT. Si el ID tiene forma válida pero no hay un evento editable, el servicio devuelve el conflicto acordado. Un ID válido no demuestra existencia ni autorización.

La respuesta contiene el registro seleccionado por el servicio, no el body original. Esta diferencia importa cuando el servidor recorta textos, convierte fechas o fija valores: el cliente debe representar lo confirmado y no asumir que todo se guardó exactamente como lo envió.

### Detalle con 404 y filtros por query

El detalle distingue «no existe» (404) de «existe pero no se puede editar» (409). Primero agrupa la selección pública en una constante para no repetirla en cada función del servicio:

```ts
// src/features/events/backend/event.service.ts (añadir; sustituye el listEvents inicial)
import type { EventStatus } from "@/generated/prisma/client";

const eventSelect = { id: true, name: true, startsAt: true, capacity: true, status: true } as const;

export async function getEvent(id: string) {
  const event = await prisma.event.findUnique({ where: { id }, select: eventSelect });
  if (!event) throw new ApiError(404, "Evento no encontrado");
  return event;
}

export function listEvents(filter: { status?: EventStatus } = {}) {
  return prisma.event.findMany({
    where: filter.status ? { status: filter.status } : {},
    select: eventSelect,
    orderBy: [{ startsAt: "desc" }, { id: "asc" }],
    take: 50,
  });
}
```

Los filtros de un listado viajan en la query (`/api/events?status=OPEN`). Llegan como texto o `null`, así que se validan igual que un body:

```ts
// src/features/events/backend/event.controller.ts (añadir o sustituir)
const listQuerySchema = z.object({
  status: z.enum(["DRAFT", "OPEN", "CLOSED"]).optional(),
});

export async function getEvents(request: Request) {
  try {
    await requireRoles(["ADMIN", "STAFF"]);
    const params = new URL(request.url).searchParams;
    const query = listQuerySchema.parse({ status: params.get("status") ?? undefined });
    return Response.json(await listEvents(query));
  } catch (error: unknown) { return apiError(error); }
}

export async function getEventById(
  _request: Request,
  context: { params: Promise<{ id: string }> },
) {
  try {
    await requireRoles(["ADMIN", "STAFF"]);
    const { id } = await context.params;
    return Response.json(await getEvent(z.uuid().parse(id)));
  } catch (error: unknown) { return apiError(error); }
}
```

`params.get("status") ?? undefined` convierte la ausencia (`null`) en campo omitido; `?status=ABIERTO` produce 400. Un estado válido sin resultados devuelve `200` con `[]`, no 404.

### Abrir y cerrar un evento

El estado avanza solo en un sentido: `DRAFT → OPEN → CLOSED`. Cada transición es una acción con su propia ruta (como el check-in de la clase 5) y la condición de origen va dentro de la escritura, igual que en la edición:

```ts
// src/features/events/backend/event.service.ts (añadir)
const requiredFrom = { OPEN: "DRAFT", CLOSED: "OPEN" } as const;

export async function changeEventStatus(id: string, to: "OPEN" | "CLOSED") {
  const changed = await prisma.event.updateMany({
    where: { id, status: requiredFrom[to] },
    data: { status: to },
  });
  if (changed.count !== 1)
    throw new ApiError(409, `Solo se puede pasar a ${to} desde ${requiredFrom[to]}`);
  return getEvent(id);
}
```

```ts
// src/features/events/backend/event.controller.ts (añadir)
function statusAction(to: "OPEN" | "CLOSED") {
  return async (request: Request, context: { params: Promise<{ id: string }> }) => {
    try {
      await requireRoles(["ADMIN"]);
      requireSameOrigin(request);
      const { id } = await context.params;
      return Response.json(await changeEventStatus(z.uuid().parse(id), to));
    } catch (error: unknown) { return apiError(error); }
  };
}
export const openEvent = statusAction("OPEN");
export const closeEvent = statusAction("CLOSED");
```

```ts
// src/app/api/events/[id]/open/route.ts
export { openEvent as POST } from "@/features/events/backend/event.controller";
// src/app/api/events/[id]/close/route.ts
export { closeEvent as POST } from "@/features/events/backend/event.controller";
```

Abrir un evento fija su capacidad: `updateDraftEvent` ya no encuentra la fila porque exige `status: "DRAFT"`. Cerrar impide nuevas emisiones porque `issueAdmission` (clase 7) exige `status: "OPEN"`. Las dos reglas se apoyan en la misma columna sin comprobaciones previas separadas.

### Eliminar un evento en DRAFT

```ts
// src/features/events/backend/event.service.ts (añadir)
export async function deleteDraftEvent(id: string) {
  const deleted = await prisma.event.deleteMany({ where: { id, status: "DRAFT" } });
  if (deleted.count !== 1) throw new ApiError(409, "Solo se eliminan eventos en DRAFT");
}
```

```ts
// src/features/events/backend/event.controller.ts (añadir)
export async function deleteEvent(request: Request, context: { params: Promise<{ id: string }> }) {
  try {
    await requireRoles(["ADMIN"]);
    requireSameOrigin(request);
    const { id } = await context.params;
    await deleteDraftEvent(z.uuid().parse(id));
    return new Response(null, { status: 204 });
  } catch (error: unknown) { return apiError(error); }
}
```

La ruta dinámica reúne las tres operaciones del recurso:

```ts
// src/app/api/events/[id]/route.ts
export {
  getEventById as GET,
  patchEvent as PATCH,
  deleteEvent as DELETE,
} from "@/features/events/backend/event.controller";
```

Si el evento en DRAFT ya tiene reservas, la FK con `onDelete: Restrict` impide el borrado: Prisma lanza `P2003` y `apiError` responde 409. 204 significa éxito sin cuerpo; no envíes `Response.json(null)`.

### Borrar no siempre significa DELETE físico

Eliminar una categoría usada puede dejar bebidas sin relación. Una FK con Restrict impide ese resultado. Puedes devolver 409 y explicar que hay recursos asociados. Una bebida vendida se desactiva; sus líneas históricas siguen apuntando a ella.

No uses un borrado lógico por costumbre sin definir qué consultas deben excluir los registros desactivados. Si `available` es false, el catálogo administrativo puede mostrar la bebida, pero el servicio de ventas debe rechazarla para nuevas ventas.

### Tratar errores como parte de la API

Los errores de validación son esperables; un nombre duplicado también puede serlo. Un error inesperado requiere diagnóstico del servidor, pero no debe enviar SQL, stack ni secretos al navegador. Traducir todos los fallos a «datos inválidos» es tan confuso como responder siempre 500.

La utilidad compartida transforma errores conocidos en HTTP. El mensaje al usuario y el registro técnico tienen propósitos distintos. Registra una operación o identificador de correlación útil sin imprimir bodies completos o credenciales. El cliente puede mostrar un mensaje breve y ofrecer reintento solo cuando tenga sentido.

### Recorrido para comprobar el CRUD

Crea un DRAFT, lista, consulta su detalle, edita su nombre y verifica el resultado. Envía un PATCH vacío y espera 400. Cambia el evento a OPEN con la acción autorizada y comprueba que la edición ya no modifica filas. Finalmente intenta borrar un recurso referenciado y observa el conflicto. Este recorrido descubre reglas que cuatro llamadas exitosas no demuestran.

### Caso desarrollado: editar sin borrar valores que no enviaste

El evento tiene nombre, fecha y capacidad. Quieres cambiar únicamente el nombre con `PATCH {"name":"Noche Retro"}`. Los campos omitidos deben conservarse. Si reconstruyes data con valores por defecto como capacity cero, estarías alterando hechos que la persona no pidió cambiar.

El schema partial acepta ausencia, pero rechaza un nombre vacío. La comprobación de al menos una propiedad rechaza `{}`. En el servicio, solo asignas campos presentes y conviertes startsAt si se envió. No asumas que null significa omitir: si un campo no permite null, se rechaza.

La condición `status: DRAFT` en la escritura impide modificar un evento ya abierto. Si otra petición lo abre mientras intentas editar, la condición se evalúa al escribir. Una consulta anterior seguida de una actualización por ID sin condición dejaría esa carrera abierta.

Al volver a leer dentro de la transacción, respondes con el registro confirmado por ese cambio. Después el controlador serializa la respuesta y la interfaz puede actualizar su copia. El servicio no necesita saber si ese nombre se escribió desde un modal o desde una página completa.

Comprueba edición de un solo campo, PATCH vacío, nombre inválido y evento OPEN. Observa campos persistidos además de los estados. El test debe demostrar que los omitidos no se borraron y que el conflicto no produjo una modificación parcial.

## Práctica guiada

Completar GET/POST de eventos y probar 201, 400 y 500 controlado sin filtrar detalles.

## Tarea para casa

Implementar lectura, edición y política de borrado/desactivación del módulo. Añadir ejemplos de requests al PR.

## Criterios de finalización

- [ ] No se mezclan rutas y persistencia.
- [ ] Los errores tienen códigos coherentes.
- [ ] Las respuestas seleccionan campos explícitos.

## Preguntas resueltas

**¿Un listado vacío es 404?**

Normalmente responde 200 con lista vacía; 404 corresponde al recurso individual no encontrado.

**¿Partial evita un PATCH vacío?**

No. Hace falta una comprobación adicional que exija algún campo.

**¿Por qué no devolver directamente el error de Prisma?**

Sus detalles internos no son el contrato público y pueden filtrar información innecesaria.

## Para profundizar

[Prisma 7: CRUD](https://www.prisma.io/docs/orm/v7/prisma-client/queries/crud) · [Route Handlers](https://nextjs.org/docs/app/getting-started/route-handlers).

## Conceptos clave de esta clase

- **CRUD:** Operaciones básicas sobre recursos, sujetas a reglas del negocio.
- **Select:** Selección explícita de campos de salida de una consulta.
- **PATCH:** Petición para cambios parciales según un contrato.
- **Restrict:** Política referencial que impide borrar una fila con dependencias.
- **Error esperado:** Fallo contemplado por el contrato, como validación o conflicto.
- **Correlación:** Identificador que permite relacionar una petición con su diagnóstico.

## Conexiones

[[Semana2/CLASE 9|Clase 9]] · [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|Convenciones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 7|Clase 7]] →

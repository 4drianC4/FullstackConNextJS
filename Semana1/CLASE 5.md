---
tipo: clase
clase: 5
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 5 — HTTP, REST y primera funcionalidad vertical

[[README|Inicio]] · [[Semana1/INDICE|Semana 1]] · ← [[Semana1/CLASE 4|Clase 4]] · [[Semana2/CLASE 6|Clase 6]] →

> [!abstract] Objetivo
> Construir una ruta HTTP pequeña usando arquitectura vertical y validación en ejecución.

## Antes de empezar

Repasa [[Semana1/CLASE 4|Clase 4]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Contrato HTTP

GET consulta, POST crea, PATCH modifica parcialmente y DELETE elimina según la política acordada. Usamos 200/201 para éxito, 400 para entrada inválida, 401 sin sesión, 403 sin permiso, 404 inexistente y 409 por conflicto. Un JSON mal formado también es 400.

En Next.js las rutas viven en `src/app/api`, pero la lógica pertenece a `src/features/<funcionalidad>`. Revisar [[Proyecto/4. Arquitectura vertical y contratos|el árbol y las dependencias]].

### Esquema y contrato

Instalar `zod@4`. Crear `src/features/events/shared/event.schema.ts`:

```ts
import { z } from "zod";
export const createEventSchema = z.object({
  name: z.string().trim().min(3).max(100),
  startsAt: z.iso.datetime({ offset: true }),
  capacity: z.number().int().min(1).max(10000),
}).strict();
export type CreateEventInput = z.infer<typeof createEventSchema>;
```

Nunca aceptar `role`, `totalCents`, contadores o IDs del usuario autenticado porque el cliente los envíe. Cada endpoint define sus campos permitidos.

### Primera ruta sin base de datos

```ts
// src/app/api/health/route.ts
export async function GET() {
  return Response.json({ status: "ok" });
}
```

```bash
curl -i http://localhost:3000/api/health
```

La ruta de salud no consulta información del negocio. Las operaciones de escritura se desarrollan y prueban solo localmente hasta integrar los permisos de las clases 8–9.

### Validar antes de persistir

```ts
const body: unknown = await request.json();
const input = createEventSchema.parse(body);
```

El controlador transforma HTTP; el servicio aplica reglas y usa Prisma. El esquema puede compartirse con el frontend; el servicio de base de datos nunca se importa allí.

## Práctica guiada

Añadir /api/health, un contrato de evento y un ejemplo válido e inválido.

## Tarea para casa

Definir rutas y contratos de tu módulo. Probar JSON incorrecto y campos inesperados.

## Criterios de finalización

- [ ] Puedes seguir petición, validación y respuesta.
- [ ] El contrato rechaza campos extra.
- [ ] La funcionalidad tiene su propia carpeta.

## Conexiones

[[Proyecto/4. Arquitectura vertical y contratos|Arquitectura y HTTP]] · [[Semana2/CLASE 6|Clase 6]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana1/INDICE|Semana 1]] · ← [[Semana1/CLASE 4|Clase 4]] · [[Semana2/CLASE 6|Clase 6]] →

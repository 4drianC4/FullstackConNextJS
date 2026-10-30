---
tipo: clase
clase: 10
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 10 — Pruebas e integración del backend

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 9|Clase 9]] · [[Semana3/CLASE 11|Clase 11]] →

> [!abstract] Objetivo
> Comprobar el backend antes de empezar la interfaz y acordar contratos estables.

## Antes de empezar

Repasa [[Semana2/CLASE 9|Clase 9]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Pruebas automatizadas pequeñas

Instalar Vitest como dependencia de desarrollo y añadir `test: vitest run` a los scripts. Los ejemplos siguientes importan rutas relativas para no depender de configurar aliases en Vitest.

```ts
// src/features/events/shared/event.schema.test.ts
import { describe, expect, it } from "vitest";
import { createEventSchema } from "./event.schema";
describe("entrada de eventos", () => {
  const valid = { name: "Noche Disco", startsAt: "2026-12-05T22:00:00-04:00", capacity: 100 };
  it("acepta un evento válido", () => {
    expect(createEventSchema.safeParse(valid).success).toBe(true);
  });
  it("rechaza capacidad negativa y campos de privilegio", () => {
    expect(createEventSchema.safeParse({ ...valid, capacity: -1 }).success).toBe(false);
    expect(createEventSchema.safeParse({ ...valid, role: "ADMIN" }).success).toBe(false);
  });
});
```

```ts
// src/shared/lib/permissions.test.ts
import { expect, it } from "vitest";
import { canAccess } from "./permissions";
it("impide al personal administrar", () => {
  expect(canAccess("STAFF", ["ADMIN"])).toBe(false);
  expect(canAccess("ADMIN", ["ADMIN"])).toBe(true);
});
```

Estas pruebas no demuestran que los endpoints ejecuten el guard: hay que comprobar la integración real.

### Matriz de integración local

Usar una base separada de prueba, migraciones y fixtures. Nunca ejecutar limpieza de datos contra producción. Obtener sesiones mediante el flujo real de Auth.js (incluido CSRF); no fabricar JWT a mano.

| Caso | Resultado |
| --- | --- |
| GET protegido sin sesión | 401 |
| POST administrativo con STAFF | 403 |
| Origen externo en mutación autenticada | 403 |
| ADMIN con JSON inválido | 400 |
| Reserva duplicada | 409, una sola fila |
| Dos ingresos simultáneos | Un éxito, un conflicto |
| Dos emisiones para una plaza restante | Una emisión, contador consistente |
| Dos ventas con la misma clave | Una sola venta; conflicto si cambia el contenido |

Conservar evidencia en el PR: request, status y comprobación de datos. La automatización de estas peticiones es una tarea del equipo después de tener el flujo de sesión funcionando; no sustituirla por mocks que omitan permisos.

### Hito de cierre de backend

Cada equipo publica contrato, ejemplos y datos de prueba. El instructor integra, ejecuta `npm run typecheck`, `npm run lint`, `npm test` y `npm run build`. Si un equipo se retrasa, usar fixtures para el resto, sin fingir que el módulo ausente está terminado.

## Práctica guiada

Ejecutar pruebas de validación/permisos y una prueba de integración de un equipo vecino.

## Tarea para casa

Completar el backend de la funcionalidad y abrir PR con evidencia. Resolver discrepancias del contrato antes del frontend.

## Criterios de finalización

- [ ] Las pruebas detectan una entrada y un permiso incorrectos.
- [ ] Los endpoints se prueban con sesiones reales.
- [ ] El contrato está integrado y documentado.

## Conexiones

[[Proyecto/5. Evaluacion y entregables|Hito de backend]] · [[semana4/CLASE 16|Clase 16]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 9|Clase 9]] · [[Semana3/CLASE 11|Clase 11]] →

---
tipo: clase
clase: 2
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 2 — TypeScript aplicado al backend

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 1|Clase 1]] · [[Semana1/CLASE 3|Clase 3]] →

> [!abstract] Objetivo
> Usar TypeScript para expresar contratos del backend sin volver a enseñar JavaScript.

## Antes de empezar

Repasa [[Semana1/CLASE 1|Clase 1]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Tipos e inferencia

TypeScript verifica código antes de ejecutarlo; los tipos se eliminan al compilar. No valida automáticamente un JSON recibido por HTTP.

```ts
type Role = "ADMIN" | "STAFF";
type EventStatus = "DRAFT" | "OPEN" | "CLOSED";

type EventSummary = {
  id: string;
  name: string;
  capacity: number;
  status: EventStatus;
};

function availablePlaces(capacity: number, sold: number): number {
  return Math.max(0, capacity - sold);
}

async function example(): Promise<EventSummary[]> {
  return [];
}
```

Usar `type` o `interface` para contratos, uniones para estados y `?` para datos opcionales. Distinguir `undefined` (ausencia) de `null` (valor explícitamente vacío). No forzar con `as` datos que todavía no se verificaron.

### unknown y estrechamiento

```ts
function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Error desconocido";
}
```

Los datos externos entran como `unknown` y se validan con Zod en la clase 5. `any` desactiva comprobaciones y no se utiliza en nuestros ejemplos.

### Contrato público frente a modelo persistido

Un usuario en la base puede tener `passwordHash`; el contrato público solo contiene `id`, `name`, `email` y `role`. No enviar un modelo completo por comodidad.

En dinero usaremos **centavos enteros**: Bs 25,50 se representa como `2550`. Para fechas HTTP usaremos ISO 8601; convertir a `Date` en el servidor y mostrar la zona horaria local en la interfaz.

### Comprobación

En la aplicación usar `strict: true` y el script `typecheck: tsc --noEmit`. Resolver el error, no silenciarlo. Todavía no usamos JSX: los archivos son `.ts`.

## Práctica guiada

Definir contratos para evento y bebida. Introducir un error de tipo y explicar el diagnóstico del compilador.

## Tarea para casa

Definir los contratos de entrada y salida de tu tarea y añadir ejemplos de JSON sin datos reales.

## Criterios de finalización

- [ ] No utilizas any.
- [ ] Distingues tipo estático y validación en ejecución.
- [ ] Los contratos no exponen datos privados.

## Conexiones

[[Proyecto/4. Arquitectura vertical y contratos|Contratos por funcionalidad]] · [[Semana1/CLASE 5|Clase 5]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 1|Clase 1]] · [[Semana1/CLASE 3|Clase 3]] →

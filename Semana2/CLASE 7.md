---
tipo: clase
clase: 7
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 7 — Relaciones, reglas de negocio y transacciones

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 6|Clase 6]] · [[Semana2/CLASE 8|Clase 8]] →

> [!abstract] Objetivo
> Hacer cumplir reglas de negocio incluso ante peticiones concurrentes.

## Antes de empezar

Repasa [[Semana2/CLASE 6|Clase 6]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Reglas concretas

- Una entrada corresponde a un evento y solo puede ingresar una vez.
- Una mesa solo tiene una reserva por evento en el MVP.
- La venta de barra usa precios de la base, no el total enviado por el cliente.
- La capacidad del evento debe ser positiva; no emitir más entradas que plazas.

Las validaciones del formulario ayudan a la UX. La garantía pertenece al servidor y, cuando corresponde, a restricciones o actualizaciones atómicas en la base.

### Registro de entrada sin sobreventa

El esquema común contiene `Event.admissionCount`. Toda emisión debe utilizar este servicio; no ofrecer otro endpoint que cree entradas saltándose el contador.

```ts
// src/features/admissions/backend/issue-admission.ts
import "server-only";
import { prisma } from "@/shared/lib/prisma";
import { ApiError } from "@/shared/lib/api-error";
export async function issueAdmission(eventId: string, holderName: string) {
  return prisma.$transaction(async (tx) => {
    const reserved = await tx.event.updateMany({
      where: { id: eventId, status: "OPEN", admissionCount: { lt: tx.event.fields.capacity } },
      data: { admissionCount: { increment: 1 } },
    });
    if (reserved.count !== 1) throw new ApiError(409, "Evento cerrado, inexistente o sin plazas");
    return tx.admission.create({ data: { eventId, holderName } });
  });
}
```

Ambos cambios se confirman juntos. Si falla la creación, el contador vuelve al valor anterior. En el MVP no hay cancelación ni reducción de capacidad después de abrir el evento; añadir esas acciones exigiría nuevas reglas.

### Ingreso una sola vez

```ts
const result = await prisma.admission.updateMany({
  where: { id: admissionId, checkedInAt: null },
  data: { checkedInAt: new Date() },
});
if (result.count !== 1) throw new ApiError(409, "Entrada inexistente o ya utilizada");
```

Dos solicitudes simultáneas no deben producir dos ingresos exitosos. Para reservas, `@@unique([eventId, tableId])` respalda la regla y un conflicto Prisma se traduce a 409.

### Dinero y ventas

Recibir `[{ drinkId, quantity }]`, validar cantidades enteras positivas, agrupar IDs repetidos y consultar bebidas disponibles. El servidor calcula `unitPriceCents * quantity`, verifica enteros seguros y persiste una copia del precio en cada línea. Ese precio histórico no cambia al editar el catálogo.

Usar una transacción para cabecera y líneas. Añadir una clave única de petición para no registrar dos ventas al repetir el envío; misma clave con contenido diferente debe devolver 409. Una transacción por sí sola no aporta idempotencia.

## Práctica guiada

Probar dos intentos de ingreso para una entrada y dos reservas para la misma mesa/evento.

## Tarea para casa

Implementar una regla crítica de tu módulo y documentar sus casos de concurrencia. Para barra, implementar total del servidor e idempotencia.

## Criterios de finalización

- [ ] El ingreso repetido falla.
- [ ] La reserva duplicada produce 409.
- [ ] Los totales no dependen del cliente.

## Conexiones

[[Proyecto/6. Modelo de datos|Restricciones del modelo]] · [[Semana2/CLASE 10|Clase 10]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 6|Clase 6]] · [[Semana2/CLASE 8|Clase 8]] →

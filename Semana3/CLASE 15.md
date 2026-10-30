---
tipo: clase
clase: 15
semana: 3
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/3
---

# Clase 15 — Consumo del backend y mutaciones

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 14|Clase 14]] · [[semana4/CLASE 16|Clase 16]] →

> [!abstract] Objetivo
> Leer datos del backend y actualizar la pantalla después de una mutación sin añadir otro gestor de estado.

## Antes de empezar

Repasa [[Semana3/CLASE 14|Clase 14]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Elegir una estrategia sencilla

Usaremos fetch, estado local y recarga explícita del listado tras guardar. Los componentes de servidor pueden leer servicios directamente; no mezclaremos dos cachés para el mismo listado. TanStack Query y Zustand quedan como ampliaciones.

### Petición cliente con cancelación

```tsx
"use client";
import { useEffect, useState } from "react";
import { z } from "zod";
const eventListSchema = z.array(z.object({
  id: z.string(), name: z.string(), startsAt: z.string(),
  capacity: z.number(), status: z.enum(["DRAFT", "OPEN", "CLOSED"]),
}));
type EventSummary = z.infer<typeof eventListSchema>[number];
export function EventList() {
  const [events, setEvents] = useState<EventSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [revision, setRevision] = useState(0);
  useEffect(() => {
    const controller = new AbortController();
    setLoading(true); setError("");
    async function load() {
      try {
        const response = await fetch("/api/events", { signal: controller.signal, cache: "no-store" });
        if (!response.ok) throw new Error(`No se pudo cargar (${response.status})`);
        const raw: unknown = await response.json();
        const data = eventListSchema.parse(raw);
        if (!controller.signal.aborted) setEvents(data);
      } catch (error: unknown) {
        if (!controller.signal.aborted) setError(error instanceof Error ? error.message : "Error de conexión");
      } finally { if (!controller.signal.aborted) setLoading(false); }
    }
    void load();
    return () => controller.abort();
  }, [revision]);
  return <section>
    <button onClick={() => setRevision((r) => r + 1)}>Actualizar</button>
    {loading ? <p role="status">Cargando…</p> : error ? <p role="alert">{error}</p> :
      events.length === 0 ? <p>No hay eventos.</p> :
      <ul>{events.map((event) => <li key={event.id}>{event.name}</li>)}</ul>}
  </section>;
}
```

Mover el esquema de respuesta a `features/events/shared` para que sea un contrato común. Las fechas JSON son strings, no objetos `Date`.

### Conectar mutaciones

Elevar `revision` al componente padre. Pasar `onSaved` al formulario; llamarlo solo después de una respuesta exitosa y aumentar revisión para recargar. Así el usuario ve el dato confirmado por servidor. `router.refresh()` no vuelve a ejecutar por sí mismo un efecto cliente con dependencias sin cambios.

Para entradas y ventas no aplicaremos optimistic UI: primero confirmar la operación. Una reserva rechazada con 409 conserva el formulario y explica que la mesa ya no está disponible. Una sesión expirada conduce al login sin tratar el HTML de redirección como JSON válido.

## Práctica guiada

Integrar formulario y listado, y comprobar que una creación aparece sin recargar el navegador.

## Tarea para casa

Completar un flujo real del módulo usando el backend compartido. Añadir reintento y estado vacío.

## Criterios de finalización

- [ ] Se comprueba response.ok.
- [ ] Se cancelan peticiones al desmontar.
- [ ] Una mutación exitosa actualiza el listado.

## Conexiones

[[Semana3/CLASE 14|Clase 14]] · [[semana4/CLASE 16|Clase 16]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 14|Clase 14]] · [[semana4/CLASE 16|Clase 16]] →

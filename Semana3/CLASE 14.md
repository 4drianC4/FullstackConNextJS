---
tipo: clase
clase: 14
semana: 3
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/3
---

# Clase 14 — Formularios con React Hook Form y Zod

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 13|Clase 13]] · [[Semana3/CLASE 15|Clase 15]] →

> [!abstract] Objetivo
> Conectar formularios tipados y mostrar errores del cliente y del servidor.

## Antes de empezar

Repasa [[Semana3/CLASE 13|Clase 13]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Un esquema, dos validaciones

Instalar `react-hook-form@7`, `@hookform/resolvers` y `zod@4`. El frontend reutiliza el esquema de eventos de la clase 5, pero el servidor vuelve a validar cada petición.

El contrato exige fecha ISO con zona. Un input `datetime-local` no incluye zona: convertirlo desde la hora local con `new Date(value).toISOString()` antes de validar/enviar. Documentar la zona del equipo y mostrar fechas en `America/La_Paz`.

### Formulario mínimo

```tsx
"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { createEventSchema, type CreateEventInput } from "../shared/event.schema";
export function EventForm() {
  const [message, setMessage] = useState("");
  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<CreateEventInput>({
    resolver: zodResolver(createEventSchema),
  });
  const submit = handleSubmit(async (input) => {
    setMessage("");
    try {
      const response = await fetch("/api/events", {
        method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(input),
      });
      if (!response.ok) { setMessage(`No se guardó el evento (${response.status}).`); return; }
      reset();
      setMessage("Evento guardado");
    } catch { setMessage("No se pudo conectar con el servidor"); }
  });
  return <form onSubmit={submit}>
    <label htmlFor="event-name">Nombre</label>
    <input id="event-name" {...register("name")} aria-invalid={!!errors.name} aria-describedby="event-name-error" />
    <p id="event-name-error">{errors.name?.message}</p>
    <label htmlFor="event-date">Fecha ISO con zona</label>
    <input id="event-date" placeholder="2026-12-05T22:00:00-04:00" {...register("startsAt")} />
    <p>{errors.startsAt?.message}</p>
    <label htmlFor="event-capacity">Capacidad</label>
    <input id="event-capacity" type="number" {...register("capacity", { valueAsNumber: true })} />
    <p>{errors.capacity?.message}</p>
    <button disabled={isSubmitting} type="submit">{isSubmitting ? "Guardando…" : "Guardar"}</button>
    <p role="status">{message}</p>
  </form>;
}
```

El primer ejemplo usa texto ISO para que la conversión sea explícita. En la práctica añadir el input local y un adaptador de formulario, sin cambiar el contrato de la API.

### Login del personal

Crear `/login` como Client Component con `signIn` de `next-auth/react`. Enviar `signIn("credentials", { email, password, redirect: false })`, mostrar un error genérico ante fallo y navegar al panel en éxito. Para salir usar `signOut`. No persistir la contraseña ni imprimirla en consola. El instructor guía esta integración con el equipo de usuarios.

Un botón deshabilitado reduce envíos repetidos en la interfaz, pero no reemplaza la idempotencia del backend de ventas.

## Práctica guiada

Crear un evento y probar errores de campo, sesión expirada y desconexión.

## Tarea para casa

Completar los formularios del módulo y el login compartido. Conservar los valores si falla el servidor y documentar la conversión de fechas.

## Criterios de finalización

- [ ] Se valida en ambos extremos.
- [ ] Los fallos no se muestran como éxitos.
- [ ] Se evita el doble clic mientras se envía.

## Conexiones

[[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 8|Clase 8]] · [[Semana3/CLASE 15|Clase 15]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 13|Clase 13]] · [[Semana3/CLASE 15|Clase 15]] →

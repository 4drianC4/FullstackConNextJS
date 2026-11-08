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

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 13|Clase 13]] · [[Semana3/CLASE 15|Clase 15]] →

> [!abstract] Objetivo
> Conectar formularios tipados y mostrar errores del cliente y del servidor.

## Antes de empezar

Repasa [[Semana3/CLASE 13|Clase 13]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Tres capas de validación con trabajos diferentes

El navegador puede comprobar required o un tipo numérico. React Hook Form organiza valores y errores en la interfaz. Zod describe el contrato y lo comprueba en ejecución. El servidor valida otra vez porque una petición puede enviarse sin utilizar ese formulario.

No es trabajo duplicado sin sentido. La validación cliente da feedback rápido; la del servidor protege la frontera de confianza; las restricciones de base sostienen integridad incluso cuando hay concurrencia. Cada una detecta situaciones que otra no puede resolver por sí sola.

### Controlado y no controlado

En un input controlado, React mantiene el valor y responde a cambios. En uno no controlado, el elemento conserva el valor y el programa lo consulta o registra. React Hook Form utiliza registro y suscripciones para organizar formularios sin obligarte a mantener un useState por cada campo.

`register("name")` conecta el control con la librería. `handleSubmit` coordina validación y entrega datos al handler. `formState.errors` expone fallos de campo; `isSubmitting` representa el envío que la librería está esperando. Para que funcione, devuelve o espera la promesa del envío en el callback.

`zodResolver` adapta el resultado de Zod al formato de errores del formulario. No crea un endpoint ni envía datos automáticamente. Si el schema transforma entradas, distingue su tipo de entrada y salida al configurar genéricos: el formulario y el servicio no siempre ven exactamente la misma representación.

### Los inputs no devuelven siempre lo que parece

Un input de número empieza como valor textual del DOM. `valueAsNumber` convierte al leer, pero un campo vacío puede producir NaN. Zod debe rechazarlo y mostrar un mensaje útil; no lo conviertas silenciosamente en cero si cero incumple la regla.

Un checkbox se maneja como boolean según su registro; un select representa opciones acordadas. No permitas que un valor mostrado como «Administrador» se convierta sin autorización en un rol persistido. Los controles de interfaz no otorgan privilegios.

### Fecha local e instante

`datetime-local` describe una fecha y hora sin zona. El contrato del backend pide un instante ISO con offset. Esta diferencia debe resolverse con un adaptador. No concatenar `Z` al final como si cualquier hora elegida estuviera en UTC.

`new Date(localValue).toISOString()` interpreta el valor con la zona del navegador. Es correcto solo si esa es la zona de entrada acordada. Para el curso se trabaja con la zona local de la discoteca; si el equipo está configurado en otra zona, el resultado no expresa necesariamente la intención. Verifica la configuración o utiliza una conversión de zona explícita. La nota [[Recursos/Conceptos/Fechas dinero y contratos|Fechas, dinero y contratos]] explica la diferencia.

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

Crear `/login` como Client Component con `signIn` de `next-auth/react`. Enviar `signIn("credentials", { email, password, redirect: false })`, mostrar un error genérico ante fallo y navegar al panel en éxito. Para salir usar `signOut`. No persistir la contraseña ni imprimirla en consola. Acuerda los nombres de campos y las respuestas con la funcionalidad de usuarios para compartir un solo flujo de acceso.

Un botón deshabilitado reduce envíos repetidos en la interfaz, pero no reemplaza la idempotencia del backend de ventas.

### Un adaptador de fecha que reconoce errores

Para mejorar el ejemplo ISO sin cambiar el contrato del backend, puedes preparar la conversión en una función pequeña:

```ts
export function localDateTimeToIso(value: string): string | null {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString();
}
```

Esta función no elige una zona distinta ni valida reglas como fecha futura: convierte según el entorno local. Mantener claras esas limitaciones evita afirmar que una conversión sintáctica resuelve todos los problemas de calendario.

Un campo vacío o inválido produce un error de campo antes del envío. Un instante válido puede incumplir una regla del evento en el servidor. Ambas respuestas deben ser visibles sin perder lo que el usuario ya escribió.

### Secuencia de envío

Al pulsar guardar, valida valores, muestra errores si hay y deshabilita el envío mientras está pendiente. En éxito, confirma el resultado, limpia cuando tenga sentido y notifica al listado. En fallo, conserva el borrador y explica qué se puede corregir.

El ejemplo comprueba response.ok antes de reset. Eso evita un formulario vacío con mensaje de éxito cuando el servidor respondió 403 o 409. Un error de red cae en catch; un 400 no lo hace automáticamente con fetch. Hay que leer el estado y su cuerpo de error según el contrato.

Para errores 400 con issues, puedes mapear los paths conocidos a `setError`. No utilices cualquier path arbitrario como nombre de campo sin comprobar que pertenece al formulario. Para 401, ofrece volver a iniciar sesión; para 409, explica el conflicto; para 500, no inventes un campo culpable.

### Login con nombres accesibles

El formulario compartido debe tener labels «Correo» y «Contraseña» y un botón «Entrar», coherentes con las pruebas de navegador. Envía credenciales mediante signIn de la librería, muestra error genérico y navega al panel solo si la autenticación fue exitosa.

No guardes password en localStorage ni añadas un log del formulario para inspeccionar el payload. Los valores de contraseña se necesitan durante el acceso, no como historial de depuración. El cierre de sesión debe usar el flujo de signOut para limpiar la sesión correctamente.

### Evitar duplicados sin culpar al usuario

Deshabilitar el botón previene clics adicionales en esa instancia, pero no controla pestañas diferentes ni respuestas perdidas. La venta necesita clave idempotente en el servidor y un manejo del borrador que preserve esa clave durante el reintento de la misma intención.

Un evento creado y una reserva tienen reglas distintas. No apliques indiscriminadamente «vaciar todo al recibir cualquier respuesta». Define qué confirma cada endpoint y cómo se recupera la persona después del fallo.

### Revisar el formulario completo

Prueba campos vacíos, límites, valores mal formados, sesión expirada, respuesta 409 y desconexión. Navega con teclado y comprueba que el error permanece asociado al control. Luego guarda un dato válido y verifica su aparición real en el listado y la base, no solo el toast.

## Práctica guiada

Crear un evento y probar errores de campo, sesión expirada y desconexión.

## Tarea para casa

Completar los formularios del módulo y el login compartido. Conservar los valores si falla el servidor y documentar la conversión de fechas.

## Criterios de finalización

- [ ] Se valida en ambos extremos.
- [ ] Los fallos no se muestran como éxitos.
- [ ] Se evita el doble clic mientras se envía.

## Preguntas resueltas

**¿Fetch lanza por recibir 400?**

No. Debes comprobar el estado HTTP; catch atiende fallos como red o excepciones del procesamiento.

**¿Añadir Z convierte una hora local correctamente?**

No. Z declara UTC y puede cambiar el instante pretendido si solo se concatena.

**¿Deshabilitar guardar hace idempotente la venta?**

No. La garantía debe estar en el servidor con la clave y reglas de comparación.

## Para profundizar

[React Hook Form](https://react-hook-form.com/docs/useform) · [Zod](https://zod.dev/api).

## Conceptos clave de esta clase

- **Resolver:** Adaptador que conecta una validación externa con el formulario.
- **Borrador:** Valores que el usuario aún no ha confirmado como una operación completa.
- **Submit:** Intento de enviar el formulario.
- **NaN:** Valor numérico que indica una conversión o cálculo no válido.
- **Offset:** Diferencia horaria expresada respecto de UTC.
- **Reset:** Restablecimiento de valores del formulario, que debe ocurrir en el momento correcto.

## Conexiones

[[Semana1/CLASE 5|Clase 5]] · [[Semana2/CLASE 8|Clase 8]] · [[Semana3/CLASE 15|Clase 15]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 13|Clase 13]] · [[Semana3/CLASE 15|Clase 15]] →

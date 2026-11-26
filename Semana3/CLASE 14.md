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

`new Date(localValue).toISOString()` interpreta el valor con la zona del navegador. Es correcto solo si esa es la zona de entrada acordada. Para el curso se trabaja con la zona local de la discoteca; si el equipo está configurado en otra zona, el resultado no expresa necesariamente la intención. Verifica la configuración o utiliza una conversión de zona explícita. Las fechas se muestran en `America/La_Paz`. La nota [[Recursos/Conceptos/Fechas dinero y contratos|Fechas, dinero y contratos]] explica la diferencia.

### Un esquema, dos validaciones

Instalar `react-hook-form@7`, `@hookform/resolvers` y `zod@4`. El frontend reutiliza el esquema de eventos de la clase 5, pero el servidor vuelve a validar cada petición.

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

El primer ejemplo usa texto ISO para que la conversión sea explícita. Más abajo está la versión con `datetime-local`, un adaptador y los errores del servidor asociados a cada campo, sin cambiar el contrato de la API.

### Login del personal

El login es un Client Component que usa `signIn` de `next-auth/react`. Las etiquetas «Correo» y «Contraseña» y el botón «Entrar» son las que usan las pruebas de navegador de la clase 16; acuérdalas con el equipo de Usuarios para que haya un solo flujo de acceso.

```tsx
// src/features/users/frontend/login-form.tsx
"use client";
import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { signIn } from "next-auth/react";

export function LoginForm() {
  const router = useRouter();
  const [error, setError] = useState("");
  const [pending, setPending] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setPending(true);
    const data = new FormData(event.currentTarget);
    try {
      const result = await signIn("credentials", {
        email: String(data.get("email") ?? ""),
        password: String(data.get("password") ?? ""),
        redirect: false,
      });
      if (!result || result.error) {
        setError("Correo o contraseña incorrectos");
        return;
      }
      router.push("/dashboard");
      router.refresh();
    } catch {
      setError("No se pudo conectar con el servidor");
    } finally {
      setPending(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="mx-auto max-w-sm space-y-4 p-4">
      <h1 className="text-2xl font-bold">Acceso del personal</h1>
      <div className="space-y-2">
        <label htmlFor="login-email">Correo</label>
        <input id="login-email" name="email" type="email" autoComplete="username" required
          className="w-full rounded-md border p-2" />
      </div>
      <div className="space-y-2">
        <label htmlFor="login-password">Contraseña</label>
        <input id="login-password" name="password" type="password" autoComplete="current-password" required
          className="w-full rounded-md border p-2" />
      </div>
      <p role="alert">{error}</p>
      <button type="submit" disabled={pending}>{pending ? "Entrando…" : "Entrar"}</button>
    </form>
  );
}
```

```tsx
// src/app/login/page.tsx
import { LoginForm } from "@/features/users/frontend/login-form";
export default function LoginPage() {
  return <main><LoginForm /></main>;
}
```

```tsx
// src/features/users/frontend/logout-button.tsx
"use client";
import { signOut } from "next-auth/react";
export function LogoutButton() {
  return <button type="button" onClick={() => signOut({ redirectTo: "/login" })}>Salir</button>;
}
```

- `redirect: false` hace que `signIn` devuelva un resultado en vez de navegar; así puedes mostrar el error en la misma pantalla. El mensaje es genérico: no dice si el correo existe ni si la cuenta está desactivada o bloqueada por intentos.
- `router.refresh()` vuelve a ejecutar los componentes de servidor para que lean la sesión nueva.
- `FormData` se lee antes del primer `await`, mientras `event.currentTarget` sigue disponible.
- No guardes la contraseña en estado, `localStorage` ni logs. `autoComplete` ayuda al gestor de contraseñas del navegador.
- Salir siempre con `signOut`: borra la cookie de sesión correctamente.

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

Guárdala en `src/features/events/frontend/local-date-time.ts`. Esta función no elige una zona distinta ni valida reglas como fecha futura: convierte según el entorno local. Mantener claras esas limitaciones evita afirmar que una conversión sintáctica resuelve todos los problemas de calendario.

Un campo vacío o inválido produce un error de campo antes del envío. Un instante válido puede incumplir una regla del evento en el servidor. Ambas respuestas deben ser visibles sin perder lo que el usuario ya escribió.

### Formulario completo: fecha local y errores del servidor

Esta versión sustituye la del principio. El formulario valida el valor del input (`datetime-local`, sin zona) y la API sigue recibiendo el contrato original con ISO y offset. Los `issues` de un 400 se asocian a su campo con `setError`:

```tsx
// src/features/events/frontend/event-form.tsx
"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createEventSchema } from "../shared/event.schema";
import { localDateTimeToIso } from "./local-date-time";

// El formulario trabaja con el texto del input; la conversión a ISO ocurre al enviar
const eventFormSchema = createEventSchema.extend({
  startsAt: z.string().min(1, "Elige fecha y hora"),
});
type EventFormValues = z.infer<typeof eventFormSchema>;

const formFields = ["name", "startsAt", "capacity"] as const;
type FormField = (typeof formFields)[number];
const isFormField = (value: unknown): value is FormField =>
  typeof value === "string" && (formFields as readonly string[]).includes(value);

const errorBodySchema = z.object({
  error: z.string(),
  issues: z.array(z.object({
    path: z.array(z.union([z.string(), z.number()])),
    message: z.string(),
  })).optional(),
});

export function EventForm({ onSaved }: { onSaved?: () => void }) {
  const [message, setMessage] = useState("");
  const { register, handleSubmit, reset, setError, formState: { errors, isSubmitting } } =
    useForm<EventFormValues>({ resolver: zodResolver(eventFormSchema) });

  const submit = handleSubmit(async (values) => {
    setMessage("");
    const startsAt = localDateTimeToIso(values.startsAt);
    if (!startsAt) {
      setError("startsAt", { message: "Fecha y hora no válidas" });
      return;
    }
    try {
      const response = await fetch("/api/events", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...values, startsAt }),
      });
      if (response.ok) {
        reset();
        setMessage("Evento guardado");
        onSaved?.();
        return;
      }
      const body = errorBodySchema.safeParse(await response.json().catch(() => null));
      if (response.status === 400 && body.success && body.data.issues) {
        for (const issue of body.data.issues) {
          const field = issue.path[0];
          if (isFormField(field)) setError(field, { message: issue.message });
        }
        return;
      }
      if (response.status === 401) {
        setMessage("Tu sesión expiró. Vuelve a iniciar sesión; los datos siguen en el formulario.");
        return;
      }
      setMessage(body.success ? body.data.error : `No se guardó el evento (${response.status}).`);
    } catch {
      setMessage("No se pudo conectar con el servidor");
    }
  });

  return (
    <form onSubmit={submit} noValidate className="space-y-4">
      <label htmlFor="event-name">Nombre</label>
      <input id="event-name" {...register("name")}
        aria-invalid={!!errors.name} aria-describedby="event-name-error" />
      <p id="event-name-error">{errors.name?.message}</p>

      <label htmlFor="event-date">Fecha y hora (hora de La Paz)</label>
      <input id="event-date" type="datetime-local" {...register("startsAt")}
        aria-invalid={!!errors.startsAt} aria-describedby="event-date-error" />
      <p id="event-date-error">{errors.startsAt?.message}</p>

      <label htmlFor="event-capacity">Capacidad</label>
      <input id="event-capacity" type="number" {...register("capacity", { valueAsNumber: true })}
        aria-invalid={!!errors.capacity} aria-describedby="event-capacity-error" />
      <p id="event-capacity-error">{errors.capacity?.message}</p>

      <button disabled={isSubmitting} type="submit">{isSubmitting ? "Guardando…" : "Guardar"}</button>
      <p role="status">{message}</p>
    </form>
  );
}
```

- `extend` reutiliza nombre y capacidad del contrato y solo cambia `startsAt` para el formulario. El servidor sigue validando con `createEventSchema`.
- Solo se aceptan paths que existen en el formulario (`isFormField`); un path desconocido no se convierte en un campo inventado.
- 401, 403, 409 y 500 muestran un mensaje general y **no** vacían el formulario. Solo `response.ok` llama a `reset()` y a `onSaved`, que la clase 15 usa para recargar el listado.
- `noValidate` desactiva los globos nativos del navegador para que los mensajes de Zod sean los únicos visibles.

### Secuencia de envío

Al pulsar guardar, valida valores, muestra errores si hay y deshabilita el envío mientras está pendiente. En éxito, confirma el resultado, limpia cuando tenga sentido y notifica al listado. En fallo, conserva el borrador y explica qué se puede corregir.

El ejemplo comprueba response.ok antes de reset. Eso evita un formulario vacío con mensaje de éxito cuando el servidor respondió 403 o 409. Un error de red cae en catch; un 400 no lo hace automáticamente con fetch. Hay que leer el estado y su cuerpo de error según el contrato.

Para errores 400 con issues, puedes mapear los paths conocidos a `setError`. No utilices cualquier path arbitrario como nombre de campo sin comprobar que pertenece al formulario. Para 401, ofrece volver a iniciar sesión; para 409, explica el conflicto; para 500, no inventes un campo culpable.

### Evitar duplicados sin culpar al usuario

Deshabilitar el botón previene clics adicionales en esa instancia, pero no controla pestañas diferentes ni respuestas perdidas. La venta necesita clave idempotente en el servidor y un manejo del borrador que preserve esa clave durante el reintento de la misma intención.

Un evento creado y una reserva tienen reglas distintas. No apliques indiscriminadamente «vaciar todo al recibir cualquier respuesta». Define qué confirma cada endpoint y cómo se recupera la persona después del fallo.

### Revisar el formulario completo

Prueba campos vacíos, límites, valores mal formados, sesión expirada, respuesta 409 y desconexión. Navega con teclado y comprueba que el error permanece asociado al control. Luego guarda un dato válido y verifica su aparición real en el listado y la base, no solo el toast.

### Caso desarrollado: la fecha del evento aparece cuatro horas corrida

Una persona escribe «5 de diciembre, 22:00» en un datetime-local. El cliente concatena Z y envía `2026-12-05T22:00:00Z`. Z declara que esas 22:00 ya son UTC. Al mostrar ese instante en America/La_Paz, aparece a las 18:00 del mismo día.

La intención original era 22:00 en la zona de la discoteca, no 22:00 UTC. El contrato debe convertir desde la zona de entrada acordada y transportar el instante con offset o en UTC equivalente. El formato válido por sí solo no indica que se interpretó correctamente la intención.

Si el navegador del equipo trabaja en la zona acordada, new Date(localValue).toISOString aplica esa interpretación local. Si no, necesitas conversión explícita con una solución de zona apropiada. Documenta la política en vez de depender del país de quien usa la aplicación.

Al recuperar la fecha, formatea con timeZone America/La_Paz para la operación del local. Prueba instantes próximos a medianoche, donde un cambio de zona puede cambiar también el día. Comprueba tanto JSON como valor mostrado.

Esta clase no exige construir un calendario internacional completo, pero sí reconocer que input local, instante persistido y texto visible son representaciones diferentes. Nombrarlas y probar su frontera evita muchos bugs que parecen aleatorios.

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

# Día 16: Fullstack I - Testing End-to-End, Sincronización y UX

## 1. Testing Manual End-to-End (E2E)

### El Vacío Teórico: La Pirámide del Testing

Normalmente, los desarrolladores prueban su código revisando funciones individuales (Unit Testing) o viendo si un componente se renderiza bien (Integration Testing). Sin embargo, en el mundo real, los usuarios no usan "funciones", usan "flujos".

El **Testing End-to-End (E2E o De extremo a extremo)** consiste en simular el comportamiento de un usuario real, desde que entra a la página web, hace clics, llena formularios y espera que la base de datos se actualice correctamente.

### ¿Cómo hacer Testing Manual E2E efectivo?

Antes de usar herramientas automatizadas complejas como _Cypress_ o _Playwright_ (que se ven en cursos avanzados), todo equipo debe saber hacer testing manual riguroso. Para esto, no probamos a lo loco, creamos **Casos de Uso (Test Cases)**.

Debes poner a prueba dos caminos principales:

1. **El "Happy Path" (El Camino Feliz):** El usuario hace exactamente lo que esperas. Entra al login, pone credenciales correctas y entra al Dashboard. Todo sale bien.
    
2. **Los "Edge Cases" (Casos Extremos / Camino Triste):** Aquí es donde el software suele romperse.
    
    - ¿Qué pasa si el usuario intenta enviar el formulario de registro con el internet apagado?
        
    - ¿Qué pasa si hace doble clic rapidísimo en el botón de "Pagar"?
        
    - ¿Qué pasa si pone un emoji en el campo de "Edad"?
        

**Regla de oro del Testing Fullstack:** Nunca asumas que el Frontend va a detener un error. Si un usuario salta tu validación de Zod en el navegador y manda datos corruptos, tu API Backend **debe** rechazar esa petición y no dejar que la base de datos se corrompa.

---

## 2. Sincronización Frontend/Backend (El problema de la verdad)

Cuando tienes una aplicación Fullstack, tienes un problema fundamental: **¿Dónde está la verdad?** * La verdad "absoluta" vive en tu base de datos (Backend).

- La verdad "temporal" vive en la pantalla del usuario (Frontend / Caché).
    

### El Vacío Teórico: La Desincronización

Imagina que dos usuarios (Ana y Carlos) están viendo la misma lista de tareas en sus respectivas computadoras. Ana borra la "Tarea 1". El servidor elimina la Tarea 1. Pero la pantalla de Carlos sigue mostrando la Tarea 1 porque su Frontend no se ha enterado del cambio. Si Carlos intenta editar la Tarea 1, el servidor le lanzará un error 500 porque ese registro ya no existe.

### Soluciones Prácticas con TanStack Query

En el Día 14 usamos TanStack Query. Esta librería tiene configuraciones nativas para mantener sincronizado el Frontend con el Backend sin escribir código extra:

- **`refetchOnWindowFocus`:** Si Carlos minimiza el navegador y luego vuelve a abrir la pestaña de tu app, TanStack Query automáticamente hace un `fetch` silencioso de fondo para actualizar los datos.
    
- **`refetchOnReconnect`:** Si Carlos pierde la conexión a internet (entra a un túnel) y la recupera, la app pide los datos más frescos automáticamente.
    
- **Polling:** Para datos muy críticos (ej. precio del Bitcoin), puedes decirle a TanStack Query que pregunte al servidor cada 5 segundos: `useQuery({ refetchInterval: 5000 })`.
    

---

## 3. Llevando la Optimistic UI al Límite (Rollbacks)

En el Día 15 vimos cómo la **Optimistic UI** (engañar al usuario asumiendo que el servidor dirá que "sí" a una mutación) hace que la app se sienta rapidísima.

Pero en una revisión Fullstack real, tenemos que planear el **Rollback** (dar marcha atrás).

**El Flujo Completo de la Experiencia de Usuario (UX):**

1. **Acción:** El usuario le da "Like" a un Post.
    
2. **Optimismo:** El corazón se pone rojo en el Frontend al instante.
    
3. **Desastre:** El servidor responde con Error 500 (La base de datos se cayó).
    
4. **Rollback:** El Frontend le quita el color rojo al corazón silenciosamente.
    
5. **¡Feedback!:** Aquí fallan muchos desarrolladores. Si le quitas el color rojo y no dices nada, el usuario pensará que no hizo clic bien y volverá a hacer clic. Debes informarle.
    

---

## 4. Feedback al Usuario: Toasts y Snackbars

Para darle feedback al usuario sin arruinar su experiencia, no uses el viejo y molesto `alert("Error")` que bloquea toda la pantalla. La industria usa **Toasts** (notificaciones no bloqueantes que aparecen en una esquina y desaparecen solas).

En Next.js y `shadcn/ui`, el estándar actual es usar una librería llamada **Sonner**.

### Implementación de Feedback Fullstack

1. Primero, agregas el componente base en tu `layout.tsx` para que esté disponible en toda la app:
```Typescript

import { Toaster } from "@/components/ui/sonner"

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Toaster /> {/* Aquí vivirán todas las notificaciones */}
      </body>
    </html>
  )
}
```
2. Luego, lo conectas a tus peticiones reales (ej. en el rollback de tu mutación):
```Typescript

"use client";
import { toast } from "sonner";
import { useMutation } from "@tanstack/react-query";

export function BotonLike({ postId }) {
  const mutation = useMutation({
    mutationFn: () => fetch(`/api/posts/${postId}/like`, { method: "POST" }),
    onMutate: () => {
      // 1. (Optimistic UI) Ponemos el corazón rojo aquí...
    },
    onError: () => {
      // 2. (Rollback) Quitamos el corazón rojo porque falló...
      
      // 3. (Feedback) Le explicamos al usuario qué pasó, con estilo.
      toast.error("No se pudo guardar tu Me gusta", {
        description: "Revisa tu conexión a internet e intenta de nuevo.",
        action: {
          label: "Reintentar",
          onClick: () => mutation.mutate(), // Damos una solución fácil
        },
      });
    },
    onSuccess: () => {
      // Opcional: Feedback positivo para acciones grandes (ej. Crear cuenta)
      toast.success("¡Like guardado correctamente!");
    }
  });

  return <button onClick={() => mutation.mutate()}>Dar Like</button>;
}
```

---
### Resumen del Día 16

El Frontend y el Backend ya no son entes separados, hoy aprendimos a tratarlos como **un solo ecosistema**:

- Comprendimos que el **Testing E2E** va más allá de ver si el código compila; es garantizar que los flujos (el Camino Feliz y los Casos Extremos) funcionen para el usuario.
- Entendimos la importancia de la **Sincronización**, dejando que herramientas como TanStack Query refresquen los datos cuando la pestaña recupera el foco.
- Unimos la **Optimistic UI con el Feedback**, garantizando que si nuestro "engaño visual" falla por culpa del servidor, hacemos un rollback limpio y avisamos al usuario mediante **Toasts** elegantes, ofreciendo siempre una forma de recuperarse del error.
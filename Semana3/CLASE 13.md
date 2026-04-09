# Día 13: Frontend III - Estado y Formularios

Si el Día 12 fue sobre cómo se ve nuestra aplicación, el Día 13 es sobre cómo se siente y cómo interactúa con el usuario. Hoy abordaremos dos de los temas que históricamente han causado más dolores de cabeza en React: el manejo del estado global y la gestión de formularios complejos.

---
## 1. Gestión de Estado Global con Zustand

### Local State vs. Prop Drilling vs. Global State

En React, el estado es la memoria del componente (ej. saber si un menú está abierto o cerrado). Normalmente usamos `useState` para esto, lo cual se llama **Estado Local**.

El problema surge cuando varios componentes separados necesitan acceder a la misma "memoria". Imagina un carrito de compras:

- El componente `<BotonAgregar />` (dentro de una lista de productos) necesita actualizar el número de ítems.
- El componente `<Navbar />` (en la parte superior de la página) necesita mostrar ese número

Si usas el estado local, tendrías que pasar la información de componente padre a componente hijo, a nieto, a bisnieto... Esto se conoce como **Prop Drilling** (Perforación de Props) y hace que tu código sea un infierno de mantener.

### Las soluciones antiguas:
- **Redux:** El estándar de la industria por años, pero requiere escribir cientos de líneas de código extra (boilerplate) solo para actualizar un simple número.
- **Context API (nativo de React):** Fácil de usar, pero tiene un problema de rendimiento grave: si el carrito de compras se actualiza, **TODOS** los componentes envueltos en ese contexto se vuelven a renderizar (parpadean en memoria), aunque no necesiten el carrito.

### La Solución Moderna: Zustand
Zustand (que significa "estado" en alemán) es un gestor de estado global microscópico, rápido y sin dolores de cabeza. Funciona por fuera del árbol de React, por lo que evita renders innecesarios.

**Ejemplo: Creando un "Store" (Almacén) para el carrito:**
```Typescript

// src/store/cartStore.ts
import { create } from 'zustand';

// 1. Definimos la forma de nuestros datos (TypeScript)
interface CartState {
  items: number;
  increment: () => void;
  clearCart: () => void;
}

// 2. Creamos el almacén global
export const useCartStore = create<CartState>((set) => ({
  items: 0,
  // La función 'set' nos permite actualizar el estado
  increment: () => set((state) => ({ items: state.items + 1 })),
  clearCart: () => set({ items: 0 }),
}));
```
**Usándolo en nuestros componentes (¡Sin Prop Drilling!):**
```Typescript

"use client";
import { useCartStore } from '@/src/store/cartStore';

// Componente 1 (En cualquier parte del árbol)
export const Navbar = () => {
  // Solo extraemos lo que necesitamos. Si otra cosa del store cambia, este navbar NO se renderiza de nuevo.
  const items = useCartStore((state) => state.items); 
  return <nav>Carrito: {items}</nav>;
}

// Componente 2 (En otra parte del árbol)
export const BotonComprar = () => {
  const increment = useCartStore((state) => state.increment);
  return <button onClick={increment}>Agregar al Carrito</button>;
}
```

---
## 2. Formularios Eficientes con React Hook Form

### Componentes Controlados vs. No Controlados

En el React clásico, los formularios se manejan mediante **Componentes Controlados**. Esto significa que por cada input (nombre, email, contraseña), creas un `useState`. Cada vez que el usuario teclea _una sola letra_, ejecutas un `onChange` que actualiza el estado, lo cual provoca que **todo el formulario se vuelva a renderizar en pantalla**.

Si tienes un formulario de 10 campos y un usuario teclea rápido, tu componente se renderiza decenas de veces por segundo. En computadoras lentas, el teclado se sentirá "trabado" o con lag (latencia).

### La Solución: React Hook Form (RHF)

RHF utiliza **Componentes No Controlados**. En lugar de seguir cada pulsación de tecla con un estado, RHF simplemente "engancha" (registra) el input de HTML usando una referencia (un `ref`). React ignora el input hasta el momento exacto en que el usuario hace clic en "Enviar". ¡El rendimiento es perfecto, con cero re-renders innecesarios!

---

## 3. Validación en el Cliente con Zod (Single Source of Truth)

¿Recuerdas que en el Día 10 creamos un esquema de Zod en el backend para validar que nadie enviara basura a nuestra base de datos? ¡Vamos a reciclar ese mismo código en el Frontend!

Esto se llama **Single Source of Truth (Única Fuente de Verdad)**. Si mañana decides que las contraseñas ahora deben tener 10 caracteres en lugar de 8, cambias el esquema de Zod en un solo archivo, y automáticamente tu Frontend y tu Backend se actualizan al mismo tiempo.

**Integrando React Hook Form + Zod:**

Necesitamos instalar un "resolver", que es el puente entre nuestro formulario y Zod: `npm install @hookform/resolvers zod`
```Typescript

"use client";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { createUserSchema } from "@/src/schemas/userSchema"; // El mismo del Día 10
import { z } from "zod";

// Extraemos el tipo de TypeScript automáticamente desde nuestro esquema de Zod
type FormValues = z.infer<typeof createUserSchema>;

export default function FormularioRegistro() {
  const {
    register,      // Para conectar los inputs
    handleSubmit,  // Para manejar el envío
    formState: { errors, isSubmitting }, // Para el manejo de errores visuales y estado de carga
  } = useForm<FormValues>({
    resolver: zodResolver(createUserSchema), // Conectamos Zod a React Hook Form
  });

  const onSubmit = async (data: FormValues) => {
    // Esta función SOLO se ejecuta si Zod confirma que todos los datos son válidos
    console.log("Datos listos para enviar al backend:", data);
    // (En el Día 15 haremos el fetch real al backend)
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4 max-w-md">
      
      {/* Input de Nombre */}
      <div>
        <label>Nombre</label>
        {/* register("name") conecta este input a RHF sin causar re-renders */}
        <input {...register("name")} className="border p-2 rounded w-full" />
        
        {/* 4. Manejo de Errores de Formularios (UX) */}
        {errors.name && (
          <span className="text-red-500 text-sm mt-1">{errors.name.message}</span>
        )}
      </div>

      {/* Input de Email */}
      <div>
        <label>Email</label>
        <input {...register("email")} type="email" className="border p-2 rounded w-full" />
        {errors.email && (
          <span className="text-red-500 text-sm mt-1">{errors.email.message}</span>
        )}
      </div>

      {/* Botón de Envío Protegido */}
      <button 
        type="submit" 
        disabled={isSubmitting} // Bloquea el botón para evitar doble envío
        className="bg-blue-600 text-white p-2 rounded disabled:opacity-50"
      >
        {isSubmitting ? "Registrando..." : "Registrarse"}
      </button>

    </form>
  );
}
```

---
## 4. Manejo de Errores y Experiencia de Usuario (UX)

Observa la línea `disabled={isSubmitting}` en el botón de arriba. Este es un detalle crítico de UX (User Experience).

**El Vacío Teórico:** Si un usuario hace clic en "Registrarse", y el servidor tarda 2 segundos en responder, el usuario pensará que el botón no funcionó y hará clic 5 veces más. Esto enviará 5 peticiones a tu base de datos (lo que podría crear registros duplicados o errores de servidor).

React Hook Form nos provee el estado `isSubmitting` de forma nativa. Mientras la función `onSubmit` esté corriendo (porque es asíncrona y tiene un `await`), `isSubmitting` será verdadero. Bloquear el botón y mostrar un texto de "Cargando..." o un _spinner_ es la marca de una aplicación profesional.

---
### Resumen del Día 13

- Entendimos la diferencia entre Estado Local y Global, y cómo **Zustand** resuelve el problema del _Prop Drilling_ de manera elegante y sin impactar el rendimiento.
- Descubrimos por qué los formularios nativos de React son lentos y adoptamos los "Componentes No Controlados" a través de **React Hook Form**.
- Aplicamos el principio de la "Única Fuente de Verdad" reutilizando nuestros esquemas de **Zod** del backend para validar datos instantáneamente en el navegador del usuario.
- Implementamos un manejo de errores en tiempo real y mejoramos la UX bloqueando envíos duplicados.
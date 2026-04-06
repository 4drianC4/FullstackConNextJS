# Día 15: Frontend V - Integración (Mutaciones y Flujos)

## 1. Mutaciones: Enviando Datos al Servidor

En el Día 14 usamos `useQuery` de TanStack Query para "preguntar" por los datos. Pero cuando enviamos un formulario, no estamos haciendo una pregunta; estamos dando una **orden** de que algo cambie. Para esto, usamos `useMutation`.

### ¿Por qué no usar fetch puro?

Si usas un `fetch("api/users", { method: "POST" })` puro dentro del `onSubmit` de tu formulario, tendrás un problema: **la caché de tu aplicación quedará desactualizada**. Acabas de crear un usuario nuevo, pero tu lista de usuarios (que cargaste con `useQuery`) no sabe que ese usuario existe hasta que recargues la página.

`useMutation` resuelve esto obligando a la caché a actualizarse (invalidando consultas viejas) en cuanto la operación termina.

### Implementación Práctica:

Vamos a conectar el formulario que hicimos en el Día 13 con nuestro backend.
```Typescript

"use client";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";

export default function CrearPostForm() {
  const queryClient = useQueryClient(); // Nuestro gestor de caché global

  // 1. Definimos la Mutación
  const mutation = useMutation({
    mutationFn: async (nuevoPost: { titulo: string; contenido: string }) => {
      const res = await fetch("/api/posts", {
        method: "POST",
        body: JSON.stringify(nuevoPost),
      });
      if (!res.ok) throw new Error("Falló la creación del post");
      return res.json();
    },
    // 2. Si todo sale bien, le decimos a TanStack Query: "¡La lista de posts cambió!"
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["posts"] });
      // Al invalidar, TanStack Query vuelve a hacer el fetch automáticamente
      // y la lista en pantalla se actualiza sola.
    },
  });

  const { register, handleSubmit } = useForm();

  const onSubmit = (data: any) => {
    mutation.mutate(data); // Disparamos la mutación
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("titulo")} placeholder="Título" />
      <textarea {...register("contenido")} placeholder="Contenido" />
      <button disabled={mutation.isPending}>
        {mutation.isPending ? "Guardando..." : "Crear Post"}
      </button>
      {mutation.isError && <p className="text-red-500">Hubo un error.</p>}
    </form>
  );
}
```

---
## 2. Optimistic Updates (El Secreto de la Mejor UX)

### El Vacío Teórico: La Latencia de Red

Imagina que estás en Twitter/X y le das "Me gusta" a un post.

- **Enfoque Pesimista (Común):** Haces clic -> Sale un spinner de carga -> Esperas 1 segundo a que el servidor de USA responda -> El corazón se pone rojo. Esa espera de 1 segundo hace que la app se sienta lenta y torpe.
    
- **Enfoque Optimista (Profesional):** Haces clic -> **El corazón se pone rojo INSTANTÁNEAMENTE en tu pantalla** -> El Frontend envía la petición al servidor en secreto.
    

¿Qué pasa si el servidor da error (ej. se cayó el internet)? El Frontend se da cuenta, quita el color rojo del corazón y te muestra un mensajito: "Error al dar Me gusta". **Asumimos el éxito por adelantado para que la app se sienta instantánea.**

### Cómo implementarlo en TanStack Query:

Se logra manipulando la caché manualmente antes de que el servidor responda.
```Typescript

const mutation = useMutation({
  mutationFn: darMeGustaAPI,
  // Se ejecuta en el instante en que haces clic, antes de que el fetch termine
  onMutate: async (postAActualizar) => {
    // 1. Cancelamos cualquier fetch en curso para que no sobreescriba nuestra acción
    await queryClient.cancelQueries({ queryKey: ['posts'] });

    // 2. Guardamos el estado anterior por si tenemos que deshacer los cambios (rollback)
    const estadoAnterior = queryClient.getQueryData(['posts']);

    // 3. Modificamos la caché a la fuerza (esto es lo que pinta el corazón rojo)
    queryClient.setQueryData(['posts'], (viejosPosts: any) => {
      return viejosPosts.map((post: any) => 
        post.id === postAActualizar.id ? { ...post, likes: post.likes + 1 } : post
      );
    });

    return { estadoAnterior };
  },
  // Si falla el servidor, restauramos el estado guardado
  onError: (err, variables, contexto) => {
    queryClient.setQueryData(['posts'], contexto?.estadoAnterior);
  },
  // Al final, haya éxito o error, pedimos los datos reales de nuevo para estar seguros
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] });
  },
});
```

---
## 3. Rutas Protegidas en el Frontend

En el Día 10, usamos un `middleware.ts` para que nadie sin iniciar sesión pudiera golpear nuestros endpoints del backend. Sin embargo, ¿qué pasa si un usuario no logueado escribe `misitio.com/dashboard` en el navegador?

El middleware del backend lo botará si intenta pedir datos, pero **el usuario aún verá la UI (el esqueleto del dashboard)** vacía. Esto es un fallo de diseño. Debemos proteger las rutas visuales.

### Protección en Server Components (La forma más segura)

Como los Server Components se ejecutan en el servidor, podemos verificar la sesión de **NextAuth** antes de siquiera enviarle un solo píxel de HTML al usuario. Si no hay sesión, ni siquiera construimos la página.
```Typescript

// app/dashboard/page.tsx
import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";
import { authOptions } from "@/app/api/auth/[...nextauth]/route"; // Configuración del Día 9

export default async function DashboardPage() {
  // 1. Revisamos la cookie del servidor
  const session = await getServerSession(authOptions);

  // 2. Si no hay sesión, forzamos la salida ANTES de renderizar
  if (!session) {
    redirect("/login");
  }

  // 3. Si llega aquí, el usuario es 100% legítimo
  return (
    <div>
      <h1>Bienvenido al Dashboard, {session.user.name}</h1>
    </div>
  );
}
```

**Ventaja gigante:** El usuario nunca verá un "parpadeo" del dashboard antes de ser pateado al login. Es seguro y profesional.

---
## 4. Redirecciones y Flujos de Navegación

A menudo, las mutaciones vienen acompañadas de un cambio de página. Si te registras con éxito, quieres ir al Home; si borras tu cuenta, quieres ser enviado a la pantalla de despedida.

En Next.js tenemos dos formas de hacer esto dependiendo de dónde estemos:

### A. Desde el Servidor (`redirect`)

Como vimos en el ejemplo de arriba, usamos `import { redirect } from "next/navigation"` dentro de funciones asíncronas de servidor (Server Components o Server Actions). Es una redirección a nivel de protocolo HTTP (Código 307 o 308).

### B. Desde el Cliente (`useRouter`)

Si estás en un Client Component (por ejemplo, dentro del `onSuccess` de una mutación en TanStack Query), usamos el hook `useRouter`.
```Typescript

"use client";
import { useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";

export default function BotonEliminarCuenta() {
  const router = useRouter();

  const mutation = useMutation({
    mutationFn: eliminarCuentaAPI,
    onSuccess: () => {
      alert("Cuenta eliminada correctamente");
      // Cambiamos la URL visualmente usando JavaScript
      router.push("/goodbye");
    }
  });

  return <button onClick={() => mutation.mutate()}>Eliminar Mi Cuenta</button>;
}
```

---
### Resumen del Día 15

¡El círculo se ha completado!
- Aprendimos a hacer **Mutaciones** con TanStack Query, asegurando que cuando enviamos datos, nuestra interfaz "se entera" y refresca lo que haga falta.
- Elevamos drásticamente la UX implementando **Optimistic Updates**, engañando al ojo humano para que la app se sienta instantánea aunque dependa de una base de datos lejana.
- Aseguramos nuestras Vistas con **Rutas Protegidas** en el servidor, combinando NextAuth y redirecciones forzadas.
- Entendimos la diferencia entre mover al usuario desde el servidor (`redirect`) y desde el cliente (`useRouter`).
# Día 14: Frontend IV - Integración (Lectura de Datos)

## 1. El Dilema: ¿Dónde pedir los datos? (Server vs. Client Fetching)

En Next.js App Router, tenemos dos estrategias principales para obtener información. Entender la diferencia es la clave para una aplicación de alto rendimiento.

### A. Fetching en Server Components (La opción recomendada)

Como vimos en el Día 11, los Server Components pueden hablar directamente con la base de datos o con tu API sin pasar por el navegador.

- **Cómo se hace:** Simplemente defines tu componente como `async` y usas `await fetch()` o incluso llamadas directas a **Prisma**.
    
- **Vacío Teórico:** Al hacer el fetch en el servidor, el usuario recibe el HTML ya con los datos. Esto es excelente para el SEO y elimina los "parpadeos" de carga. Además, las credenciales (como tokens de API) nunca viajan al navegador, lo que es mucho más seguro.
    

### B. Fetching en Client Components (TanStack Query)

A veces necesitas interactividad: buscadores en tiempo real, filtros dinámicos o datos que se actualizan cada 30 segundos sin recargar la página. Aquí es donde entra **TanStack Query** (antes conocido como React Query).

**¿Por qué no usar un simple `useEffect`?** Hacer un `fetch` dentro de un `useEffect` tiene muchos problemas:

1. **No hay Caché:** Si el usuario sale de la página y vuelve, tiene que esperar a que los datos se carguen de nuevo.
    
2. **"Race Conditions":** Si el usuario hace clic rápido en varios filtros, las respuestas de red pueden llegar en desorden y mostrar datos incorrectos.
    
3. **Manejo de estados manual:** Tienes que crear manualmente estados para `loading`, `error` y `data` cada vez.

---

## 2. TanStack Query: El Gestor de "Estado de Servidor"

TanStack Query no es solo para pedir datos, es una herramienta de **gestión de caché**. Su trabajo es recordar lo que el servidor respondió para no volver a preguntarle innecesariamente.

**Ejemplo de implementación en un componente de lista de usuarios:**
```Typescript

"use client";
import { useQuery } from "@tanstack/react-query";

// 1. Definimos la función que hace el fetch puro
const fetchUsers = async () => {
  const response = await fetch("/api/users");
  if (!response.ok) throw new Error("Error al obtener usuarios");
  return response.json();
};

export default function ListaUsuarios() {
  // 2. Usamos el Hook de TanStack Query
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ["users"], // Identificador único para el caché
    queryFunc: fetchUsers,
    staleTime: 1000 * 60 * 5, // Los datos se consideran "frescos" por 5 minutos
  });

  if (isLoading) return <p>Cargando...</p>;
  if (isError) return <p>Error: {error.message}</p>;

  return (
    <ul>
      {data.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

---
## 3. Estados de Carga: Loaders y Skeletons

El "Vacío Teórico" de la experiencia de usuario (UX) es el **Layout Shift** (salto de diseño). Ocurre cuando una página está vacía y, de repente, aparecen los datos y "empujan" todo el contenido hacia abajo. Esto es molesto y se siente poco profesional.

### A. Archivo `loading.tsx` (Estrategia de Next.js)

Next.js nos permite crear un archivo especial llamado `loading.tsx` en cualquier carpeta de ruta. Next.js lo mostrará automáticamente mientras el Server Component termina de obtener los datos.

### B. Skeletons (Shadcn/ui)

Para una experiencia más "premium", usamos **Skeletons**. Son siluetas grises que imitan la forma de los datos que van a llegar.

**Ejemplo de un Skeleton para una tarjeta de usuario:**
```Typescript

import { Skeleton } from "@/components/ui/skeleton"

export function UserSkeleton() {
  return (
    <div className="flex items-center space-x-4 p-4 border rounded-lg">
      <Skeleton className="h-12 w-12 rounded-full" /> {/* Silueta de la foto */}
      <div className="space-y-2">
        <Skeleton className="h-4 w-[250px]" /> {/* Silueta del nombre */}
        <Skeleton className="h-4 w-[200px]" /> {/* Silueta del email */}
      </div>
    </div>
  )
}
```

## 4. Caché y Revalidación

Cuando pedimos datos, Next.js y TanStack Query los guardan en una "mochila" (Caché). Pero, **¿cómo sabe la app que los datos en la base de datos cambiaron?**

### Revalidación en el Servidor

En Next.js, puedes configurar cuánto tiempo debe durar el caché de una petición:
```Typescript

// Forzar a que esta petición se actualice cada 1 hora (3600 seg)
const res = await fetch('https://api.ejemplo.com/data', { next: { revalidate: 3600 } });
```
### Revalidación On-Demand (Bajo demanda)

Esto es lo más potente. Imagina que un usuario crea un post nuevo. No quieres esperar 1 hora para que aparezca en la lista. Usamos `revalidatePath` en nuestras **Server Actions** (lo veremos a fondo mañana):
```Typescript

// Esto le dice a Next.js: "Borra el caché de la página de inicio porque hay datos nuevos"
revalidatePath('/');
```

---
## 5. Manejo de Errores (Error Boundaries)

¿Qué pasa si la base de datos se cae o la API falla? No queremos que toda la aplicación se rompa y muestre una pantalla blanca.

Next.js usa archivos `error.tsx`. Si algo falla dentro de una carpeta de ruta, Next.js "atrapa" el error y muestra este archivo en su lugar, permitiendo que el resto de la aplicación (como el menú de navegación) siga funcionando.
```Typescript

"use client"; // Los archivos de error deben ser Client Components

export default function ErrorPage({ error, reset }: { error: Error, reset: () => void }) {
  return (
    <div className="p-10 text-center">
      <h2 className="text-2xl font-bold">¡Vaya! Algo salió mal.</h2>
      <p className="text-red-500">{error.message}</p>
      <button 
        onClick={() => reset()} // Intenta cargar la página de nuevo
        className="mt-4 bg-blue-500 text-white p-2 rounded"
      >
        Reintentar
      </button>
    </div>
  );
}
```

---
### Resumen del Día 14

- Aprendimos que los **Server Components** son la forma más rápida y segura de obtener datos iniciales.
- Introdujimos **TanStack Query** para manejar el "Estado del Servidor" en el cliente, dándonos caché y sincronización automática.
- Mejoramos la UX usando **Skeletons** para evitar saltos bruscos en la interfaz.
- Entendimos que el **Caché** es vital para la velocidad, pero que necesitamos estrategias de **Revalidación** para mantener los datos frescos.
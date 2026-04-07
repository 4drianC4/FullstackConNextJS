# Día 11: Frontend I - Arquitectura UI
## 1. El Cambio de Paradigma: Server Components vs Client Components

En el React tradicional (como el que hacíamos con Create React App o Vite), **todo** el código de tus componentes se empaquetaba en un archivo JavaScript gigante y se enviaba al navegador del usuario. El navegador descargaba ese JS, lo ejecutaba, y recién ahí "dibujaba" (renderizaba) el HTML en la pantalla. Esto se llama **Client-Side Rendering (CSR)**.

¿El problema? Si el usuario tiene un celular lento o mala conexión, vería una pantalla en blanco por varios segundos. Además, los motores de búsqueda (Google) a veces no podían leer el contenido, afectando el SEO.

Next.js App Router soluciona esto dividiendo los componentes en dos mundos:
### A. React Server Components (RSC)

Son la **nueva opción por defecto** en Next.js. Estos componentes se ejecutan **exclusivamente en el servidor**.

- **¿Qué envían al navegador?** Solo HTML estático puro y CSS. Cero JavaScript.
    
- **Ventajas:** Cargan rapidísimo, reducen el tamaño de la aplicación, y te permiten hacer cosas como conectarte a Prisma directamente en el componente sin necesidad de usar un `useEffect` o una API intermedia.
    
- **La Regla de Oro:** Como viven en el servidor, **NO** tienen interactividad. No puedes usar `onClick`, `useState`, `useEffect`, ni acceder a cosas del navegador como `window` o `localStorage`.
### B. Client Components

Son los componentes de React "de toda la vida". Para decirle a Next.js que un componente debe ser interactivo y enviarse al navegador, debemos colocar la directiva `"use client"` en la primera línea del archivo.

- **Cuándo usarlos:** Cuando necesitas botones, formularios interactivos, animaciones complejas, estados (`useState`), o ciclos de vida (`useEffect`).
    
- **Buenas Prácticas:** Mantén los Client Components lo más pequeños posible (al final del árbol de componentes) ("hojas" del árbol) para no enviar JS innecesario al cliente.

### Ejemplo:
```Typescript

// Esto fallaría en un Server Component (por defecto)
const MiBoton = () => {
  const [contador, setContador] = useState(0); // Error: useState no existe en el servidor
  return <button onClick={() => setContador(contador + 1)}>{contador}</button>
}

// La forma correcta: Convertirlo en Client Component
"use client";
import { useState } from 'react';

export const MiBoton = () => {
  const [contador, setContador] = useState(0);
  return <button onClick={() => setContador(contador + 1)}>{contador}</button>
}
```

---
## 2. App Router y File-based Routing

Olvídate de librerías como `react-router-dom`. En Next.js, **el sistema de carpetas es tu enrutador**. La carpeta `app/` es el corazón de tu frontend.

### Las Reglas del Enrutamiento

1. **Las Carpetas definen la ruta (URL):** Si creas una carpeta llamada `dashboard`, estás definiendo la ruta `midominio.com/dashboard`.
    
2. **El archivo `page.tsx` hace que la ruta sea pública:** Puedes tener mil carpetas (ej. `app/components/ui`), pero si no hay un archivo llamado exactamente `page.tsx` dentro, esa ruta no existe en el navegador.
    

### Rutas Dinámicas

Si queremos ver el perfil de un usuario específico, no podemos crear una carpeta para cada usuario. Usamos **corchetes `[]`** para indicar un parámetro dinámico (igual que hicimos en el backend).

- Estructura: `app/users/[id]/page.tsx`
    
- URL resultante: `midominio.com/users/123`
    
- Next.js le pasará el valor `123` a tu componente `page.tsx` a través de las `props`.

---

## 3. Layouts Compartidos y Anidados

Un problema clásico del desarrollo web es la repetición de código. Si tienes un menú de navegación lateral (Sidebar) y un menú superior (Navbar), no quieres copiar y pegar ese código en cada una de tus 50 páginas.

Para eso existen los **Layouts (`layout.tsx`)**. Un Layout es una interfaz de usuario que se comparte entre múltiples páginas. Al navegar entre esas páginas, el Layout preserva su estado, sigue siendo interactivo y **no se vuelve a renderizar** (no hay parpadeos molestos).

### A. El Root Layout (`app/layout.tsx`)

Es el diseño principal y obligatorio. Contiene las etiquetas `<html>` y `<body>`. Todo lo que pongas aquí se verá en toda tu aplicación.
```Typescript

// app/layout.tsx
import Navbar from '@/components/Navbar'; // Supongamos que lo creamos

export default function RootLayout({
  children, // 'children' es la página actual que el usuario está visitando
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body>
        <Navbar />          {/* Se verá en todas las páginas */}
        <main>
          {children}        {/* Aquí se inyecta el page.tsx correspondiente */}
        </main>
        <footer>Pie de página global</footer>
      </body>
    </html>
  )
}
```
### B. Layouts Anidados

Puedes poner un `layout.tsx` dentro de cualquier carpeta. Por ejemplo, si pones un `layout.tsx` dentro de `app/dashboard/`, ese diseño específico (digamos, una barra lateral de configuración) solo aplicará a la ruta `/dashboard` y todas sus subrutinas (ej. `/dashboard/settings`, `/dashboard/analytics`), envolviéndose dentro del Root Layout.

---

## 4. Navegación: El Componente `<Link>`

En HTML tradicional, para ir de una página a otra usamos la etiqueta de ancla: `<a href="/about">Sobre Nosotros</a>`.

**¡NUNCA uses la etiqueta `<a>` clásica para navegación interna en Next.js!**

### El Problema de la etiqueta `<a>`
four brothers 
Si usas `<a>`, el navegador hace un **Hard Reload**. Es decir, destruye todo el estado de tu aplicación en memoria, vuelve a pedir el HTML al servidor, vuelve a cargar los archivos CSS y JS. Es lento y arruina la experiencia de usuario (UX).

### La Solución: El componente `<Link>` de Next.js

Next.js nos provee un componente especial que sobrescribe este comportamiento para darnos una experiencia de **Single Page Application (SPA)**.
```Typescript

import Link from 'next/link';

export default function MiNavegacion() {
  return (
    <nav>
      {/* ❌ Forma incorrecta */}
      <a href="/dashboard">Dashboard Lento</a> 

      {/* ✅ Forma correcta */}
      <Link href="/dashboard">
        Dashboard Ultra Rápido
      </Link>
    </nav>
  )
}
```

**¿Por qué `<Link>` es "mágico"?**

1. **Client-side Navigation:** Cambia la URL y el componente en la pantalla usando JavaScript, sin recargar el navegador. Tu estado global (ej. la música que está sonando de fondo o el carrito de compras) no se pierde.
    
2. **Pre-fetching (Precarga):** Cuando el componente `<Link>` entra en el campo visual de la pantalla del usuario (hace scroll y el enlace aparece), Next.js secretamente descarga el código de esa página de fondo. Cuando el usuario hace clic, la página aparece instantáneamente porque ya estaba descargada.

---
### Resumen del Día 11

Hoy hemos establecido las fundaciones visuales de nuestra app:

- Entendimos la separación entre **Server Components** (estáticos, rápidos, seguros) y **Client Components** (interactivos, "use client").
    
- Vimos cómo organizar nuestras carpetas usando el **App Router** (`app/ruta/page.tsx`).
    
- Aprendimos a estructurar nuestra UI sin duplicar código gracias a los **Layouts**.
    
- Optimizamos la navegación interna utilizando el componente **`<Link>`** para transiciones instantáneas.
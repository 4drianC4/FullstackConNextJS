# Día 12: Frontend II - Sistema de Diseño y UI

## 1. El Paradigma de Tailwind CSS (Utility-First)

Durante años, la forma estándar de dar estilos a una web era usar CSS tradicional o preprocesadores como SASS. Creabas una clase (ej. `.boton-primario`), ibas a tu archivo `.css`, y escribías las reglas.

**El Problema del CSS Tradicional:**

1. **Nombres de clases:** Perder tiempo pensando si llamarlo `.tarjeta-perfil`, `.perfil-card` o `.wrapper-usuario`.
    
2. **Context Switching:** Saltar constantemente entre tu archivo HTML/JSX y tu archivo CSS rompe la concentración.
    
3. **Código muerto (Dead Code):** A medida que el proyecto crece, el archivo CSS se vuelve gigante y nadie se atreve a borrar clases por miedo a romper algo en otra página.
    

### La Solución: Clases de Utilidad (Utility-First)

Tailwind CSS cambia las reglas del juego. En lugar de crear clases semánticas, Tailwind te da miles de "clases de utilidad" pequeñitas, donde cada clase hace **una sola cosa**.

- `bg-blue-500` = `background-color: #3b82f6;`
    
- `text-center` = `text-align: center;`
    
- `p-4` = `padding: 1rem;`
    
- `rounded-lg` = `border-radius: 0.5rem;`

**Ejemplo Práctico:**
```Typescript

// Enfoque Antiguo (requiere un archivo .css separado)
<div className="tarjeta-usuario">
  <h2>Juan Perez</h2>
</div>
// Enfoque Tailwind (todo en el mismo archivo)
<div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
  <h2 className="text-xl font-bold text-gray-800">Juan Perez</h2>
</div>
```

**"¡Pero el HTML queda horrible y lleno de clases!":** Esta es la queja número uno de los principiantes. La respuesta es: **En React/Next.js, tu componente es la plantilla.** No necesitas un HTML "limpio" porque ya estás encapsulando esa lógica en un componente reutilizable llamado `<TarjetaUsuario />`. Si necesitas cambiar el color, lo cambias en un solo lugar. Además, Tailwind purga (elimina) automáticamente en producción todas las clases que no usaste, resultando en un archivo CSS minúsculo.

---
## 2. Componentes UI Reutilizables (shadcn/ui)

Tailwind es genial, pero hacer un menú desplegable (Dropdown) accesible, con navegación por teclado y animaciones desde cero, toma horas.

Históricamente, usaríamos librerías como Material UI o Bootstrap. El problema de estas librerías es que son rígidas: si quieres cambiar un comportamiento interno, terminas peleando contra la librería y escribiendo CSS para sobrescribir su diseño original.

### ¿Qué es shadcn/ui y por qué está dominando el mercado?

**shadcn/ui NO es una librería de componentes** que instalas a través de `npm` y se guarda en `node_modules`. Es una **colección de componentes diseñados con Tailwind CSS y Radix UI (Headless UI)** que tú copias y pegas en tu proyecto.

- **Headless UI:** Significa que Radix UI maneja toda la lógica compleja (accesibilidad, focus, abrir/cerrar con la tecla Escape) pero **no tiene estilos**.
    
- **Propiedad Total:** Cuando ejecutas el comando para añadir un botón de shadcn, el código se descarga directamente en tu carpeta `components/ui/button.tsx`. ¡Tú eres dueño del código! Si quieres que todos los botones de tu app tengan bordes más redondeados, simplemente editas _tu_ archivo `button.tsx`.
    

### Inicialización en Next.js

Para inicializarlo en la terminal ejecutamos:
```Bash

npx shadcn@latest init
```

Y luego, si necesitamos un botón y un formulario:
```Bash

npx shadcn@latest add button input form
```

---

## 3. Responsive Design (Diseño Adaptable)

Tu aplicación debe verse bien en un iPhone y en un monitor de 32 pulgadas. Tailwind usa el principio de **"Mobile First" (Móvil Primero)**.

**El Vacío Teórico - Mobile First:** Significa que cualquier clase que escribas en Tailwind sin prefijo, se aplicará **primero a pantallas pequeñas (móviles)**. Luego, usas "prefijos de ruptura" (breakpoints) para sobrescribir ese estilo cuando la pantalla se hace más grande.

- `sm:` (Tablets pequeñas, > 640px)  
- `md:` (Tablets grandes/Laptops, > 768px)
- `lg:` (Monitores, > 1024px)
- `xl:` (Monitores grandes, > 1280px)

**Ejemplo Práctico de Responsive:**
```Typescript

export default function GrillaResponsiva() {
  return (
    // 1. Por defecto (móvil): text-sm y 1 columna (flex-col)
    // 2. En md (laptops): text-base y 2 columnas (grid-cols-2)
    // 3. En lg (monitores): text-lg y 4 columnas (grid-cols-4)
    <div className="flex flex-col md:grid md:grid-cols-2 lg:grid-cols-4 gap-4 text-sm md:text-base lg:text-lg">
      <div className="bg-red-500 p-4">Caja 1</div>
      <div className="bg-blue-500 p-4">Caja 2</div>
      <div className="bg-green-500 p-4">Caja 3</div>
      <div className="bg-yellow-500 p-4">Caja 4</div>
    </div>
  )
}
```

---
## 4. Temas y Modo Oscuro (Dark Mode)

Hoy en día, el modo oscuro no es un lujo, es una obligación. Implementarlo solía ser un dolor de cabeza, pero con Tailwind y Next.js es casi automático.

### A. La clase `dark:` en Tailwind

Tailwind tiene un modificador especial llamado `dark:`. Funciona exactamente igual que los modificadores responsivos (`md:`), pero se activa solo cuando el modo oscuro está encendido.
```Typescript

<div className="bg-white text-black dark:bg-gray-900 dark:text-white p-6 rounded">
  <h1>Este texto cambia de color según el tema</h1>
</div>
```
### B. El Problema del Parpadeo (FOUC) y `next-themes`

Si guardas la preferencia de modo oscuro en el `localStorage`, el usuario notará un "parpadeo blanco" al recargar la página. Esto ocurre porque el HTML llega del servidor en modo claro, y milisegundos después, el JavaScript del cliente lee el `localStorage` y lo cambia a oscuro.
Para evitar esto en Next.js App Router, usamos un paquete llamado `next-themes`. Este paquete inyecta un pequeño script que bloquea el renderizado de la página hasta que sabe qué tema prefirió el usuario, evitando el parpadeo.

**Implementación en el Root Layout (`app/layout.tsx`):**
```Typescript

import { ThemeProvider } from "@/components/theme-provider"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    // suppressHydrationWarning es necesario en Next.js cuando alteramos el <html> 
    // dinámicamente para que React no se queje de diferencias entre Servidor y Cliente.
    <html lang="es" suppressHydrationWarning>
      <body>
        <ThemeProvider
          attribute="class"       // Le dice a Tailwind que use la clase 'dark' en el HTML
          defaultTheme="system"   // Lee la preferencia del sistema operativo (Windows/Mac)
          enableSystem
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
```

---
### Resumen del Día 12
- Dejamos atrás la lucha con archivos `.css` gigantes y adoptamos el desarrollo ultra-rápido de **Tailwind CSS**.
- Entendimos que **shadcn/ui** nos da lo mejor de dos mundos: componentes profesionales, accesibles y hermosos, manteniendo nosotros el control absoluto del código fuente.
- Dominamos el enfoque **Mobile-First**, asegurando que nuestra app nazca pensada para celulares y escale a monitores grandes con prefijos como `md:` o `lg:`.
- Implementamos un **Modo Oscuro** perfecto y sin parpadeos utilizando `next-themes` y el modificador `dark:`.
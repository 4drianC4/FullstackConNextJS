---
tipo: clase
clase: 12
semana: 3
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/3
---

# Clase 12 — React II y rutas de Next.js

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 11|Clase 11]] · [[Semana3/CLASE 13|Clase 13]] →

> [!abstract] Objetivo
> Manejar interactividad y ubicar las pantallas en App Router sin mezclar código privado.

## Antes de empezar

Repasa [[Semana3/CLASE 11|Clase 11]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Estado y eventos

```tsx
"use client";
import { useState } from "react";
export function QuantityControl() {
  const [quantity, setQuantity] = useState(1);
  return (
    <div>
      <p>Cantidad: {quantity}</p>
      <button type="button" onClick={() => setQuantity((current) => current + 1)}>Añadir</button>
      <button type="button" disabled={quantity <= 1}
        onClick={() => setQuantity((current) => Math.max(1, current - 1))}>Quitar</button>
    </div>
  );
}
```

Usar actualizador funcional cuando el próximo valor depende del anterior. El estado vive en el ancestro común que lo necesita. No hace falta Zustand para un formulario o contador local.

### Rutas y layouts

`src/app/page.tsx` es `/`; `src/app/dashboard/events/page.tsx` es `/dashboard/events`. `layout.tsx` compone pantallas y `Link` navega entre ellas. Una ruta `[id]` recibe parámetros dinámicos; en Next.js 16 se esperan con `await` en componentes de servidor.

```tsx
// src/app/dashboard/layout.tsx
import type { ReactNode } from "react";
import Link from "next/link";
export default function DashboardLayout({ children }: { children: ReactNode }) {
  return <><nav aria-label="Principal"><Link href="/dashboard/events">Eventos</Link></nav><main>{children}</main></>;
}
```

### Servidor y cliente

Los componentes son de servidor por defecto. `"use client"` marca una frontera para interactividad y los módulos importados por ella. Un Client Component también puede participar en el HTML inicial del servidor: no significa que todo su trabajo ocurra exclusivamente en el navegador.

No importar Prisma ni servicios backend desde un componente cliente. Pasar datos serializables y contratos públicos. El servidor puede consultar un servicio directamente; no necesita llamar a su propia API por HTTP. En este curso las pantallas interactivas practicarán además el consumo de las rutas REST.

No añadir `useEffect` para calcular datos derivados. Lo utilizaremos cuando exista una sincronización externa concreta, como una petición en la clase 15.

## Práctica guiada

Crear el layout del panel y navegar hacia el listado del módulo. Añadir un control de cantidad.

## Tarea para casa

Construir las rutas de listado y creación de tu funcionalidad, todavía con datos de prueba.

## Criterios de finalización

- [ ] Puedes explicar dónde se ejecuta cada parte.
- [ ] Los componentes cliente no importan servicios backend.
- [ ] La navegación y el estado funcionan.

## Conexiones

[[Semana3/CLASE 11|Clase 11]] · [[Proyecto/4. Arquitectura vertical y contratos|Fronteras de la funcionalidad]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 11|Clase 11]] · [[Semana3/CLASE 13|Clase 13]] →

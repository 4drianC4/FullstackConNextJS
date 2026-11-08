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

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 11|Clase 11]] · [[Semana3/CLASE 13|Clase 13]] →

> [!abstract] Objetivo
> Manejar interactividad y ubicar las pantallas en App Router sin mezclar código privado.

## Antes de empezar

Repasa [[Semana3/CLASE 11|Clase 11]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Por qué una variable no basta para recordar una interacción

Un componente se ejecuta para calcular una representación. Una variable local creada dentro de la función se reinicia con cada ejecución y cambiarla no comunica a React que debe actualizar la interfaz. El estado conserva información entre renders de una instancia y proporciona una función para solicitar una actualización.

`useState` devuelve el valor del render actual y su setter. Llamar al setter programa otro render; no modifica la variable que ya estás leyendo en la función que está terminando. Por eso un log inmediatamente después de `setQuantity` puede mostrar el valor anterior sin que React esté roto.

### Actualizar a partir del valor previo

Cuando el próximo estado depende del anterior, la forma funcional `setQuantity(current => current + 1)` expresa la relación. Si se encadenan varias actualizaciones, React puede procesarlas con el valor pendiente correcto. Dos llamadas basadas en una misma captura de `quantity` podrían expresar dos veces el mismo valor.

El setter de objetos no fusiona automáticamente propiedades. Crea el siguiente objeto sin mutar el anterior. En listas, usa copias y transformaciones para que el cambio de referencia represente el estado nuevo. No almacenes a la vez cantidad, precio y total si el total se deriva de los dos primeros: son fuentes duplicadas que pueden desincronizarse.

### Reglas de hooks y propiedad del estado

Los hooks ordinarios como useState y useEffect se llaman al nivel superior del componente o de un hook propio. No se colocan detrás de un if o dentro de un bucle; React debe poder asociarlos de forma consistente entre renders.

Dos contadores renderizados son dos instancias con memoria propia. Si varias piezas deben mostrar la misma cantidad, eleva el estado al ancestro común y pasa valores y callbacks. Esto es suficiente para muchas pantallas del MVP sin introducir un almacén global.

### Apoyo visual: prop drilling y estado compartido

![[propDrilling.excalidraw]]

[[propDrilling.excalidraw|Abrir el dibujo de props y estado compartido]] · [[Recursos/Mapa de dibujos Excalidraw|Ver todos los dibujos]].

Observa los componentes e inputs y sigue por dónde viaja la información que escribe el usuario. Pasar props a través de varios niveles que solo las transportan se conoce como prop drilling. No es un error por sí mismo: en árboles pequeños puede ser una dependencia explícita y fácil de seguir.

El bloque `store.ts` representa una alternativa de estado compartido. No significa que cada input necesite un store ni que debamos introducir Zustand para completar el proyecto. Primero decide quién necesita el dato y sitúalo en el ancestro común. Un borrador de venta puede coordinarse desde su pantalla; la venta confirmada sigue teniendo su autoridad en el servidor.

Usa el dibujo para comparar las dos rutas y preguntar qué componentes leen, modifican o simplemente transmiten el valor. Cambiar dónde vive el estado no elimina la necesidad de contratos claros.

### Eventos y efectos cumplen funciones diferentes

Un evento responde a una interacción concreta. Un efecto sincroniza con algo externo después de renderizar, como una petición o una suscripción. No pongas una venta dentro de un efecto dependiente de una cantidad: cambiar el input podría registrar ventas sin confirmación explícita.

El render tampoco debe producir efectos de negocio. Calcula la vista; deja el envío a un handler. En la clase 15 veremos peticiones de lectura con cancelación y actualización explícita del listado.

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

### App Router: la carpeta como mapa de direcciones

`app` sigue convenciones de Next.js. `page.tsx` crea una pantalla; `layout.tsx` envuelve contenido compartido; `route.ts` atiende HTTP. Una carpeta `(grupo)` organiza sin añadir segmento visible; una carpeta `[id]` captura un segmento dinámico.

No confundas `/api/events` con `/dashboard/events`: la primera entrega datos según un contrato HTTP; la segunda representa una pantalla. Pueden compartir servicios del dominio desde el servidor, pero no son el mismo punto de entrada.

En una página dinámica de servidor, params es una promesa en la versión del curso:

```tsx
export default async function EventPage({
  params,
}: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <h1>Evento {id}</h1>;
}
```

Este ejemplo solo presenta el parámetro; todavía falta validar el UUID, autorizar y consultar el detalle. No supone que recibir un ID convierte a una pantalla en privada.

### Server Components y la frontera cliente

Los componentes de servidor pueden ejecutar lecturas privadas sin enviar el código de consulta al navegador. No tienen acceso a eventos del DOM ni al almacenamiento del navegador. Los componentes cliente necesitan JavaScript para interactividad y pueden manejar estado y handlers.

La directiva `"use client"` marca un punto de entrada para el conjunto de módulos cliente. No es una instrucción para ponerla en todos los archivos ni una promesa de que ese componente nunca participa en el HTML inicial del servidor. La carga inicial puede incluir HTML de presentación y después conectar interactividad en el navegador.

Esa conexión se llama hidratación. Si el servidor describe una pantalla y el cliente intenta hidratar otra distinta, aparecen advertencias y reconstrucciones. No uses valores aleatorios o lecturas de localStorage para producir una salida inicial incompatible sin gestionar esa diferencia.

### Props que cruzan la frontera

Al pasar datos desde servidor hacia cliente, utiliza contratos serializables y públicos. No pases una instancia Prisma, conexiones o funciones arbitrarias de servidor como si fueran props normales. Los callbacks locales entre componentes cliente sí son un patrón habitual.

Importar un esquema Zod puro o un tipo compartido no equivale a importar el servicio que usa la base. `server-only` ayuda a detectar una importación indebida, pero conviene entender la separación en vez de depender de que el build nos detenga.

### Navegación y reutilización

`Link` facilita navegación dentro de la aplicación. Los layouts pueden conservarse entre transiciones, por lo que no son un lugar suficiente para confiar toda la autorización. Cada lectura privada y endpoint sensible revisa permisos con la identidad vigente.

El estado local vive asociado a posiciones y claves de componentes. Cambiar de página, desmontar o alterar una key puede reiniciarlo. Si necesitas conservar un borrador, decide dónde vive y durante cuánto tiempo; no agregues persistencia de contraseñas como solución genérica.

La nota [[Recursos/Conceptos/Renderizado estado e hidratacion|Renderizado, estado e hidratación]] conecta estos términos con el recorrido de carga de una página.

### Caso desarrollado: dos incrementos producen solo uno

Dentro de un handler escribes dos veces `setQuantity(quantity + 1)`. Si quantity vale uno en ese render, ambas llamadas proponen el valor dos. No expresan necesariamente «incrementar dos veces»: repiten un siguiente valor calculado desde la misma captura.

La forma `setQuantity(current => current + 1)` describe una transformación del valor pendiente. Dos actualizaciones funcionales se aplican una tras otra y expresan el aumento acumulado. La diferencia es importante cuando varios eventos o actualizaciones se agrupan.

No intentes observar el valor nuevo leyendo inmediatamente la variable quantity del mismo handler. Esa variable pertenece al render que creó la función. Observa la pantalla del siguiente render o analiza el estado con herramientas y logs ubicados correctamente.

Ahora calcula un total con `quantity * priceCents` durante render. No necesitas otro estado total ni un efecto para sincronizarlo. Si almacenas ambos, tendrás que mantener una relación que ya puede obtenerse directamente y abrirás otra posibilidad de desajuste.

El total mostrado sigue siendo una estimación del borrador; el servidor confirma precios al registrar la venta. Este caso conecta dos niveles: React debe conservar una interacción consistente y el backend debe sostener la autoridad del dato confirmado.

## Práctica guiada

Crear el layout del panel y navegar hacia el listado del módulo. Añadir un control de cantidad.

## Tarea para casa

Construir las rutas de listado y creación de tu funcionalidad, todavía con datos de prueba.

## Criterios de finalización

- [ ] Puedes explicar dónde se ejecuta cada parte.
- [ ] Los componentes cliente no importan servicios backend.
- [ ] La navegación y el estado funcionan.

## Preguntas resueltas

**¿El setter cambia inmediatamente la variable actual?**

Solicita una actualización; el render que ya se está ejecutando conserva su snapshot.

**¿Use client implica no generar HTML inicial?**

No. Distingue la frontera de código cliente y sus capacidades; puede participar en la presentación inicial.

**¿Todo estado necesita Zustand?**

No. Empieza con estado local o elevado a un ancestro común y amplía cuando exista una necesidad concreta.

## Para profundizar

[React: estado](https://react.dev/learn/state-a-components-memory) · [Next.js: Server y Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components).

## Conceptos clave de esta clase

- **Hook:** Función de React que conecta un componente con capacidades como estado o efectos.
- **Snapshot:** Valores que un render concreto observa.
- **Hidratación:** Conexión de interactividad cliente al HTML inicial compatible.
- **Layout:** Componente que envuelve pantallas y organiza estructura compartida.
- **Segmento dinámico:** Parte de ruta capturada, como [id].
- **Estado derivado:** Valor que se puede calcular a partir de otros datos sin almacenarlo aparte.

## Conexiones

[[Semana3/CLASE 11|Clase 11]] · [[Proyecto/4. Arquitectura vertical y contratos|Fronteras de la funcionalidad]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 11|Clase 11]] · [[Semana3/CLASE 13|Clase 13]] →

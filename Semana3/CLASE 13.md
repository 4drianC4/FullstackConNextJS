---
tipo: clase
clase: 13
semana: 3
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/3
---

# Clase 13 — Interfaz, Tailwind y accesibilidad

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 12|Clase 12]] · [[Semana3/CLASE 14|Clase 14]] →

> [!abstract] Objetivo
> Construir una interfaz consistente y usable sin dedicar el curso a un sistema de diseño complejo.

## Antes de empezar

Repasa [[Semana3/CLASE 12|Clase 12]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Una interfaz coherente reduce decisiones innecesarias

El panel debe permitir trabajar, no obligar al personal a aprender un diseño distinto en cada módulo. Usa patrones comunes para títulos, formularios, acciones y errores. La consistencia facilita reconocer qué se puede pulsar y qué resultado esperar.

Un sistema de diseño pequeño puede ser una colección de colores, espaciados, tipografía y componentes acordados. No necesitamos una biblioteca enorme. Define qué se comparte y qué pertenece al dominio: un botón es transversal; una tarjeta que muestra aforo pertenece a eventos.

### Utilidades Tailwind y reglas CSS

Tailwind aplica estilos mediante clases de utilidad que expresan propiedades concretas. En `p-4`, `grid`, `gap-4` y `text-2xl`, cada clase tiene una función. No son etiquetas semánticas: todavía necesitas escoger elementos HTML apropiados y entender layout y tamaño.

En la línea 4 utilizamos configuración CSS-first. `@theme` define tokens usados por utilidades. Un token es un valor con nombre y significado, como color de marca. Cambiarlo permite alinear varias piezas sin buscar hexadecimales sueltos por toda la aplicación.

Evita construir clases dinámicas que el proceso de detección no pueda reconocer como cadenas completas. Para variantes, usa un mapa explícito de clases, por ejemplo estado abierto/cerrado. El hecho de que un string final parezca correcto en el inspector no garantiza que el CSS correspondiente se haya generado.

### Responsive como cambio de organización

El enfoque mobile-first empieza con una disposición válida en anchuras pequeñas y añade cambios a partir de breakpoints. `grid` con una columna y `md:grid-cols-2` no significa una versión para un dispositivo concreto: expresa una regla al superar un ancho configurado.

Prueba contenido real: nombres largos, filas sin imagen y mensajes de error. Una tabla que se sale del viewport o un botón que desaparece debajo de un teclado móvil son problemas funcionales. Responsive no se resuelve únicamente bajando el tamaño de letra.

### Componentes copiados, no una caja negra

shadcn/ui incorpora componentes al proyecto. Eso permite leerlos y adaptarlos, pero también implica que debes revisar sus cambios y conservar sus patrones de accesibilidad. No elimines labels, foco o atributos porque no afecten una captura de pantalla.

La ubicación acordada es shared/ui. La configuración generada debe apuntar allí para que los imports sean consistentes. No copies manualmente otro button.tsx a cada funcionalidad cuando ya hay un control común.

### Tailwind 4

Partimos del CSS generado por el template compatible. En Tailwind 4 la configuración base es CSS-first; no copiar el `tailwind.config.ts` de los apuntes antiguos como requisito universal.

```css
/* src/app/globals.css */
@import "tailwindcss";
@theme {
  --color-brand: #7c3aed;
}
```

Si se inicializa shadcn/ui, conservar además sus imports y tokens generados; este fragmento no reemplaza ese archivo completo.

```tsx
<section className="mx-auto max-w-5xl space-y-6 p-4 md:p-8">
  <h1 className="text-2xl font-bold">Eventos</h1>
  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{/* tarjetas */}</div>
</section>
```

### Componentes seleccionados

```bash
npx shadcn@latest init
npx shadcn@latest add button input label dialog
```

El CLI es una herramienta de preparación: registrar su versión y revisar el diff. Elegir `src/shared/ui` como destino de componentes UI en la configuración del proyecto y usar ese import en todos los ejemplos. Los componentes copiados pertenecen al proyecto: leerlos antes de modificarlos.

### Accesibilidad práctica

Usar `button` para acciones y `Link` para navegación; labels vinculados a inputs; encabezados ordenados; foco visible; contraste legible; diálogos con nombre accesible y devolución del foco. Prueba teclado, zoom y pantalla estrecha, además de la vista de escritorio.

La identidad visual usa fondo oscuro, superficies diferenciadas y acento violeta. El estado no se comunica solamente por color: acompañar con texto. Modo oscuro alternable y animaciones complejas quedan como ampliación.

### Semántica antes que apariencia

Un botón ejecuta una acción; un enlace navega. Un div con onClick puede parecer botón con CSS, pero necesita resolver teclado, foco y significado accesible. Usar el elemento correcto evita recrear comportamientos ya proporcionados por el navegador.

Los encabezados describen jerarquía; un h1 presenta la pantalla y los niveles posteriores organizan secciones. No elijas h4 solo porque su tamaño se ve adecuado. Una navegación tiene un nombre accesible si hay varias zonas similares.

### Formulario legible para personas y herramientas

Cada input debe tener un label asociado mediante htmlFor e id. Un placeholder no lo sustituye: desaparece al escribir y no siempre se comunica del mismo modo. Los errores deben relacionarse con su campo mediante aria-describedby y señalar invalidez cuando corresponda.

```tsx
<div className="space-y-2">
  <label htmlFor="drink-name">Nombre de la bebida</label>
  <input id="drink-name" name="name" aria-describedby="drink-name-help"
    className="w-full rounded-md border p-2 focus-visible:outline-2" />
  <p id="drink-name-help">Usa un nombre que el personal pueda reconocer.</p>
</div>
```

El ejemplo muestra estructura, no valida datos ni autoriza cambios. CSS y accesibilidad no reemplazan reglas del backend, pero hacen posible completar el recorrido de manera comprensible.

### Foco, teclado y diálogos

Recorre la pantalla con Tab y Shift+Tab. El foco debe ser visible y seguir un orden razonable. Comprueba que Enter y Espacio actúan como se espera en controles nativos. No desactives outlines sin una alternativa visible.

Al abrir un diálogo, el foco entra en su contenido y al cerrarlo debe regresar a una ubicación útil. Una confirmación de borrado tiene título, descripción y acciones claras. «Aceptar» puede ser ambiguo; «Eliminar reserva» comunica la consecuencia.

No construyas un diálogo casero únicamente con una caja encima del contenido si no vas a resolver foco, teclado y semántica. Aprovecha el componente acordado y comprende qué comportamiento proporciona.

### Color y estados

La disponibilidad de una bebida no se debe expresar solo con verde o rojo. Acompaña con texto. Un error importante no debe depender de distinguir dos tonos muy próximos. Mantén contraste adecuado entre texto y fondo y verifica el aspecto en distintas pantallas.

Usa feedback según el estado: cargando, vacío, éxito, error de validación o conflicto. Un toast puede confirmar una acción breve, pero un error de campo debe permanecer junto al control y no desaparecer antes de que alguien termine de leerlo.

### Una revisión concreta de la pantalla

Comprueba cuatro dimensiones: estructura con encabezados/labels, operación por teclado, anchura estrecha y estados con datos difíciles. Prueba nombres largos y mensajes del servidor. Si necesitas zoom para leer o un ratón para hacer todo, hay trabajo pendiente aunque la captura sea atractiva.

La ampliación de tema alternable puede esperar hasta que la interfaz principal y sus errores sean usables. Una pantalla sencilla y consistente permite demostrar el flujo completo sin ocultar una operación incompleta detrás de decoración.

## Práctica guiada

Maquetar listado y formulario del módulo, comprobando teclado y anchura móvil.

## Tarea para casa

Unificar la navegación y reutilizar los componentes acordados. Adjuntar captura de móvil al PR.

## Criterios de finalización

- [ ] Cada input tiene label.
- [ ] La pantalla se usa con teclado.
- [ ] El diseño no desborda en móvil.

## Preguntas resueltas

**¿Un placeholder reemplaza el label?**

No. El campo necesita un nombre persistente y una asociación programática.

**¿Un div con onClick ya es un botón?**

No adquiere automáticamente todas las capacidades y semántica de un button nativo.

**¿Responsive significa reducir todo?**

Implica adaptar organización, tamaños y acceso al contenido, manteniendo legibilidad y operación.

## Para profundizar

[Tailwind](https://tailwindcss.com/docs) · [shadcn/ui](https://ui.shadcn.com/docs) · [WAI: tutorial de formularios](https://www.w3.org/WAI/tutorials/forms/).

## Conceptos clave de esta clase

- **Token:** Valor de diseño con un nombre y un uso acordados.
- **Breakpoint:** Umbral de anchura desde el que se aplica una regla responsive.
- **Semántica:** Significado que aporta el elemento HTML elegido.
- **Foco:** Control que recibe la interacción del teclado.
- **ARIA:** Atributos que aportan información de accesibilidad cuando el HTML por sí solo no basta.
- **Contraste:** Diferencia perceptible entre elementos como texto y fondo.

## Conexiones

[[Semana3/CLASE 14|Clase 14]] · [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|UI y convenciones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana3/CLASE 12|Clase 12]] · [[Semana3/CLASE 14|Clase 14]] →

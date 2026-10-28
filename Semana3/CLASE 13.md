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

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 12|Clase 12]] · [[Semana3/CLASE 14|Clase 14]] →

> [!abstract] Objetivo
> Construir una interfaz consistente y usable sin dedicar el curso a un sistema de diseño complejo.

## Antes de empezar

Repasa [[Semana3/CLASE 12|Clase 12]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

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

Usar `button` para acciones y `Link` para navegación; labels vinculados a inputs; encabezados ordenados; foco visible; contraste legible; diálogos con nombre accesible y devolución del foco. Probar teclado y pantalla estrecha, no solamente el monitor del instructor.

La identidad visual usa fondo oscuro, superficies diferenciadas y acento violeta. El estado no se comunica solamente por color: acompañar con texto. Modo oscuro alternable y animaciones complejas quedan como ampliación.

## Práctica guiada

Maquetar listado y formulario del módulo, comprobando teclado y anchura móvil.

## Tarea para casa

Unificar la navegación y reutilizar los componentes acordados. Adjuntar captura de móvil al PR.

## Criterios de finalización

- [ ] Cada input tiene label.
- [ ] La pantalla se usa con teclado.
- [ ] El diseño no desborda en móvil.

## Conexiones

[[Semana3/CLASE 14|Clase 14]] · [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|UI y convenciones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana3/INDICE|Semana 3]] · ← [[Semana3/CLASE 12|Clase 12]] · [[Semana3/CLASE 14|Clase 14]] →

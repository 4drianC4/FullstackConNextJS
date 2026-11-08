---
tipo: concepto
tags:
  - curso/conceptos
---

# Renderizado, estado e hidratación

[[Semana3/CLASE 11|Componentes]] · [[Semana3/CLASE 12|Estado y App Router]] · [[Semana3/CLASE 15|Lecturas cliente]]

## Render no significa modificar inmediatamente el DOM

React calcula qué debería representar una instancia de componente con sus datos. Después coordina la actualización de la interfaz. Mantener el cálculo libre de escrituras externas permite repetirlo sin emitir ventas o cambiar la base accidentalmente.

El estado conserva memoria asociada a una instancia. El valor que lees corresponde al render actual; el setter solicita un siguiente estado. No cambia retroactivamente las variables de una función que ya se está ejecutando. Esa observación explica muchos logs que parecen ir un paso atrás.

## Identidad y posición

Dos QuantityControl son dos instancias aunque usan la misma función. React relaciona identidad con posición y keys. Una key aleatoria puede reconstruir el componente; el índice de una lista reordenada puede asociar estado con otra fila. Usa IDs estables para registros persistidos.

Si dos componentes deben compartir un valor, colócalo en su ancestro común y transmite entradas y callbacks. El estado global es una herramienta para necesidades reales de alcance; no es el destino obligatorio de cada input.

## Relación con el dibujo de componentes

[[propDrilling.excalidraw|El dibujo de prop drilling y store]] muestra cómo se comunica un valor entre piezas de interfaz. Úsalo junto a [[Semana3/CLASE 12|la clase de estado]] para distinguir identidad de instancia, propietario del estado y alcance compartido. El dibujo explica circulación de datos, no el proceso de hidratación del servidor.

## Carga inicial en Next.js

El servidor produce la representación inicial de una ruta con componentes de servidor y, cuando corresponde, HTML de componentes cliente. El navegador recibe recursos para mostrar la página y conectar los comportamientos interactivos.

La hidratación asocia esa presentación inicial con el código cliente. Si ambos lados esperan estructuras diferentes, aparecen inconsistencias. Un valor aleatorio, fecha formateada con zona diferente o lectura de almacenamiento solo cliente puede producir esa divergencia.

No resuelvas cualquier advertencia ocultándola. Identifica qué contenido difiere y por qué. Los valores que necesitan navegador deben incorporarse en el momento adecuado sin cambiar de forma accidental el contrato inicial.

## Fronteras de módulos

La directiva use client declara una entrada al conjunto cliente. Los módulos que importa no pueden llevarse secretos o Prisma a ese conjunto. Comparte tipos y esquemas puros; conserva servicios en backend. Un componente de servidor puede componer piezas cliente y entregarles datos serializables públicos.

Un esquema Zod no se vuelve secreto por vivir cerca de un servicio. La organización de carpetas debe permitir compartir validación sin importar configuración privada. Esta es una razón concreta para separar shared, backend y frontend dentro de una funcionalidad.

## Eventos, efectos y desarrollo

Un handler responde a una interacción; un efecto sincroniza con un sistema externo. Un total derivado puede calcularse durante render; no necesita efecto y un segundo estado. Una petición de lectura sí tiene ciclo de vida y requiere considerar cancelación o resultados antiguos.

En desarrollo, React puede ejecutar comprobaciones adicionales y repetir ciclos de efectos bajo Strict Mode para detectar limpiezas incorrectas. No desactives esas comprobaciones para ocultar una venta disparada desde un efecto: cambia la ubicación de la acción. La mutación debe corresponder a una intención explícita y conservar garantías en servidor.

[React: render y commit](https://react.dev/learn/render-and-commit) · [React: estado](https://react.dev/learn/state-a-components-memory) · [Next.js: servidor y cliente](https://nextjs.org/docs/app/getting-started/server-and-client-components).

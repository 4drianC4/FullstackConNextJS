---
tipo: guia
tags:
  - curso/obsidian
---
# Obsidian — Guía del curso

[[README|Inicio]] · [[Semana1/CLASE 1|Clase 1]] · [[Recursos/Conceptos y conexiones|Conceptos]]

## Abrir y leer

1. Clona o descarga el repositorio y abre la carpeta como bóveda en Obsidian.
2. Abre README y el índice de la semana. Usa vista de lectura o Live Preview.
3. Habilita los plugins principales **Backlinks**, **Outgoing links**, **Outline**, **Properties view**, **Search** y **Graph view** si no están activos.
4. Abre el grafo local de una clase para ver su relación con proyecto, recursos y clases vecinas. El grafo es una ayuda, no una obligación.

No se modifica la configuración personal `.obsidian`. No hacen falta Dataview, Templater ni otro plugin comunitario para los enlaces o índices. Los dibujos Excalidraw se conservan y su edición sí requiere el plugin correspondiente.

## Convenciones

- `[[Semana2/CLASE 9|Clase 9 — Permisos]]` enlaza una nota por ruta sin extensión.
- `[[Proyecto/4. Arquitectura vertical y contratos#Permisos|Matriz de permisos]]` enlaza una sección.
- `![[nota]]` incrusta una nota; úsalo en tus apuntes personales con moderación para no duplicar el curso entero.
- Los callouts `> [!tip]`, `> [!warning]` y `> [!abstract]` distinguen práctica, precauciones y objetivos.
- Las propiedades YAML indican tipo, clase, semana y etiquetas. No representan progreso automático.
- Las tareas `- [ ]` son comprobaciones del alumno. Marcarlas no equivale a la evaluación del instructor.

Los nombres de las clases se conservan con su semana. Usar rutas completas evita ambigüedad y permite que los enlaces funcionen aunque haya otros cursos en la bóveda. Si renombras una nota desde Obsidian, acepta actualizar enlaces. No renombres desde el explorador sin revisar las referencias.

## Buscar y conectar

Buscar `tag:#semana/2` muestra las notas etiquetadas de esa semana. `path:Semana3` limita la búsqueda a frontend. Los backlinks de Arquitectura vertical muestran dónde se usa en las clases; los del Modelo de datos enlazan sus reglas con el código.

Plantilla opcional para una nota personal, fuera de las clases compartidas:

```markdown
---
tipo: apunte
tags: []
---
# Mi duda sobre permisos

Relacionado: [[Semana2/CLASE 9|Clase 9]]

## Lo que entendí

## Ejemplo propio

## Duda y cómo la comprobé
```

No hace falta una extensión para copiar esta plantilla. Guarda apuntes personales en tu copia sin modificar accidentalmente las clases compartidas.

## Material visual anterior

Los diagramas de petición, prop drilling y SQL/NoSQL sirven como apoyo conceptual. Los modelos actuales están en [[Proyecto/6. Modelo de datos|Modelo Discoteca]]. Un dibujo histórico no cambia los contratos vigentes.

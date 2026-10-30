---
tipo: guia
tags:
  - curso/obsidian
---
# Obsidian: para conectar ideas y no acumular 47 archivos llamados «apuntes»

[[README|Inicio]] · [[Semana1/CLASE 1|Clase 1]] · [[Recursos/Conceptos y conexiones|Conceptos]]

## Abrir y leer

La bóveda no guarda oro, pero sí la explicación que vas a necesitar justo después de decir «esto lo entendí perfectamente». Vamos a dejarla a mano.

1. Clona o descarga el repositorio y abre la carpeta como bóveda en Obsidian. No hace falta un ritual; elegir la carpeta correcta suele bastar.
2. Abre README y el índice de la semana. Usa vista de lectura o Live Preview: el formato está para ayudarte, no para que leas símbolos como si descifraras una profecía.
3. Habilita los plugins principales **Backlinks**, **Outgoing links**, **Outline**, **Properties view**, **Search** y **Graph view** si no están activos.
4. Abre el grafo local de una clase para ver su relación con proyecto, recursos y clases vecinas. Es una ayuda, no una obligación ni un concurso para ver quién consigue la telaraña más grande.

Tu configuración personal `.obsidian` se respeta: no vamos a redecorar tu casa porque entramos a leer un apunte. Para los enlaces e índices bastan las funciones principales; no necesitas instalar quince plugins antes de escribir la primera nota. Los dibujos Excalidraw sí requieren su plugin si quieres editarlos.

## Convenciones

Estos símbolos tienen una función. No son decoración de un grimorio, aunque algunos nombres de archivo colaboren con la estética.

- `[[Semana2/CLASE 9|Clase 9 — Permisos]]` enlaza una nota por ruta sin extensión.
- `[[Proyecto/4. Arquitectura vertical y contratos#Permisos|Matriz de permisos]]` enlaza una sección.
- `![[nota]]` incrusta una nota; úsalo en tus apuntes personales con moderación para no duplicar el curso entero.
- Los callouts `> [!tip]`, `> [!warning]` y `> [!abstract]` distinguen práctica, precauciones y objetivos.
- Las propiedades YAML indican tipo, clase, semana y etiquetas. No representan progreso automático: poner `tipo: experto` no aprueba el examen.
- Las tareas `- [ ]` son comprobaciones del alumno. Marcarlas no equivale a la evaluación del instructor; ojalá aprender autenticación fuera tan rápido como marcar una casilla.

Los nombres de las clases se conservan con su semana. Usar rutas completas evita ambigüedad y permite que los enlaces funcionen aunque haya otros cursos en la bóveda. Si renombras una nota desde Obsidian, acepta actualizar enlaces. No renombres desde el explorador sin revisar las referencias: un enlace roto es una puerta que abre hacia una pared.

## Buscar y conectar

Antes de preguntar «¿en qué clase estaba?», dale una oportunidad al buscador. No se ofende si escribes la misma duda cinco veces.

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

Puedes copiar esta plantilla sin instalar nada más. Guarda tus notas en tu copia: tus dudas merecen espacio propio, pero no hace falta reemplazar la clase compartida por «preguntarle al profe qué pasó aquí». También vale escribir qué comprobaste y cómo lo resolviste.

## Material visual anterior

Los diagramas de petición, prop drilling y SQL/NoSQL sirven como apoyo conceptual. Los modelos actuales están en [[Proyecto/6. Modelo de datos|Modelo Discoteca]]. Si un dibujo antiguo cuenta otra historia, no hemos abierto un multiverso: el contrato vigente manda.

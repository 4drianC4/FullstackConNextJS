---
tipo: mapa
aliases:
  - Dibujos del curso
  - Índice de Excalidraw
tags:
  - curso/recursos-visuales
---

# Mapa de dibujos Excalidraw

[[README|Inicio]] · [[Recursos/Conceptos y conexiones|Mapa de conceptos]] · [[Recursos/Obsidian - Guia del curso|Leer estos apuntes en Obsidian]]

Los dibujos permiten seguir una explicación visual y volver al concepto que representa cada bloque. Abre el enlace para trabajar sobre el lienzo o consulta su representación incrustada dentro del apunte relacionado. El plugin Excalidraw de Obsidian permite visualizar y editar estos archivos como dibujos.

## Encontrar un dibujo por tema

| Dibujo | Qué representa | Apuntes relacionados |
| --- | --- | --- |
| [[pasosPeticion.excalidraw\|Recorrido de una petición]] | Cliente, ruta, controlador, contrato, servicio, ORM y base | [[Semana1/CLASE 5\|Clase 5]] y [[Semana2/CLASE 6\|Clase 6]] |
| [[SQL VS NOSQL.excalidraw\|SQL y relaciones]] | Tablas de estudiantes/cursos y relación 1:N | [[Semana1/CLASE 4\|Clase 4]] |
| [[propDrilling.excalidraw\|Prop drilling y estado compartido]] | Componentes, inputs y un store como alternativa | [[Semana3/CLASE 12\|Clase 12]] y [[Recursos/Conceptos/Renderizado estado e hidratacion\|Estado y renderizado]] |
| [[ComoOptimizoMemoria.excalidraw\|Almacenamiento y caché]] | Analogía de casa, tienda y supermercado | [[Semana3/CLASE 15\|Clase 15]] y [[Recursos/Conceptos/Cache y sincronizacion\|Caché y sincronización]] |
| [[grpc.excalidraw\|gRPC]] | Comunicación entre bloques de cine y candybar | [[Semana1/CLASE 5\|Clase 5, complemento]] |
| [[WebSockets.excalidraw\|WebSockets]] | Lienzo vacío, pendiente de desarrollar | [[Semana3/CLASE 15\|Clase 15, complemento]] |

## Recorrido de una petición

El dibujo se incrusta en [[Semana1/CLASE 5#Apoyo visual: el viaje de una petición|la explicación del viaje de una petición]]. Vuelve a él al leer los servicios de la clase 6 e identifica la responsabilidad de cada archivo. El esquema de bloques no obliga a crear capas nuevas si no aportan una separación útil.

## Bases de datos y relaciones

Consulta [[Semana1/CLASE 4#Apoyo visual: tablas y relaciones|la lectura guiada de tablas y relaciones]]. El dibujo usa otro dominio para enseñar PK, FK y 1:N; no modifica los modelos de Discoteca. Su nombre SQL VS NOSQL no implica una comparación completa de todas las familias NoSQL.

## Estado en React

En [[Semana3/CLASE 12#Apoyo visual: prop drilling y estado compartido|la explicación de prop drilling]] comparamos pasar datos por componentes intermedios con compartirlos desde un estado común. `store.ts` ilustra una opción, no un requisito de Zustand para el proyecto.

## Almacenamiento y vigencia

La [[Recursos/Conceptos/Cache y sincronizacion#Apoyo visual: casa, tienda y supermercado|analogía de casa, tienda y supermercado]] ayuda a preguntar dónde está una copia, cuánto cuesta recuperarla y cuándo deja de estar vigente. No convierte local storage, Redis y PostgreSQL en piezas intercambiables ni añade Redis al MVP.

## Comunicación entre servicios: gRPC

![[grpc.excalidraw]]

[[grpc.excalidraw|Abrir el dibujo de gRPC]].

El ejemplo separa cine y candybar en bloques conectados. Sirve para conversar sobre responsabilidades y llamadas entre servicios y compararlas con el intercambio HTTP/JSON del curso. Las etiquetas son del ejemplo visual; no son nuevos módulos de Discoteca.

Es material complementario: el proyecto mantiene la arquitectura vertical dentro de Next.js y sus APIs REST. Conocer otra forma de comunicación no obliga a distribuir el proyecto ni a añadir servidores nuevos.

## WebSockets: lienzo pendiente

[[WebSockets.excalidraw|Abrir el lienzo de WebSockets]].

El archivo existe, pero todavía no contiene elementos de dibujo. Queda conectado como apoyo futuro para el complemento de [[Semana3/CLASE 15|la clase 15]]. No se presenta como un diagrama terminado ni como una funcionalidad implementada.

## Cómo aprovecharlos en Obsidian

Los enlaces crean conexiones entre dibujo, clase y concepto en el grafo. Los backlinks de cada dibujo permiten volver a los apuntes que lo explican. Si solo ves el código o la sección de datos del archivo, ábrelo en la vista Excalidraw del plugin; los bloques `compressed-json` contienen el lienzo y no son ejemplos para ejecutar.

Los dibujos conservan sus nombres y su ubicación. Los enlaces usan el nombre real terminado en `.excalidraw` para localizar la nota `.excalidraw.md`. Si renombras uno desde Obsidian, actualiza también sus enlaces.

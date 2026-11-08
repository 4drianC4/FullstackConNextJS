---
tipo: concepto
tags:
  - curso/conceptos
---

# Caché y sincronización

[[Semana3/CLASE 15|Consumo y mutaciones]] · [[semana4/CLASE 16|Integración]]

## Por qué una pantalla puede mostrar un dato antiguo

Entre la base y la pantalla puede haber varias copias: respuesta HTTP conservada, datos reutilizados por servidor, estado de un componente o caché de una librería. Cada capa tiene un ámbito y una política. Borrar una no modifica automáticamente todas las demás.

En el curso empezamos con una estrategia explícita por listado. El cliente consulta con fetch, valida la respuesta y almacena datos locales; una mutación exitosa dispara una nueva lectura. La fuente de verdad del negocio sigue siendo el servidor.

## Apoyo visual: casa, tienda y supermercado

![[ComoOptimizoMemoria.excalidraw]]

[[ComoOptimizoMemoria.excalidraw|Abrir la analogía de almacenamiento y caché]] · [[Recursos/Mapa de dibujos Excalidraw|Ver todos los dibujos]].

El dibujo compara la casa y su despensa, una tienda cercana y un supermercado con lugares donde puede conservarse información. La pregunta útil es qué dato puedes recuperar cerca y cuándo necesitas acudir a su fuente. Tener una copia puede reducir viajes, pero hay que decidir cómo reconocer que quedó antigua.

Local storage vive en el navegador; Redis es un servicio de almacenamiento en memoria que puede emplearse como caché; PostgreSQL conserva los registros relacionales del proyecto. No son niveles obligatorios de una misma jerarquía ni almacenan por defecto lo mismo. Local storage también puede persistir al cerrar el navegador y no es la RAM del componente React.

El nombre del archivo habla de memoria, pero aquí usamos su analogía para explicar almacenamiento, proximidad y vigencia de copias. Redis es complementario y no se instala en el MVP. Las sesiones siguen el mecanismo de cookies del curso; el dibujo no propone guardar tokens privados en local storage.

## Identificar la copia

| Dónde está el dato | Señal de que podría estar desactualizado | Qué revisar |
| --- | --- | --- |
| Base | Varias lecturas entregan el mismo valor incorrecto | Escritura, transacción y entorno |
| Respuesta HTTP | Red no hace una lectura esperada o reutiliza respuesta | Cabeceras y política de caché |
| Componente cliente | API cambia, pero el listado sigue igual | Dependencias y setters de estado |
| Datos del servidor | Página vuelve a entregar un resultado reutilizado | Estrategia de render y revalidación |
| Librería de consultas | Query conserva datos tras mutación | Claves e invalidación configuradas |

No necesitas todas estas capas para el MVP. Conocer sus diferencias evita añadir una librería como solución a un callback que nunca se ejecuta.

## Invalidation y revalidación

Invalidar declara que una copia ya no debe considerarse vigente. Revalidar obtiene o comprueba una versión actual. No son una escritura del negocio: registrar una reserva ocurre antes, y después debes sincronizar la vista que la representa.

router.refresh afecta el árbol de servidor de la ruta. Un useEffect cliente que depende de revision no observa un cambio de revision por ese hecho. Por eso la estrategia local del curso actualiza explícitamente su señal después de guardar.

## Una lectura lenta que llega tarde

Al cambiar de selección, puede terminar primero la petición nueva y después la antigua. Publicar ambas sin control deja en pantalla datos de otra selección. Un AbortController y una comprobación de vigencia evitan aplicar resultados cancelados. Otras estrategias usan un identificador de petición; el principio es el mismo: solo la lectura que corresponde al estado actual puede publicar su resultado.

Cancelar la espera del cliente no revierte efectos del servidor. Para mutaciones, maneja el resultado incierto con un contrato de recuperación, como idempotencia en ventas. No conviertas un abort en una afirmación de que no ocurrió nada.

## Optimismo y confirmación

Optimistic UI muestra provisionalmente el resultado esperado. Necesita reconocer fallo, deshacer o reconciliar y distinguir la identidad temporal de la confirmada. Es útil en algunos escenarios, pero añade estados que el MVP no exige.

Para aforo, ingreso y ventas esperamos confirmación antes de mostrar éxito. El costo de unos instantes de carga es preferible a anunciar un acceso o venta que nunca se confirmó. La copia visible nunca reemplaza las reglas atómicas del backend.

[Next.js: actualización de datos](https://nextjs.org/docs/app/getting-started/updating-data) · [React: efectos](https://react.dev/learn/synchronizing-with-effects).

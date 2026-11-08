---
tipo: concepto
tags:
  - curso/conceptos
---

# Idempotencia y concurrencia

[[Semana2/CLASE 7|Reglas y transacciones]] · [[Semana2/CLASE 10|Pruebas del backend]] · [[Proyecto/6. Modelo de datos|Modelo]]

## Tres problemas que se parecen

Una operación puede fallar a mitad, dos operaciones pueden competir por un dato y un cliente puede repetir una operación ya confirmada. Necesitan garantías distintas. Una transacción trata la unidad de cambios; una escritura condicional o restricción coordina competencia; una clave idempotente reconoce la intención repetida.

| Situación | Riesgo | Garantía aplicada |
| --- | --- | --- |
| Aumenta contador, falla crear entrada | Plaza consumida sin entrada | Transacción con rollback |
| Dos emisiones para la última plaza | Sobreventa | Condición e incremento atómicos |
| Dos reservas para mesa/evento | Duplicación del recurso | Restricción única compuesta |
| Una venta confirmada pierde respuesta | Doble venta al reintentar | Clave de intención única y comparación de contenido |

## La carrera de leer antes de escribir

Con 99 entradas sobre capacidad 100, dos peticiones pueden leer 99 antes de que alguna escriba. Si ambas deciden fuera de la base que hay sitio y crean, el resultado es 101. Una lectura válida no reserva el dato. Por eso la condición `admissionCount < capacity` forma parte de la actualización que incrementa.

En PostgreSQL, la coordinación de escrituras sobre la fila y su condición evita que ambas consuman la misma última plaza con ese patrón. Crear la entrada dentro de la misma transacción conserva la relación entre contador y registro. Si apareciera un segundo camino que crea entradas sin usarlo, rompería el invariante.

No basta documentar una regla: todos los puntos de entrada que afecten esos datos tienen que sostenerla. Cancelar entradas o modificar capacidad en OPEN necesitaría diseñar también sus garantías; por eso no forma parte del MVP.

## Reintentos y respuestas perdidas

Si envías una venta y recibes error de conexión, hay al menos dos posibilidades: el servidor no la guardó o sí la guardó y la respuesta no llegó. Repetir con una clave nueva no permite distinguirlas. La misma requestKey con el mismo contenido permite pedir «completa o devuelve esta misma intención».

El backend busca la clave, compara actor y hash de contenido normalizado y devuelve el resultado ya creado si coincide. Si la clave existe para otro contenido, rechaza. La unicidad de requestKey resuelve también la carrera entre dos peticiones que todavía no la encontraban.

El cliente mantiene la clave durante un reintento incierto. Si cambias productos o cantidades, no reutilices la misma intención como si nada: primero resuelve si la anterior se registró. El hash no se calcula a partir de texto arbitrario del formulario, sino de datos normalizados y ordenados.

## Alcance de las garantías

Idempotencia no implica que dos claves diferentes para pedidos iguales sean una sola venta: podrían ser dos ventas legítimas. La identidad de intención y la política de repetición son parte del contrato. Un sistema real también decide cuánto tiempo conserva claves y cómo audita reintentos.

No confundas idempotencia del efecto con igualdad absoluta de todas las respuestas: un DELETE repetido puede mantener el mismo estado final aunque la segunda respuesta indique inexistencia. En la venta del curso conservamos y devolvemos la representación confirmada de la misma intención.

## Comprobarlo

Prepara escenarios separados de fallo parcial, competencia y reintento. Cuenta filas y revisa invariantes además de códigos HTTP. Una prueba con mocks no demuestra bloqueos o unicidad de PostgreSQL. Ejecuta las carreras en una base aislada y sin datos reales.

[Transacciones Prisma 7](https://www.prisma.io/docs/orm/v7/prisma-client/queries/transactions) · [Aislamiento en PostgreSQL](https://www.postgresql.org/docs/16/transaction-iso.html).

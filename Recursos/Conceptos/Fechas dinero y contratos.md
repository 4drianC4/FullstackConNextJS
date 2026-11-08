---
tipo: concepto
tags:
  - curso/conceptos
---

# Fechas, dinero y contratos

[[Semana1/CLASE 2|Tipos]] · [[Semana2/CLASE 7|Ventas]] · [[Semana3/CLASE 14|Formularios]]

## Número, valor y representación

Un número de centavos no es el mismo dato que un string monetario. `2550` puede usarse para calcular y persistir; `Bs 25,50` es texto para una persona. No parsees valores formateados como si fueran una fuente universal: separadores, símbolos y reglas varían según locale.

Para el curso usamos centavos enteros con moneda BOB acordada. Validamos no negativos, cantidades positivas y total dentro del rango del campo Int de PostgreSQL: máximo 2147483647. Ser un entero seguro de JavaScript no garantiza caber en ese campo. Limita también cantidad de líneas y unidades antes de multiplicar.

Si el dominio exige fracciones más pequeñas o varias monedas, se necesita otro contrato: moneda explícita, redondeo y precisión acordados. No cambies centavos a decimales flotantes solo para mostrar una coma.

## Precio actual y precio aplicado

El catálogo describe cuánto se cobra ahora. La línea de venta guarda lo aplicado a una operación concreta. Cuando un precio cambia, no se recalculan ventas anteriores con el catálogo nuevo. El servidor consulta, calcula y conserva líneas y total coherentes en una transacción.

Una vista puede estimar total antes de confirmar, pero debe comunicar qué valor confirmó el backend. Cambiar precios o disponibilidades mientras otra persona prepara una venta es un caso real, no una excepción imposible.

## Instante, zona y hora de pared

Un instante identifica un punto temporal. Una hora de pared, como «5 de diciembre a las 22:00», necesita contexto de zona para identificarlo. ISO con offset expresa ese contexto en transporte: `2026-12-05T22:00:00-04:00` y `2026-12-06T02:00:00Z` representan el mismo instante.

Una zona como America/La_Paz tiene reglas, no es solo un número escrito permanentemente en el código. Mostrar con Intl.DateTimeFormat y timeZone explícita hace visible la intención de presentación. El navegador en otra zona no debería decidir silenciosamente a qué hora abre la discoteca.

## La frontera datetime-local

El input datetime-local no incluye zona. new Date interpreta ese texto conforme al entorno local; toISOString expresa el instante resultante en UTC. Es apropiado solo si esa interpretación coincide con la política de entrada. Si los equipos trabajan en zonas diferentes, utiliza una conversión de zona explícita y compruébala con ejemplos.

No añadas Z a texto local para «convertirlo»: solo estarías declarando que aquella hora ya era UTC. Tampoco confundas validar formato ISO con exigir fecha futura o impedir reservas en un evento cerrado. Formato y reglas temporales son comprobaciones distintas.

## Contratos para evitar sorpresas

Documenta nombre del campo, unidad, zona y límites. `priceCents` expresa unidad; `startsAt` viaja como ISO con zona; `createdAt` refleja un hecho creado por servidor. No permitas que el body elija timestamps internos o identidad del actor sin una razón del negocio.

[Date en MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date) · [Intl.NumberFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat) · [Tipos numéricos PostgreSQL](https://www.postgresql.org/docs/16/datatype-numeric.html).

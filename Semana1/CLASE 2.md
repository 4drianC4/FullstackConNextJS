---
tipo: clase
clase: 2
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 2 — TypeScript aplicado al backend

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 1|Clase 1]] · [[Semana1/CLASE 3|Clase 3]] →

> [!abstract] Objetivo
> Usar TypeScript para expresar contratos del backend.

## Antes de empezar

Repasa [[Semana1/CLASE 1|Clase 1]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### El problema que resuelve el tipado

Imagina que una función recibe la capacidad de un evento como número, pero otro archivo le envía el texto `"100"`. JavaScript puede producir conversiones inesperadas al sumar o comparar. TypeScript permite expresar qué valores acepta una función y detectar usos incompatibles mientras desarrollas. No sustituye las pruebas, pero reduce errores antes de ejecutar el recorrido.

Hay dos momentos distintos. En **comprobación estática**, TypeScript analiza el código conocido. En **ejecución**, la aplicación recibe valores de usuarios, archivos o servicios externos. Una petición JSON no pasó por el compilador de tu proyecto: tendrás que validarla aunque la variable tenga un nombre convincente.

### Inferencia y anotaciones

TypeScript infiere muchos tipos a partir de los valores. `const capacity = 100` ya aporta información; no hace falta anotar cada número. En cambio, las fronteras de una funcionalidad se benefician de tipos explícitos: qué recibe el servicio y qué entrega al resto del sistema.

`string`, `number` y `boolean` describen categorías amplias. Los literales restringen valores concretos: `"ADMIN" | "STAFF"` expresa dos roles, no cualquier texto. Una unión permite representar alternativas y obliga a considerar los estados posibles.

```ts
type EventState = "DRAFT" | "OPEN" | "CLOSED";
function canIssueAdmission(state: EventState): boolean {
  return state === "OPEN";
}
```

`canIssueAdmission("OPEN")` cumple el contrato. `canIssueAdmission("ABIERTO")` no lo cumple aunque parezca una traducción razonable: el sistema debe acordar una representación consistente. Los textos visibles pueden traducirse sin cambiar el valor almacenado.

### Tipos de objetos y datos ausentes

Un contrato de objeto enumera campos con significado. `name: string` significa que debe existir un texto; `description?: string` admite que el campo no esté. `description: string | null` exige el campo, pero permite expresar ausencia con null. Estas opciones tienen efectos diferentes en una edición parcial.

En PATCH, omitir `name` normalmente significa conservarlo. Enviar `null` significaría vaciarlo si el dominio lo permite. No reemplaces ambas situaciones con un valor por defecto sin decidir qué debería ocurrir.

Los arrays también necesitan contrato: `EventSummary[]` es una lista de resúmenes. Una lista vacía es válida y no equivale a un error ni a `null`. La interfaz deberá mostrar que todavía no hay eventos.

### Tipos e inferencia

TypeScript verifica código antes de ejecutarlo; los tipos se eliminan al compilar. No valida automáticamente un JSON recibido por HTTP.

```ts
type Role = "ADMIN" | "STAFF";
type EventStatus = "DRAFT" | "OPEN" | "CLOSED";

type EventSummary = {
  id: string;
  name: string;
  capacity: number;
  status: EventStatus;
};

function availablePlaces(capacity: number, sold: number): number {
  return Math.max(0, capacity - sold);
}

async function example(): Promise<EventSummary[]> {
  return [];
}
```

Usar `type` o `interface` para contratos, uniones para estados y `?` para datos opcionales. Distinguir `undefined` (ausencia) de `null` (valor explícitamente vacío). No forzar con `as` datos que todavía no se verificaron.

### unknown y estrechamiento

```ts
function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Error desconocido";
}
```

Los datos externos entran como `unknown` y se validan con Zod en la clase 5. `any` desactiva comprobaciones y no se utiliza en nuestros ejemplos.

### Contrato público frente a modelo persistido

Un usuario en la base puede tener `passwordHash`; el contrato público solo contiene `id`, `name`, `email` y `role`. No enviar un modelo completo por comodidad.

En dinero usaremos **centavos enteros**: Bs 25,50 se representa como `2550`. Para fechas HTTP usaremos ISO 8601; convertir a `Date` en el servidor y mostrar la zona horaria local en la interfaz.

### Comprobación

En la aplicación usar `strict: true` y el script `typecheck: tsc --noEmit`. Resolver el error, no silenciarlo. Todavía no usamos JSX: los archivos son `.ts`.

### Componer contratos sin duplicar información

Podemos derivar tipos para evitar describir el mismo objeto de varias maneras incompatibles:

```ts
type Drink = {
  id: string;
  name: string;
  priceCents: number;
  available: boolean;
};
type CreateDrinkInput = Pick<Drink, "name" | "priceCents">;
type EditDrinkInput = Partial<Pick<Drink, "name" | "available">>;
```

`Pick` selecciona campos existentes. `Partial` hace opcionales las propiedades seleccionadas. Eso no demuestra que un PATCH contenga al menos un cambio ni que el precio sea positivo; esas reglas se validan en ejecución. Los tipos ayudan a mantener relaciones entre contratos, pero no deben esconder decisiones del negocio.

### Uniones discriminadas para resultados

Un resultado que a veces incluye un valor y a veces un error puede expresarse con un campo que distinga ambas alternativas:

```ts
type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: string };

function formatResult(result: Result<number>): string {
  if (result.ok) return `Total: ${result.value} centavos`;
  return result.error;
}
```

`T` es un parámetro de tipo: permite describir la misma estructura para distintos valores. Dentro de la rama `ok`, TypeScript conoce `value`; fuera de ella no debes asumir que existe. No necesitas crear genéricos para cada función del curso, pero entenderlos ayuda a leer librerías.

### Por qué unknown no es un obstáculo

Un `unknown` dice «todavía no sé qué llegó». Para utilizarlo, necesitas evidencia: comprobar si es un objeto, un string o una instancia de Error. Una conversión `as EventSummary` solo cambia lo que cree el compilador; no inspecciona el objeto real.

Supón que la respuesta trae `{ "capacity": "muchas" }`. Un `as` no transforma ese texto en un número. En la clase de Zod construiremos el análisis que rechaza esa entrada y entrega un valor validado. Este paso se llama estrechamiento o narrowing cuando el código reduce las posibilidades del tipo.

### Fechas, números y transporte

El tipo `number` no expresa por sí mismo «entero positivo». Para precios acordamos centavos enteros y comprobamos sus límites. `2550` representa Bs 25,50; el formato con coma y símbolo pertenece a la presentación.

Una fecha `Date` del servidor se serializa como texto al responder JSON. Un contrato HTTP debe decir que la fecha es string ISO, no prometer un objeto con métodos como `getFullYear()`. Reconstruir una Date y decidir zona horaria es un paso posterior.

### Leer un error de TypeScript

Si aparece «Type string is not assignable to type number», busca el campo y la función implicados. Pregunta si el contrato es correcto y si la conversión debe ocurrir en esa frontera. No cambies todo a `any` ni uses una aserción para ocultar el problema. Un error que desaparece del editor puede seguir existiendo en producción.

Ejecuta el script de tipos desde la aplicación. `--noEmit` comprueba sin generar archivos JavaScript nuevos. Esta comprobación debe pasar en un clon limpio, no solamente después de reiniciar el editor.

### Caso desarrollado: la capacidad llega como texto

Tienes un formulario cuyo input muestra `100`. La función del backend declara `capacity: number`, pero en la red observas `"capacity": "100"`. La pantalla y el JSON se parecen visualmente; el contrato es distinto.

La solución no es escribir `body as CreateEventInput`. Esa aserción permite al compilador confiar sin cambiar el valor. Debes decidir la frontera de conversión. En nuestro contrato HTTP, capacity es un número: el formulario convierte su valor y el backend exige número entero dentro de rango. Un cliente que envíe texto recibe 400.

También sería posible diseñar una API que acepte texto y lo convierta explícitamente. Eso requeriría documentarlo y tratar cadenas vacías, decimales, espacios y valores no numéricos. No mezcles ambas políticas sin darte cuenta: un contrato claro reduce dudas entre frontend y backend.

Después de convertir, todavía no has demostrado positividad ni rango. `-10` es number y JSON válido. Ahí entra la validación de ejecución. Finalmente, aun un 100 válido puede incumplir una regla del evento si intentas editarlo cuando ya está abierto.

El ejemplo muestra tres preguntas diferentes: representación, validez de entrada y permiso/regla de negocio. TypeScript ayuda en la representación del código; Zod comprueba la frontera; el servicio y base conservan las reglas. Una sola palabra como «validado» no debe ocultar qué se comprobó realmente.

## Práctica guiada

Definir contratos para evento y bebida. Introducir un error de tipo y explicar el diagnóstico del compilador.

## Tarea para casa

Definir los contratos de entrada y salida de tu tarea y añadir ejemplos de JSON sin datos reales.

## Criterios de finalización

- [ ] No utilizas any.
- [ ] Distingues tipo estático y validación en ejecución.
- [ ] Los contratos no exponen datos privados.

## Preguntas resueltas

**¿Poner un tipo a un JSON lo valida?**

No. Los datos externos necesitan comprobaciones en ejecución; una aserción solo cambia la visión del compilador.

**¿Partial hace seguro cualquier PATCH?**

No. Hace opcionales los campos, pero no impide un objeto vacío ni aplica reglas de negocio.

**¿Por qué no devolver User completo?**

Puede contener campos privados y acopla el contrato público a cambios internos de persistencia.

## Para profundizar

[TypeScript: tipos cotidianos](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html) · [Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html).

## Conceptos clave de esta clase

- **Inferencia:** Tipo deducido por el compilador a partir del código.
- **Unión:** Tipo que admite varias alternativas explícitas.
- **Narrowing:** Reducción de posibilidades mediante comprobaciones.
- **DTO:** Contrato de datos que cruza una frontera; no tiene por qué ser el modelo completo.
- **Genérico:** Parámetro de tipo que permite reutilizar una estructura.
- **Serialización:** Conversión de valores a un formato de transporte, como JSON.

## Conexiones

[[Proyecto/4. Arquitectura vertical y contratos|Contratos por funcionalidad]] · [[Semana1/CLASE 5|Clase 5]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 1|Clase 1]] · [[Semana1/CLASE 3|Clase 3]] →

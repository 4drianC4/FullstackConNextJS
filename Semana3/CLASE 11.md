---
tipo: clase
clase: 11
semana: 3
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/3
---

# Clase 11 — React I - Componentes y props

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana2/CLASE 10|Clase 10]] · [[Semana3/CLASE 12|Clase 12]] →

> [!abstract] Objetivo
> Construir componentes React tipados para mostrar información del proyecto.

## Antes de empezar

Repasa [[Semana2/CLASE 10|Clase 10]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### De manipular elementos a describir una interfaz

Con JavaScript puedes buscar nodos del DOM y cambiar su contenido manualmente. React propone describir cómo debería verse la interfaz para unos datos y organizar esa descripción en componentes. Al cambiar datos o estado, React vuelve a calcular la salida necesaria y actualiza el DOM correspondiente.

Un componente es una función que devuelve una descripción de interfaz. No es una clase CSS ni un archivo con nombre especial. En nuestros ejemplos utilizamos funciones con nombre en PascalCase para que JSX las distinga de etiquetas HTML como `button` o `section`.

Una tarjeta de bebida recibe nombre, precio y disponibilidad. Su responsabilidad es mostrarlos; no debería decidir por sí sola quién puede cambiar precios ni consultar contraseñas. Separar la presentación del comportamiento del servidor permite reutilizar la tarjeta sin llevarse dependencias privadas al navegador.

### JSX no es un string HTML

JSX permite escribir estructuras parecidas a HTML dentro de TypeScript, pero las expresiones entre llaves se evalúan como código. Las etiquetas se cierran, `className` representa clases y `htmlFor` asocia un label con un input. Para agrupar hermanos puedes usar un contenedor semántico o un fragmento.

```tsx
const clubName = "Discoteca Demo";
const title = <h1>{clubName}</h1>;
const warning = <p>{2 + 3} entradas disponibles</p>;
```

Las llaves no convierten cualquier objeto en contenido visible. Si intentas renderizar directamente un objeto de evento, necesitas elegir sus campos o formatearlo. En cambio, texto y números pueden representarse como contenido.

JSX escapa texto por defecto, lo cual ayuda a evitar interpretar un nombre como HTML ejecutable. No abandones esa protección utilizando HTML sin filtrar porque una API devuelve una descripción. En este proyecto las descripciones son texto, no instrucciones para el navegador.

### Props: la entrada de un componente

Las props se parecen a argumentos de función. El padre decide qué datos entrega; el hijo los lee y describe su interfaz. No modifica el objeto recibido para «actualizar» al padre. Un componente puede recibir texto, números, objetos o incluso contenido mediante `children`, respetando las fronteras de servidor/cliente.

TypeScript ayuda a comprobar los nombres y tipos. Si `DrinkCard` exige `priceCents`, pasar `price` no cumple el contrato. Esto detecta una desalineación antes de descubrir que la pantalla muestra NaN.

### Componentes y JSX

React describe la interfaz mediante componentes. JSX permite expresar esa estructura en `.tsx`; no es un string HTML. Usar `className`, expresiones entre llaves y un único contenedor de retorno.

```tsx
// src/features/drinks/frontend/drink-card.tsx
export type DrinkSummary = {
  id: string;
  name: string;
  priceCents: number;
  available: boolean;
};
export function DrinkCard({ drink }: { drink: DrinkSummary }) {
  const price = new Intl.NumberFormat("es-BO", {
    style: "currency", currency: "BOB",
  }).format(drink.priceCents / 100);
  return (
    <article>
      <h2>{drink.name}</h2>
      <p>{price}</p>
      <p>{drink.available ? "Disponible" : "No disponible"}</p>
    </article>
  );
}
```

Las props son entradas de solo lectura. Un componente hijo no modifica el objeto del padre. Extraer el tipo al contrato compartido al integrarlo con el backend; no mantener dos definiciones contradictorias.

### Listas y composición

```tsx
import { DrinkCard, type DrinkSummary } from "./drink-card";
export function DrinkList({ drinks }: { drinks: DrinkSummary[] }) {
  if (drinks.length === 0) return <p>No hay bebidas registradas.</p>;
  return <section>{drinks.map((drink) => <DrinkCard key={drink.id} drink={drink} />)}</section>;
}
```

La key es un identificador estable. No usar el índice de una lista que cambia. Mostrar estados condicionales con expresiones; no añadir estado a información que puede derivarse de las props.

### Ubicación

La tarjeta pertenece a `features/drinks/frontend`. Un botón compartido pertenece a `shared/ui`. No convertir todo en componente global solo porque tiene pocas líneas. En esta clase usamos fixtures, sin llamadas a la API todavía.

### Seguir el ejemplo de tarjeta

`DrinkSummary` representa la vista pública que necesita la tarjeta. `priceCents / 100` convierte a unidades monetarias solo para mostrar; `Intl.NumberFormat` añade formato y moneda. No persistas el resultado formateado porque contiene símbolos y separadores de presentación.

La condición de disponibilidad produce texto accesible. Una tarjeta gris sin explicación puede parecer rota; el texto «No disponible» comunica lo que ocurre sin depender solo del color. El bloque `<article>` agrupa una unidad de contenido reconocible.

La función debe ser pura respecto de sus entradas: para las mismas props produce la misma descripción y no modifica la base ni dispara ventas. No hagas fetch ni escrituras durante el renderizado de un componente cliente. React puede repetir cálculos y no queremos duplicar efectos de negocio.

### Renderizar listas e identidad estable

Al usar map para construir tarjetas, React necesita distinguir sus instancias entre cambios. La key es esa pista de identidad y debe corresponder al registro, no a su posición actual ni a un valor aleatorio generado al renderizar.

Si una lista se reordena y usas el índice, React puede asociar estado de una fila con otra. Esto se vuelve visible cuando hay inputs o controles locales. Un UUID persistido conserva identidad aunque cambie el orden.

`key` tiene un tratamiento especial: si el componente necesita el ID, pásalo dentro de su dato o como otra prop. No asumas que puede leer una prop llamada key del modo habitual.

### Estados vacíos y renderizado condicional

Un listado puede contener cero registros sin estar fallando. Mostrar «No hay bebidas registradas» distingue esa situación de una pantalla en blanco por error. Una condición temprana permite resolver casos especiales y después describir el caso normal.

Cuidado con `{count && <p>...</p>}` si count puede ser 0: podrías renderizar un cero. Expresa una condición booleana como `count > 0`. Lee el código como una decisión de interfaz, no solo como una manera de acortar líneas.

### Composición antes de crear una biblioteca gigante

Una página puede combinar título, filtros, listado y estado vacío. Extraer componentes ayuda cuando cada uno tiene significado claro, se repite o evita mezclar varias responsabilidades. Crear un componente por cada span no mejora automáticamente la lectura.

`features/drinks/frontend` contiene piezas de bebidas. `shared/ui` contiene controles transversales, como un botón con estilo común. Evita que un botón global conozca la tabla Drink o el endpoint de reservas: esa dependencia invierte la separación que estamos construyendo.

### Recorrido de comprobación

Renderiza una bebida disponible, otra no disponible y una lista vacía. Cambia el nombre y precio de los fixtures y predice la salida. Introduce un precio como string y observa el error de tipos. Reordena las tarjetas usando IDs estables. Este recorrido comprueba contrato y representación antes de sumar peticiones de red.

Conservar los datos de prueba en una nota o módulo claramente identificado permite reemplazarlos después por la API sin cambiar la responsabilidad de presentación. No presentes un mock como si fuera información confirmada por el servidor.

### Caso desarrollado: una lista se reordena y un input cambia de bebida

Tienes tres tarjetas con un control local de cantidad. La primera muestra agua y cantidad dos. Al ordenar por precio, otra bebida ocupa la primera posición. Si utilizaste el índice como key, React puede asociar la memoria de esa posición al nuevo registro.

El resultado visible parece una cantidad movida de bebida. No es un error de multiplicación ni una escritura de base: es identidad de instancia en la representación. Usa drink.id como key para que la tarjeta siga al mismo registro al reordenarse.

No generes una key aleatoria en cada render para «asegurar unicidad». Eso cambia identidad cada vez y puede reiniciar todos los controles, perder foco y rehacer trabajo. Estable y única dentro de la lista son las propiedades que necesitas.

Después decide dónde debería vivir cantidad. Si prepara una venta con varias filas y un total común, probablemente debe estar en el padre que coordina ese borrador, no aislada sin comunicación en cada tarjeta. La key resuelve identidad; no define por sí sola la fuente del estado compartido.

Prueba agregar, quitar y reordenar registros. Comprueba que valores y foco conservan la relación esperada. Este ejemplo muestra que los fundamentos de React afectan la precisión del negocio incluso antes de conectar una API.

## Práctica guiada

Mostrar un listado de bebidas de prueba y un estado vacío.

## Tarea para casa

Crear dos componentes de tu funcionalidad con props tipadas y datos del contrato acordado.

## Criterios de finalización

- [ ] No mutas las props.
- [ ] Las listas usan IDs estables.
- [ ] La interfaz contempla cero resultados.

## Preguntas resueltas

**¿Una prop puede modificarse para actualizar al padre?**

No. El padre mantiene la fuente de datos; la interacción se comunica mediante callbacks cuando corresponde.

**¿Por qué no usar Math.random como key?**

Cambia la identidad en cada render y puede reconstruir componentes y perder estado.

**¿Una lista vacía implica fallo de API?**

No. Es un resultado válido que merece un estado visible propio.

## Para profundizar

[React: describir la interfaz](https://react.dev/learn/describing-the-ui).

## Conceptos clave de esta clase

- **DOM:** Estructura de elementos que representa la página en el navegador.
- **JSX:** Sintaxis para describir elementos de interfaz dentro del código.
- **Prop:** Entrada que un componente recibe de su padre.
- **Render:** Cálculo de la descripción de interfaz a partir de datos y estado.
- **Key:** Identidad estable que React usa para seguir elementos de listas.
- **Composición:** Construcción de una interfaz combinando componentes con responsabilidades claras.

## Conexiones

[[Semana1/CLASE 2|Clase 2]] · [[Semana3/CLASE 12|Clase 12]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana2/CLASE 10|Clase 10]] · [[Semana3/CLASE 12|Clase 12]] →

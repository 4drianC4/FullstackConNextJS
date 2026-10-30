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

## Práctica guiada

Mostrar un listado de bebidas de prueba y un estado vacío.

## Tarea para casa

Crear dos componentes de tu funcionalidad con props tipadas y datos del contrato acordado.

## Criterios de finalización

- [ ] No mutas las props.
- [ ] Las listas usan IDs estables.
- [ ] La interfaz contempla cero resultados.

## Conexiones

[[Semana1/CLASE 2|Clase 2]] · [[Semana3/CLASE 12|Clase 12]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana3/0 INDICE|Semana 3]] · ← [[Semana2/CLASE 10|Clase 10]] · [[Semana3/CLASE 12|Clase 12]] →

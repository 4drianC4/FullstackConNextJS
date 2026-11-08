---
tipo: clase
clase: 10
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 10 — Pruebas e integración del backend

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 9|Clase 9]] · [[Semana3/CLASE 11|Clase 11]] →

> [!abstract] Objetivo
> Comprobar el backend antes de empezar la interfaz y acordar contratos estables.

## Antes de empezar

Repasa [[Semana2/CLASE 9|Clase 9]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Qué significa comprobar software

Probar consiste en comparar un comportamiento con una expectativa definida bajo condiciones controladas. Ejecutar la aplicación y ver que no se cayó aporta poca evidencia si nunca intentaste un valor inválido, un permiso incorrecto o un reintento.

Una prueba automatizada conserva esa comparación para repetirla. No demuestra que el sistema carezca de errores; demuestra que ciertos casos concretos cumplen su contrato con las condiciones usadas. Por eso la calidad depende de elegir casos relevantes, no de acumular aserciones que repiten el código.

### Niveles de prueba

Una prueba unitaria observa una función o regla aislada. Una de integración observa colaboración real, por ejemplo endpoint, sesión y base. Una E2E recorre un flujo desde la interfaz. Cada nivel descubre problemas diferentes y tiene un coste distinto de preparación y diagnóstico.

Si una función `canAccess` rechaza STAFF, un test unitario puede demostrarlo. No demuestra que `postEvent` llame esa función: esa conexión necesita integración. Si la API crea un evento correctamente, tampoco demuestra que el formulario envíe el contrato correcto: eso aparece al conectar frontend.

### Preparación, acción y comprobación

Organiza un test en tres partes: prepara datos, ejecuta una acción y compara resultado. Por ejemplo, capacidad cero es un caso que el esquema debe rechazar. Si el test solo copia el esquema en otro archivo y compara ambas definiciones, no está usando el comportamiento real que quieres proteger.

Usa nombres que describan reglas: «rechaza capacidad negativa» explica qué se rompe si falla. «test 1» obliga a abrir el código para descubrirlo. Una buena prueba ayuda a depurar a quien no escribió la funcionalidad.

### Casos normales, bordes y rechazos

Para capacidad 1–10000, prueba valores válidos y límites: 1, 10000, 0 y 10001. Incluye un decimal, texto y ausencia. No necesitas probar todos los enteros; elige clases de entrada que ejerciten reglas diferentes.

Para permisos, incluye éxito autorizado y rechazo no autorizado. Para unicidad, verifica una creación y luego el duplicado. Para concurrencia, prepara estado y lanza operaciones que realmente se solapen. Si tu test llama una y después otra, no puso a prueba la carrera de la última plaza.

### Pruebas automatizadas pequeñas

Instalar Vitest como dependencia de desarrollo y añadir `test: vitest run` a los scripts. Los ejemplos siguientes importan rutas relativas para no depender de configurar aliases en Vitest.

```ts
// src/features/events/shared/event.schema.test.ts
import { describe, expect, it } from "vitest";
import { createEventSchema } from "./event.schema";
describe("entrada de eventos", () => {
  const valid = { name: "Noche Disco", startsAt: "2026-12-05T22:00:00-04:00", capacity: 100 };
  it("acepta un evento válido", () => {
    expect(createEventSchema.safeParse(valid).success).toBe(true);
  });
  it("rechaza capacidad negativa y campos de privilegio", () => {
    expect(createEventSchema.safeParse({ ...valid, capacity: -1 }).success).toBe(false);
    expect(createEventSchema.safeParse({ ...valid, role: "ADMIN" }).success).toBe(false);
  });
});
```

```ts
// src/shared/lib/permissions.test.ts
import { expect, it } from "vitest";
import { canAccess } from "./permissions";
it("impide al personal administrar", () => {
  expect(canAccess("STAFF", ["ADMIN"])).toBe(false);
  expect(canAccess("ADMIN", ["ADMIN"])).toBe(true);
});
```

Estas pruebas no demuestran que los endpoints ejecuten el guard: hay que comprobar la integración real.

### Matriz de integración local

Usar una base separada de prueba, migraciones y fixtures. Nunca ejecutar limpieza de datos contra producción. Obtener sesiones mediante el flujo real de Auth.js (incluido CSRF); no fabricar JWT a mano.

| Caso | Resultado |
| --- | --- |
| GET protegido sin sesión | 401 |
| POST administrativo con STAFF | 403 |
| Origen externo en mutación autenticada | 403 |
| ADMIN con JSON inválido | 400 |
| Reserva duplicada | 409, una sola fila |
| Dos ingresos simultáneos | Un éxito, un conflicto |
| Dos emisiones para una plaza restante | Una emisión, contador consistente |
| Dos ventas con la misma clave | Una sola venta; conflicto si cambia el contenido |

Conservar evidencia en el PR: request, status y comprobación de datos. La automatización de estas peticiones es una tarea del equipo después de tener el flujo de sesión funcionando; no sustituirla por mocks que omitan permisos.

### Hito de cierre de backend

Cada equipo publica contrato, ejemplos y datos de prueba. Antes de solicitar integración, ejecuta `npm run typecheck`, `npm run lint`, `npm test` y `npm run build`. Si dependes de un módulo todavía incompleto, utiliza fixtures compatibles, indica la dependencia en el PR y distingue el recorrido simulado del flujo terminado.

### Qué hacen Vitest y las aserciones

Vitest descubre archivos según su configuración, ejecuta funciones de prueba y informa las aserciones fallidas. `describe` agrupa contexto; `it` nombra un comportamiento; `expect` compara lo obtenido con lo esperado. `toBe` compara valores; para estructuras puedes necesitar `toEqual`.

Un test asíncrono debe esperar su promesa. Si disparas una operación sin await y el test termina antes de la comparación, puedes obtener una falsa sensación de éxito. Los fallos de preparación tampoco deben convertirse silenciosamente en tests omitidos que nadie ve.

### Separar pruebas de herramientas diferentes

Los archivos `src/**/*.test.ts` contienen pruebas de Vitest. Los specs del navegador viven en `tests` y Playwright los ejecuta con su configuración. Esta separación evita que una herramienta interprete la API de otra. La nota de stack muestra los scripts acordados.

Configura el alcance de forma intencional. Si usas alias `@/`, el entorno de pruebas debe resolverlos; los ejemplos iniciales utilizan imports relativos para no añadir ese problema al primer test. No cambies imports productivos a rutas rotas para hacer pasar una prueba.

### Datos controlados y aislamiento

Una base de prueba permite preparar registros y limpiar resultados sin afectar el trabajo del grupo. Debe tener una URL diferente y un nombre reconocible. No asumas que un sufijo `_test` en una variable basta si apunta al mismo servidor/base de producción.

Evita que los tests dependan del orden de ejecución o de una reserva dejada por alguien ayer. Usa identificadores propios, prepara el estado requerido y limpia de forma controlada. En pruebas de carreras, comprueba filas y contadores al final; las respuestas HTTP no cuentan toda la historia.

### Mocks y qué dejan fuera

Un mock reemplaza una dependencia para controlar su respuesta. Es útil para simular un fallo de red o una fecha, pero si reemplazas la base por una lista en memoria no estás comprobando FK, unicidad ni aislamiento de PostgreSQL. Esas garantías necesitan la base real en integración.

No fabriques la sesión de forma que omita todos los guards y después concluyas que el login es seguro. Puedes usar dobles en una prueba unitaria, pero una integración del flujo debe pasar por las credenciales y protocolo de la librería.

### Convertir un bug en evidencia repetible

Si una reserva duplicada pasó desapercibida, prepara un caso que falle con el código anterior y pase con la corrección. Comprobar únicamente un caso feliz nuevo puede no detectar una futura regresión. La prueba debe describir la regla, no el detalle accidental de cómo hoy se implementa.

En el PR incluye comandos ejecutados, estado del entorno, resultado y límites. «Pasaron pruebas de esquema y permisos; pendiente integración de login» es información útil y honesta. «Todo probado» cuando solo corriste lint genera expectativas falsas.

La nota [[Recursos/Conceptos/Pruebas CI y evidencias|Pruebas, CI y evidencias]] explica cómo combinar estas verificaciones al integrar y desplegar.

## Práctica guiada

Ejecutar pruebas de validación/permisos y una prueba de integración de un equipo vecino.

## Tarea para casa

Completar el backend de la funcionalidad y abrir PR con evidencia. Resolver discrepancias del contrato antes del frontend.

## Criterios de finalización

- [ ] Las pruebas detectan una entrada y un permiso incorrectos.
- [ ] Los endpoints se prueban con sesiones reales.
- [ ] El contrato está integrado y documentado.

## Preguntas resueltas

**¿Muchos tests significan más calidad?**

Solo si protegen reglas relevantes y fallan cuando esas reglas se rompen.

**¿Un mock demuestra la restricción única?**

No. La unicidad de PostgreSQL debe comprobarse con la base real.

**¿Por qué un test asíncrono puede pasar sin probar nada?**

Si no espera la operación, puede finalizar antes del resultado o de la aserción.

## Para profundizar

[Vitest](https://vitest.dev/guide/) · [Playwright](https://playwright.dev/docs/intro).

## Conceptos clave de esta clase

- **Aserción:** Comparación que debe cumplirse para que un caso pase.
- **Fixture:** Dato preparado con condiciones conocidas para una prueba.
- **Mock:** Sustituto controlado de una dependencia.
- **Regresión:** Comportamiento que funcionaba y vuelve a fallar tras un cambio.
- **Determinismo:** Capacidad de repetir un resultado con las mismas condiciones.
- **Integración:** Colaboración entre componentes reales que una prueba observa.

## Conexiones

[[Proyecto/5. Evaluacion y entregables|Hito de backend]] · [[semana4/CLASE 16|Clase 16]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 9|Clase 9]] · [[Semana3/CLASE 11|Clase 11]] →

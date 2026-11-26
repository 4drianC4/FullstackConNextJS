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

Conservar evidencia en el PR: request, status y comprobación de datos. Más abajo está cómo automatizar esta matriz con sesiones reales; no la sustituyas por mocks que omitan permisos.

### Hito de cierre de backend

Cada equipo publica contrato, ejemplos y datos de prueba. Antes de solicitar integración, ejecuta `npm run typecheck`, `npm run lint`, `npm test` y `npm run build`. Si dependes de un módulo todavía incompleto, utiliza fixtures compatibles, indica la dependencia en el PR y distingue el recorrido simulado del flujo terminado.

### Qué hacen Vitest y las aserciones

Vitest descubre archivos según su configuración, ejecuta funciones de prueba y informa las aserciones fallidas. `describe` agrupa contexto; `it` nombra un comportamiento; `expect` compara lo obtenido con lo esperado. `toBe` compara valores; para estructuras puedes necesitar `toEqual`.

Un test asíncrono debe esperar su promesa. Si disparas una operación sin await y el test termina antes de la comparación, puedes obtener una falsa sensación de éxito. Los fallos de preparación tampoco deben convertirse silenciosamente en tests omitidos que nadie ve.

### Separar pruebas de herramientas diferentes

Los archivos `src/**/*.test.ts` contienen pruebas de Vitest. Los specs del navegador viven en `tests` y Playwright los ejecuta con su configuración. Esta separación evita que una herramienta interprete la API de otra. La nota de stack muestra los scripts acordados.

Configura el alcance de forma intencional. Los ejemplos iniciales usan imports relativos; en cuanto un test importe código que use `@/`, configura el alias como en la sección siguiente. No cambies imports productivos a rutas rotas para hacer pasar una prueba.

### Vitest con módulos de servidor

Dos cosas rompen el primer test que importa un servicio: el alias `@/` y `import "server-only"`. Ese paquete lanza un error a propósito cuando se carga fuera del entorno de servidor de React, y Vitest no lo es. Configura ambas cosas una vez:

```ts
// vitest.config.ts
import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";
export default defineConfig({
  resolve: { alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) } },
  test: {
    include: ["src/**/*.test.ts"],
    environment: "node",
    setupFiles: ["./vitest.setup.ts"],
  },
});
```

```ts
// vitest.setup.ts
import { vi } from "vitest";
vi.mock("server-only", () => ({})); // solo en tests: el guard de imports sigue activo en Next.js
```

Con esto puedes probar funciones puras de un servicio (por ejemplo, el agrupado de líneas de una venta). Si la función usa Prisma, necesitas la base de test de abajo; para permisos y respuestas HTTP es más fiable la integración por HTTP de la siguiente sección que llamar al controlador a mano.

### Base de datos de test

Las pruebas de integración crean y borran filas, así que usan su propia base, nunca la de desarrollo ni la de producción. Créala en el mismo contenedor de la clase 3:

```bash
docker compose exec db sh -c 'createdb -U "$POSTGRES_USER" discoteca_test'
```

Crea un `.env.test` local (no se versiona: `.env*` ya está en `.gitignore`) con la misma estructura que `.env`, pero apuntando a `discoteca_test`, y añade credenciales de una cuenta STAFF de prueba:

```text
DATABASE_URL=postgresql://discoteca:CAMBIAR_LOCALMENTE@localhost:5432/discoteca_test
AUTH_SECRET=GENERAR_LOCALMENTE
SEED_ADMIN_EMAIL=admin@example.test
SEED_ADMIN_PASSWORD=DEFINIR_LOCALMENTE
SEED_STAFF_EMAIL=staff@example.test
SEED_STAFF_PASSWORD=DEFINIR_LOCALMENTE
```

El seed común solo crea el administrador. Añade dentro de `main()` de `prisma/seed.ts` la cuenta STAFF opcional:

```ts
const staffEmail = process.env.SEED_STAFF_EMAIL?.toLowerCase();
const staffPassword = process.env.SEED_STAFF_PASSWORD;
if (staffEmail && staffPassword) {
  await prisma.user.upsert({
    where: { email: staffEmail }, update: {},
    create: { email: staffEmail, name: "Personal de prueba", role: "STAFF", passwordHash: await bcrypt.hash(staffPassword, 12) },
  });
}
```

Para reconstruir la base de test desde cero, carga sus variables en la terminal y ejecuta reset y seed. Las variables ya definidas en el shell tienen prioridad sobre `.env`, así que Prisma usará la URL de test:

```bash
set -a; source .env.test; set +a
echo "$DATABASE_URL"            # comprueba que termina en /discoteca_test
npx prisma migrate reset --force
npm run db:seed
```

`migrate reset` borra todo lo que hay en esa base. Por eso el `echo` va antes: si ves la URL de desarrollo, para.

### Automatizar la matriz con sesiones reales

Playwright no solo controla navegadores: su cliente `request` hace peticiones HTTP y conserva cookies como un navegador. Lo usamos para la matriz de integración porque pasa por el login real de Auth.js (clase 8) y por los guards reales, sin mocks. Configúralo una vez; la clase 16 reutiliza este archivo para los flujos con navegador:

```ts
// playwright.config.ts
import { defineConfig } from "@playwright/test";
const baseURL = "http://127.0.0.1:3000";
export default defineConfig({
  testDir: "./tests",
  workers: 1, // todos los tests comparten la base de test
  use: { baseURL, trace: "retain-on-failure" },
  webServer: {
    command: "npm run dev -- --hostname 127.0.0.1",
    url: `${baseURL}/api/health`,
    reuseExistingServer: false,
    timeout: 120_000,
    env: { APP_ORIGIN: baseURL, AUTH_URL: baseURL },
  },
});
```

`webServer` arranca la aplicación con las variables de tu terminal (las de `.env.test` si hiciste `source`) más las de `env`. `reuseExistingServer: false` evita conectarse por error a un servidor de desarrollo que apunta a otra base. `127.0.0.1` y `localhost` no son el mismo origen: usa el mismo en `baseURL`, `APP_ORIGIN` y `AUTH_URL`.

```ts
// tests/helpers/session.ts
import { request, type APIRequestContext } from "@playwright/test";
import { z } from "zod";

const BASE_URL = "http://127.0.0.1:3000";

export function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Falta ${name} en el entorno de test`);
  return value;
}

/** Cliente sin sesión, con el Origin que exigen nuestras mutaciones. */
export function anonymous(): Promise<APIRequestContext> {
  return request.newContext({ baseURL: BASE_URL, extraHTTPHeaders: { Origin: BASE_URL } });
}

/** Mismo flujo que con curl: token CSRF, POST de credenciales y comprobación. */
export async function loginAs(email: string, password: string): Promise<APIRequestContext> {
  const api = await anonymous();
  const { csrfToken } = z.object({ csrfToken: z.string() })
    .parse(await (await api.get("/api/auth/csrf")).json());
  await api.post("/api/auth/callback/credentials", {
    form: { csrfToken, email, password },
    maxRedirects: 0,
  });
  const session = z.object({ user: z.object({ id: z.string() }) }).nullable()
    .parse(await (await api.get("/api/auth/session")).json());
  if (!session) throw new Error("No se pudo iniciar sesión con la cuenta de prueba");
  return api;
}

export const asAdmin = () => loginAs(requireEnv("SEED_ADMIN_EMAIL"), requireEnv("SEED_ADMIN_PASSWORD"));
export const asStaff = () => loginAs(requireEnv("SEED_STAFF_EMAIL"), requireEnv("SEED_STAFF_PASSWORD"));
```

```ts
// tests/api/events.spec.ts
import { test, expect } from "@playwright/test";
import { z } from "zod";
import { anonymous, asAdmin, asStaff } from "../helpers/session";

const validEvent = { name: "Evento de test", startsAt: "2026-12-20T22:00:00-04:00", capacity: 10 };

test("GET protegido sin sesión responde 401", async () => {
  const api = await anonymous();
  expect((await api.get("/api/events")).status()).toBe(401);
});

test("STAFF no puede crear eventos", async () => {
  const api = await asStaff();
  expect((await api.post("/api/events", { data: validEvent })).status()).toBe(403);
});

test("ADMIN crea un evento y luego existe", async () => {
  const api = await asAdmin();
  const created = await api.post("/api/events", { data: validEvent });
  expect(created.status()).toBe(201);
  const { id } = z.object({ id: z.string() }).parse(await created.json());
  expect((await api.get(`/api/events/${id}`)).status()).toBe(200);
});

test("una mutación con origen ajeno responde 403", async () => {
  const api = await asAdmin();
  const response = await api.post("/api/events", {
    data: validEvent,
    headers: { Origin: "https://otro-sitio.example" },
  });
  expect(response.status()).toBe(403);
});
```

Para carreras, lanza las dos peticiones a la vez con `Promise.all` y comprueba que exactamente una gana. Adapta las rutas al contrato de tu módulo:

```ts
test("dos ingresos simultáneos: un éxito y un conflicto", async () => {
  const api = await asStaff();
  const issued = await api.post("/api/admissions", {
    data: { eventId: "00000000-0000-4000-8000-000000000001", holderName: "Test" }, // evento OPEN del seed
  });
  const { id } = z.object({ id: z.string() }).parse(await issued.json());
  const [a, b] = await Promise.all([
    api.post(`/api/admissions/${id}/check-in`),
    api.post(`/api/admissions/${id}/check-in`),
  ]);
  expect([a.status(), b.status()].sort()).toEqual([200, 409]);
});
```

Ejecuta con la base de test cargada:

```bash
set -a; source .env.test; set +a
npx playwright test tests/api
```

Las respuestas no cuentan toda la historia: en los casos de concurrencia comprueba también filas y contadores, por ejemplo consultando el detalle después o abriendo `npx prisma studio` contra la base de test.

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

### Caso desarrollado: una prueba pasa y el endpoint sigue abierto

La suite comprueba que canAccess devuelve false para STAFF cuando se exige ADMIN. El resultado es verde. Sin embargo, postEvent no llama al guard y una petición sin sesión crea un evento. La función aislada es correcta; la conexión con el endpoint no existe.

Añade una integración que envíe el request real sin sesión y espere 401. Además comprueba que no haya una nueva fila. Si solo verificas el mensaje del controlador simulado, podrías estar probando un sustituto que ya hace lo esperado y nunca llega al código productivo.

Después añade el caso con STAFF y uno válido con ADMIN. Así distingues «nadie puede crear» de «solo la identidad autorizada puede crear». Un test que rechaza todo no demuestra que el recurso sea usable.

Mantén también el unitario: sigue siendo rápido y útil para explicar la regla. Los niveles no se eliminan entre sí; se combinan porque tienen alcances diferentes. Cuando un caso falle, su nombre y preparación deben permitir ubicar si el problema está en regla, integración o entorno.

En el PR escribe qué niveles ejecutaste y con qué datos. Si no pudiste ejecutar integración porque faltaba PostgreSQL de test, decláralo. Una limitación explícita permite completarla antes de integrar; una afirmación genérica de «tests OK» puede ocultarla.

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

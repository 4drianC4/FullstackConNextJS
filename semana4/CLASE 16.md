---
tipo: clase
clase: 16
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 16 — Integración fullstack y pruebas de flujos

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[Semana3/CLASE 15|Clase 15]] · [[semana4/CLASE 17|Clase 17]] →

> [!abstract] Objetivo
> Verificar flujos completos y resolver fallos antes de preparar producción.

## Antes de empezar

Repasa [[Semana3/CLASE 15|Clase 15]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Integrar significa comprobar acuerdos en funcionamiento

Una funcionalidad puede pasar sus pruebas aisladas y fallar al conectarse con otras. El formulario envía una fecha local mientras el endpoint espera ISO; el listado interpreta una respuesta como array, pero recibe un objeto; el usuario tiene un rol válido, pero la vista llama a una operación administrativa. La integración descubre estas fronteras.

Para analizar el sistema, sigue una intención completa. «Emitir una entrada» comienza con seleccionar un evento, continúa con validación y permiso, termina en una escritura consistente y entrega una confirmación visible. La prueba debe observar el resultado y la ausencia de efectos extra.

### El camino feliz es necesario, pero no suficiente

Un flujo de alta de evento con ADMIN demuestra que esa combinación funciona. No comprueba que STAFF sea rechazado, que un body inválido no persista ni que dos ingresos simultáneos produzcan un único acceso. Completa el recorrido con variaciones que ejerciten sus reglas.

No todas las variaciones deben ser E2E. El navegador es adecuado para comprobar formularios, navegación y feedback. Las peticiones directas son útiles para permisos y concurrencia. La base confirma que los datos resultantes respetan invariantes. Combinar niveles produce evidencia más clara que intentar resolver todo con capturas.

### Protecciones de interfaz y datos

Una página privada verifica sesión y redirige si falta. Después, cualquier lectura privada de servidor y operación de API verifica su acceso. No confíes todo al layout: puede reutilizarse durante navegación y no representa cada punto de entrada del backend.

La interfaz puede mostrar solo acciones permitidas para reducir confusión. Si un usuario invoca una acción oculta manualmente, el backend la rechaza. Ambas comprobaciones se complementan, pero sus garantías no son iguales.

### Un problema, un registro reproducible

Un Issue útil contiene entorno, pasos mínimos, datos sintéticos, resultado esperado, resultado real y evidencia. «La reserva no funciona» no indica si falla al cargar mesas, enviar, validar o actualizar el listado. Escribe una secuencia que otra persona pueda repetir sin preguntarte cada detalle.

Distingue severidad de prioridad: una operación sin permisos puede ser crítica aunque no se vea en una demo; un borde visual pequeño puede ser urgente si impide pulsar guardar en móvil. Atiende primero acceso incorrecto, pérdida/duplicación de datos y recorridos bloqueados.

### Proteger la vista y la operación

Un layout puede redirigir al login para mejorar la experiencia, pero cada API y cada lectura privada de servidor vuelve a verificar permisos. No confiar exclusivamente en el layout: las navegaciones y cachés pueden reutilizarlo.

En una página de servidor leer sesión con `auth()` y usar `redirect("/login")` si falta. Antes de recuperar datos privados invocar el guard de la clase 9. Ocultar acciones administrativas según rol es UX, no una autorización adicional suficiente.

### Escenarios E2E

| Flujo | Resultado esperado |
| --- | --- |
| ADMIN crea evento y lo abre | STAFF puede consultarlo |
| STAFF intenta editar capacidad | Backend rechaza 403 |
| Personal emite entrada e ingresa dos veces | Segundo ingreso rechazado |
| Dos personas reservan la misma mesa/evento | Una reserva y un conflicto |
| Personal vende bebidas | Total del servidor y precios históricos |
| Cuenta desactivada mantiene cookie antigua | Próxima operación rechazada |
| API desconectada | Mensaje y opción de reintento |

El equipo de ventas debe probar la misma clave de petición dos veces; ni un doble clic ni un reintento deben duplicar la venta.

### Un flujo automatizado con Playwright

Instalar `@playwright/test`, instalar el navegador de pruebas y configurar `webServer` o una `baseURL` local. Usar base de prueba y credenciales locales de test, nunca producción.

```ts
// tests/login.spec.ts
import { test, expect } from "@playwright/test";
test("el personal inicia sesión", async ({ page }) => {
  const email = process.env.TEST_EMAIL;
  const password = process.env.TEST_PASSWORD;
  if (!email || !password) throw new Error("Faltan credenciales de prueba");
  await page.goto("/login");
  await page.getByLabel("Correo").fill(email);
  await page.getByLabel("Contraseña").fill(password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(page).toHaveURL(/\/dashboard/);
});
```

Acordar esos labels en el formulario real. Una prueba que solo abre login no verifica permisos: mantener además la matriz de peticiones directas del backend. Ampliar el flujo a crear y consultar un evento con fixtures aislados.

### Refactorizar con evidencia

Resolver errores primero, extraer lógica repetida cuando tenga el mismo significado y volver a ejecutar pruebas. No separar en diez archivos una función de cinco líneas sin necesidad. Abrir Issues con pasos, esperado, obtenido y evidencia sin datos privados.

### Preparar Playwright sin esconder dependencias

Playwright controla un navegador real. Necesita la aplicación ejecutándose, una base de prueba preparada y usuarios de prueba. No asumas que `npm run test:e2e` creará por sí solo todo el entorno. Carga variables de prueba y ejecuta migraciones y seed contra su URL antes de arrancar el servidor.

Puedes configurar `playwright.config.ts` con este punto de partida:

```ts
import { defineConfig } from "@playwright/test";
export default defineConfig({
  testDir: "./tests",
  use: { baseURL: "http://127.0.0.1:3000", trace: "retain-on-failure" },
  webServer: {
    command: "npm run dev -- --hostname 127.0.0.1",
    url: "http://127.0.0.1:3000/login",
    reuseExistingServer: false,
    timeout: 120000,
  },
});
```

En el entorno de test configura APP_ORIGIN y los ajustes de Auth.js con ese mismo origen. `127.0.0.1` y `localhost` no son la misma cadena de host para todas las reglas de cookies/origen. No reutilices un servidor que podría apuntar a la base de otro entorno.

El navegador de pruebas se instala con `npx playwright install chromium`. Los artefactos de trace y capturas pueden incluir datos de pantalla: utiliza únicamente fixtures y no publiques trazas con credenciales o información privada.

### Locators y esperas que expresan intención

`getByLabel("Correo")` identifica el control por su nombre accesible. `getByRole("button", { name: "Entrar" })` se aproxima a cómo una persona reconoce una acción. Son preferibles a un selector basado en la posición accidental del tercer div.

Las aserciones de Playwright esperan condiciones observables. No añadas una pausa fija de cinco segundos para esconder una condición de carrera: espera URL, estado visible o resultado. Una pausa puede pasar en tu equipo y fallar en CI sin decir qué estaba esperando.

### Prueba cruzada de un módulo

Pide a otra persona que use instrucciones del PR sin explicaciones adicionales. Si no puede ejecutar el entorno, hay un problema de reproducción; si puede usar la interfaz pero los datos no persisten, hay un problema de integración. Ambos necesitan documentación y corrección, aunque el código del servicio parezca correcto.

Para la entrada duplicada, registra primera respuesta, segunda respuesta y estado checkedInAt. Para una venta, comprueba cantidad de filas con la misma clave y precios históricos. En reservas, verifica la restricción de mesa/evento, no solo la aparición de un mensaje.

### Refactorizar conservando comportamiento

Refactorizar cambia la estructura sin pretender cambiar el resultado observable. Antes de extraer una función compartida, identifica qué repetición tiene el mismo significado. Dos formularios parecidos pueden tener reglas distintas; forzarlos a una abstracción única añade condiciones y acoplamiento.

Usa pruebas y recorrido manual relevante como referencia. Si cambias contrato o permiso, ya no es solamente refactorización: describe el cambio de comportamiento. Un PR pequeño facilita revisar que la limpieza no borró un caso importante.

### Cerrar un fallo con evidencia

Reproduce el fallo anterior, ejecuta el caso con la corrección y revisa una regresión vecina. Por ejemplo, arreglar ingreso duplicado no debe impedir un primer ingreso válido. Añade al Issue el resultado y enlaza el PR. No cierres un error porque dejó de aparecer una vez después de reiniciar.

### Caso desarrollado: el test solo falla cuando corre con los demás

La prueba de reserva pasa sola y falla en suite porque otro caso ya reservó mesa 1 para el mismo evento. El código podría estar respetando la restricción; lo que no está controlado es el estado inicial del test.

Asigna fixtures propios o prepara y limpia las filas que necesita cada caso con cuidado. No borres toda la base compartida mientras otra prueba la usa. Define si la suite corre en paralelo y qué recursos pueden compartir sus casos.

Comprueba que la URL apunta a la base de test antes de ejecutar limpieza. Reutilizar un servidor existente puede hacer que la suite se conecte a tu aplicación de desarrollo y produzca un estado distinto. La configuración propuesta evita esa reutilización por defecto.

Si la prueba usa la hora actual para permitir una reserva, sus fixtures también pueden vencer con el calendario. Prepara fechas relativas o un reloj controlado según el nivel y documenta la zona. No mantengas un evento pasado en un fixture que exige disponibilidad futura.

Un test intermitente consume confianza: no se resuelve repitiendo hasta que salga verde. Determina si el problema es una carrera del producto o aislamiento del entorno. Ambos son importantes, pero necesitan cambios diferentes y una evidencia que distinga la causa.

## Práctica guiada

Intercambiar módulos entre equipos y registrar bugs reproducibles. Automatizar el login y un flujo del proyecto.

## Tarea para casa

Corregir bloqueantes, revisar responsive y preparar instrucciones de ejecución desde un clon limpio.

## Criterios de finalización

- [ ] Los escenarios críticos están probados.
- [ ] Un compañero puede ejecutar el módulo.
- [ ] No hay bloqueantes conocidos sin registrar.

## Preguntas resueltas

**¿Por qué fallan juntas dos partes que pasan por separado?**

Sus pruebas aisladas pueden no observar los mismos datos, formatos, permisos o secuencia real.

**¿Una pausa fija arregla un test inestable?**

No resuelve la causa. Espera una condición observable y revisa preparación, concurrencia o selectores.

**¿Basta con que desaparezca el mensaje?**

Comprueba el resultado persistido y la regla que originó el problema, no solo su representación.

## Para profundizar

[Playwright: servidor](https://playwright.dev/docs/test-webserver) · [Locators](https://playwright.dev/docs/locators).

## Conceptos clave de esta clase

- **E2E:** Prueba de un recorrido desde la interacción externa del sistema.
- **Locator:** Descripción de cómo encontrar un elemento en una prueba de navegador.
- **Trace:** Registro de acciones y estado de una ejecución de prueba.
- **Severidad:** Gravedad de la consecuencia de un fallo.
- **Refactorización:** Cambio de estructura que busca conservar comportamiento.
- **Contrato roto:** Desacuerdo entre lo que una parte entrega y otra espera.

## Conexiones

[[Semana2/CLASE 10|Clase 10]] · [[Proyecto/5. Evaluacion y entregables|Hito fullstack]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[Semana3/CLASE 15|Clase 15]] · [[semana4/CLASE 17|Clase 17]] →

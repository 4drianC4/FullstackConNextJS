---
tipo: clase
clase: 9
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 9 — Autorización y protección de operaciones

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] →

> [!abstract] Objetivo
> Verificar identidad y permisos en cada operación del backend.

## Antes de empezar

Repasa [[Semana2/CLASE 8|Clase 8]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Decidir quién puede hacer qué

Una sesión válida identifica a una cuenta, pero no autoriza cualquier comportamiento. STAFF puede emitir entradas y registrar ventas; ADMIN puede además administrar eventos, catálogo y cuentas. Esta matriz convierte una idea informal de roles en reglas revisables.

El permiso se comprueba por operación y, cuando hay datos privados, también por recurso. Si en una ampliación cada cliente solo pudiera leer sus reservas, verificar «está logueado» sería insuficiente: habría que filtrar por su identidad. En el MVP el panel es interno y ambos roles consultan los datos operativos definidos en el contrato.

### El servidor obtiene la identidad

El navegador no decide `createdById` de una venta. Un empleado podría enviar el ID de otro o de un administrador. El guard obtiene la sesión y consulta una selección reducida de la cuenta real; el controlador pasa el actor autorizado al servicio.

Ese acceso a la base también permite reconocer cuentas desactivadas. Si el JWT conserva un ID durante ocho horas y se desactiva al usuario, una comprobación del rol antiguo sin consultar estado no reflejaría el cambio.

### Defensa en las fronteras correctas

El botón oculto es útil para no ofrecer acciones que alguien no puede ejecutar. No es una barrera: la misma persona puede construir una petición manual. Un layout que redirige al login mejora la navegación, pero no protege automáticamente un endpoint distinto ni una lectura privada del servidor.

Los Route Handlers se tratan como entradas públicas de red. Cada operación sensible comprueba permisos antes de acceder a datos o modificar estado. Los servicios de lectura invocados directamente desde componentes de servidor también necesitan un acceso autorizado; no quedan protegidos porque no tengan URL propia.

### 401, 403 y la información que revelas

Sin sesión válida respondemos 401. Con identidad válida pero permiso insuficiente respondemos 403. En ciertos productos, responder 404 para recursos privados evita confirmar su existencia; si eliges eso, documenta la política y úsala de forma coherente. No cambies estados al azar según la pantalla.

La API entrega JSON de error. Redirigir una API al formulario de login puede acabar devolviendo HTML con estado 200 tras seguir la redirección, y el cliente fallará al intentar interpretarlo como datos.

### Autenticar no equivale a autorizar

Saber quién inició sesión no permite asumir que puede editar eventos o administrar usuarios. Consultar la matriz de permisos en [[Proyecto/4. Arquitectura vertical y contratos|contratos y permisos]]. No confiar en un `userId` o `role` enviado por el navegador.

### Guard común: identidad vigente desde la base

```ts
// src/shared/lib/permissions.ts (función pura, también comprobable con Vitest)
export type Role = "ADMIN" | "STAFF";
export function canAccess(role: Role, allowed: readonly Role[]) {
  return allowed.includes(role);
}
```

```ts
// src/shared/lib/access.ts
import "server-only";
import { auth } from "@/auth";
import { prisma } from "@/shared/lib/prisma";
import { ApiError } from "./api-error";
import { canAccess, type Role } from "./permissions";
export async function requireRoles(allowed: readonly Role[]) {
  const session = await auth();
  if (!session?.user.id) throw new ApiError(401, "Inicia sesión");
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { id: true, role: true, active: true },
  });
  if (!user || !user.active) throw new ApiError(401, "Sesión no válida");
  if (!canAccess(user.role, allowed)) throw new ApiError(403, "Sin permiso");
  return user;
}
```

Esto permite que desactivar una cuenta o cambiar su rol tenga efecto sin esperar a que expire el JWT. El ID de sesión identifica; la base decide los privilegios actuales.

### Cerrar las rutas que construimos localmente

Importar `requireRoles` en el controlador de eventos de la clase 6. Insertar `await requireRoles(["ADMIN"])` al principio de `postEvent`, y `await requireRoles(["ADMIN", "STAFF"])` al principio de `getEvents`. Repetir en PATCH y DELETE según la matriz.

El actor de una venta se obtiene del guard: `const actor = await requireRoles(["ADMIN", "STAFF"])`. Asignar `createdById: actor.id` en servidor. Para recursos que sean privados por usuario, filtrar también por propietario dentro de la consulta.

### Middleware/Proxy y vistas

En Next.js 16 la convención se llama `proxy.ts`. Puede servir para redirigir pronto, pero no lo necesitamos para la garantía de permisos: el guard debe permanecer en los endpoints. No afirmar que ocultar un botón protege una operación. Una API responde 401/403 JSON, no HTML de login como si fuera un resultado correcto.

Las operaciones por cookies también necesitan protección ante CSRF: en las rutas de mutación propias comprobar `Origin` contra el origen configurado y rechazar orígenes ajenos antes de ejecutar cambios. Auth.js gestiona su propio flujo; no copiar ese supuesto a nuestras APIs.

```ts
export function requireSameOrigin(request: Request) {
  const expected = process.env.APP_ORIGIN;
  if (!expected || request.headers.get("origin") !== new URL(expected).origin)
    throw new ApiError(403, "Origen no permitido");
}
```

Integrar esta función (con import de `ApiError`) en POST/PATCH/DELETE propios. Las pruebas con curl incluyen `Origin: http://localhost:3000`. Los clientes externos necesitarían un contrato de autenticación diferente.

### Composición de una operación protegida

Este controlador ilustra el orden completo sobre el servicio ya construido:

```ts
import { createEventSchema } from "../shared/event.schema";
import { createEvent } from "./event.service";
import { requireRoles } from "@/shared/lib/access";
import { requireSameOrigin } from "@/shared/lib/origin";
import { apiError } from "@/shared/lib/api-error";

export async function postEvent(request: Request) {
  try {
    await requireRoles(["ADMIN"]);
    requireSameOrigin(request);
    const input = createEventSchema.parse(await request.json());
    return Response.json(await createEvent(input), { status: 201 });
  } catch (error: unknown) { return apiError(error); }
}
```

El orden permite rechazar accesos sin privilegios antes de procesar un cuerpo potencialmente grande. La validación del esquema no sustituye el guard y el guard no reemplaza las reglas del servicio.

La función de origen debe vivir en `src/shared/lib/origin.ts` e importar `ApiError` de `./api-error`. Configura APP_ORIGIN con el origen real de la aplicación. Un origen incluye esquema, host y puerto; no incluye el path. `http://localhost:3000` y `http://localhost:3001` son distintos.

### Por qué aparece CSRF al usar cookies

El navegador puede adjuntar cookies automáticamente según las reglas configuradas. Una página ajena podría intentar provocar una escritura aprovechando una sesión del usuario. Comprobar el origen en nuestras mutaciones es una defensa explícita para este cliente web del mismo origen; no es una clave secreta ni autentica a herramientas externas.

Un cliente no navegador puede escribir una cabecera Origin, así que además siempre debe presentar sesión y permisos. Para integraciones externas se necesitaría otro contrato de autenticación. No abras la comprobación a cualquier origen para arreglar un error local de puerto.

XSS es otro problema: código no confiable ejecutado dentro de tu origen. Si ocurre, el origen puede parecer correcto. Evitar inyección de HTML y manejar salida no confiable sigue siendo necesario. La nota de [[Recursos/Conceptos/Sesiones cookies y seguridad web|seguridad web]] desarrolla la diferencia.

### Seguridad de campos y asignación de roles

Un endpoint de creación de personal puede aceptar nombre, correo y contraseña, pero no rol arbitrario. Si existe una operación de cambio de rol, debe ser administrativa y revisar reglas como no dejar el sistema sin cuentas administradoras activas. Añadir un enum al body no implementa esas decisiones.

Para los datos de la sesión, selecciona ID, rol y active. Para el JSON de un usuario, selecciona los campos públicos. Separar estas vistas reduce filtraciones y evita que la interfaz dependa de información que no necesita.

### Matriz de prueba, paso a paso

Repite la misma operación sin cookie, con STAFF, con ADMIN, con cuenta desactivada y con origen ajeno. La variante cambia una condición por vez para que puedas atribuir el resultado. Además intenta cambiar el actor dentro del body y comprueba que el servidor no lo usa.

Si un test solo confirma que el menú no muestra «Administración», todavía no verificó el backend. Debe existir una petición directa que obtenga 403 y una comprobación de base que confirme que el recurso no cambió.

## Práctica guiada

Intentar crear un evento sin sesión, con STAFF y con ADMIN. Verificar 401, 403 y 201.

## Tarea para casa

Aplicar guards y origen a todas las operaciones de tu módulo. Revisar el PR de otro equipo intentando saltarse su interfaz.

## Criterios de finalización

- [ ] Cada operación comprueba permisos en servidor.
- [ ] La identidad del actor proviene de la sesión.
- [ ] Se prueban peticiones directas y origen ajeno.

## Preguntas resueltas

**¿Comprobar Origin autentica al usuario?**

No. Es una defensa de origen para el navegador y se combina con sesión y permisos.

**¿Un layout protegido protege toda la API?**

No. Cada endpoint y lectura privada necesita su propia comprobación de acceso.

**¿Por qué consultar el rol vigente?**

Para que cambios de rol y desactivaciones tengan efecto aunque la cookie aún no haya expirado.

## Para profundizar

[Next.js: autenticación y autorización](https://nextjs.org/docs/app/guides/authentication) · [Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies).

## Conceptos clave de esta clase

- **Guard:** Función que rechaza accesos sin las condiciones de identidad o permiso requeridas.
- **RBAC:** Control de acceso basado en roles.
- **Actor:** Identidad que realiza una operación y que el servidor acredita.
- **Origen:** Esquema, host y puerto de una dirección web.
- **CSRF:** Acción provocada desde otro contexto aprovechando credenciales enviadas por el navegador.
- **XSS:** Ejecución de código no confiable dentro de una página u origen.

## Conexiones

[[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] →

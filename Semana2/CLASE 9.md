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

[[README|Inicio]] · [[Semana2/INDICE|Semana 2]] · ← [[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] →

> [!abstract] Objetivo
> Verificar identidad y permisos en cada operación del backend.

## Antes de empezar

Repasa [[Semana2/CLASE 8|Clase 8]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

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

## Práctica guiada

Intentar crear un evento sin sesión, con STAFF y con ADMIN. Verificar 401, 403 y 201.

## Tarea para casa

Aplicar guards y origen a todas las operaciones de tu módulo. Revisar el PR de otro equipo intentando saltarse su interfaz.

## Criterios de finalización

- [ ] Cada operación comprueba permisos en servidor.
- [ ] La identidad del actor proviene de la sesión.
- [ ] Se prueban peticiones directas y origen ajeno.

## Conexiones

[[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana2/INDICE|Semana 2]] · ← [[Semana2/CLASE 8|Clase 8]] · [[Semana2/CLASE 10|Clase 10]] →

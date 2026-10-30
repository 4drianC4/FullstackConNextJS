---
tipo: clase
clase: 8
semana: 2
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/2
---

# Clase 8 — Autenticación y sesiones

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 7|Clase 7]] · [[Semana2/CLASE 9|Clase 9]] →

> [!abstract] Objetivo
> Autenticar al personal sin persistir ni devolver contraseñas en texto plano.

## Antes de empezar

Repasa [[Semana2/CLASE 7|Clase 7]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Decisión del curso

No habrá registro público: el administrador crea cuentas del personal. Usamos credenciales, JWT gestionado por Auth.js y cookies de sesión; no implementamos nuestro propio JWT ni lo guardamos en localStorage.

Los apuntes usan la API de **Auth.js / NextAuth 5 beta**, no los ejemplos `withAuth` de v4. Ver [[Recursos/Stack y entorno|la advertencia de versión y el lockfile]]. Instalar una beta concreta revisada por el instructor y guardarla exacta; no cambiarla durante la edición.

```bash
npm install --save-exact next-auth@beta bcryptjs
npx auth secret
```

### Usuarios y contraseñas

El campo se llama siempre `passwordHash`. Al crear una cuenta autorizada, validar contraseña (8–72 bytes UTF-8 para este ejemplo bcrypt), aplicar `bcrypt.hash(password, 12)` y usar un `select` público en Prisma. El cliente nunca elige un rol de administrador mediante un registro abierto.

El seed inicial crea una cuenta administrativa con una contraseña leída de una variable local. No hay contraseñas por defecto en el código. Consultar [[Proyecto/6. Modelo de datos|seed del proyecto]].

### Configuración en src/auth.ts

```ts
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "@/shared/lib/prisma";
const loginSchema = z.object({
  email: z.email(),
  password: z.string().min(8).refine((s) => new TextEncoder().encode(s).length <= 72),
});
export const { handlers, auth, signIn, signOut } = NextAuth({
  session: { strategy: "jwt", maxAge: 8 * 60 * 60 },
  providers: [Credentials({
    credentials: { email: {}, password: {} },
    async authorize(raw) {
      const parsed = loginSchema.safeParse(raw);
      if (!parsed.success) return null;
      const user = await prisma.user.findUnique({ where: { email: parsed.data.email.toLowerCase() } });
      if (!user || !user.active) return null;
      if (!await bcrypt.compare(parsed.data.password, user.passwordHash)) return null;
      return { id: user.id, name: user.name, email: user.email };
    },
  })],
  callbacks: {
    jwt({ token, user }) { if (user) token.sub = user.id; return token; },
    session({ session, token }) {
      if (token.sub) session.user.id = token.sub;
      return session;
    },
  },
});
```

Crear `src/types/next-auth.d.ts` para el campo adicional:

```ts
import type { DefaultSession } from "next-auth";
declare module "next-auth" {
  interface Session {
    user: { id: string } & DefaultSession["user"];
  }
}
```

Y `src/app/api/auth/[...nextauth]/route.ts`:

```ts
import { handlers } from "@/auth";
export const { GET, POST } = handlers;
```

`AUTH_SECRET` permanece privado. Mantener los defaults seguros de cookies de la librería y HTTPS en producción. Hashing no es cifrado reversible. HttpOnly dificulta robar la cookie desde JS, pero no elimina XSS ni sustituye protección CSRF.

Antes de publicar: añadir limitación de intentos usando almacenamiento compartido o controles del proveedor de hosting, probar el bloqueo y no registrar credenciales. No basta un contador en memoria en un despliegue con varias instancias.

## Práctica guiada

Crear usuarios de prueba mediante seed y verificar credenciales con una prueba local del flujo de Auth.js. El formulario se construye en frontend.

## Tarea para casa

Integrar configuración y documentar sesión expirada, contraseña incorrecta y cuenta inactiva. Coordinar con los demás equipos el contrato de sesión.

## Criterios de finalización

- [ ] Solo se persiste el hash.
- [ ] La sesión no contiene passwordHash.
- [ ] No hay registro público ni secretos versionados.

## Conexiones

[[Semana2/CLASE 9|Clase 9]] · [[Proyecto/6. Modelo de datos|Usuarios de prueba]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana2/0 INDICE|Semana 2]] · ← [[Semana2/CLASE 7|Clase 7]] · [[Semana2/CLASE 9|Clase 9]] →

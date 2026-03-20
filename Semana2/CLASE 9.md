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
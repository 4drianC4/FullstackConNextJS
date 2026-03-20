# Día 10: Backend VII - Validaciones y Middleware

¡Llegamos al final de la Semana 2 y del desarrollo exclusivo del Backend! Ya tenemos base de datos, arquitectura limpia y seguridad. Pero nos falta proteger las "puertas internas" de nuestra aplicación.

¿Qué pasa si un usuario envía un formulario sin un correo válido? ¿O si intenta borrar un post sin haber iniciado sesión? Hoy resolveremos esto usando Zod para validar datos y Middleware para proteger nuestras rutas.

---

## 1. Validación de Datos con Zod

Nunca confíes en los datos que vienen del cliente (Frontend). Aunque pongas required en tus inputs de HTML, un usuario malintencionado puede enviar datos basura directamente a tu API usando herramientas como Postman.

En lugar de escribir decenas de if (!body.email || typeof body.email !== 'string'), usaremos Zod, una librería de declaración y validación de esquemas que se integra perfectamente con TypeScript.
### A. Definiendo un Esquema (Schema)

Zod nos permite definir la "forma" exacta que deben tener nuestros datos. Vamos a crear una carpeta src/schemas/ y ahí definiremos cómo debe lucir la petición para crear un usuario.
```TypeScript
// src/schemas/userSchema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2, "El nombre debe tener al menos 2 caracteres"),
  email: z.string().email("Debe ser un correo electrónico válido"),
  password: z.string().min(8, "La contraseña debe tener al menos 8 caracteres"),
  role: z.enum(["USER", "ADMIN"]).optional(), // Opcional, si no viene usamos el default
});
```

### B. Validando en el Controlador

Ahora, actualizamos el controlador que hicimos en el Día 7 para que valide el body antes de enviarlo al servicio.
```TypeScript

// src/controllers/userController.ts
import { NextRequest, NextResponse } from 'next/server';
import { createUserSchema } from '@/src/schemas/userSchema';
import * as userService from '@/src/services/userService';

export const handleCreateUser = async (req: NextRequest) => {
  try {
    const body = await req.json();
    
    // Zod parsea el body. Si los datos son inválidos, lanzará un error y caerá en el catch.
    const validatedData = createUserSchema.parse(body);
    
    // Si llegamos aquí, TypeScript sabe con 100% de seguridad que validatedData es correcto
    const newUser = await userService.createUser(validatedData);
    
    return NextResponse.json(newUser, { status: 201 });
    
  } catch (error: any) {
    // Si el error viene de Zod, le devolvemos al cliente qué campos fallaron
    if (error.name === 'ZodError') {
      return NextResponse.json({ error: error.issues }, { status: 400 });
    }
    return NextResponse.json({ error: 'Error interno del servidor' }, { status: 500 });
  }
};
```

---
## 2. Middleware: Los Guardias de Seguridad

Un Middleware es un bloque de código que se ejecuta antes de que una petición llegue a su destino final (tu Route Handler). Es el lugar perfecto para verificar si un usuario está autenticado.

En Next.js (App Router), el middleware se define en un archivo llamado middleware.ts en la raíz del proyecto (al mismo nivel que la carpeta app).
### Protegiendo Rutas con Auth.js (NextAuth)

Gracias a que instalamos Auth.js en el Día 9, proteger rutas enteras es increíblemente fácil.
```TypeScript

// middleware.ts
import { withAuth } from "next-auth/middleware";

// withAuth envuelve nuestro middleware y revisa el JWT de la cookie automáticamente
export default withAuth({
  pages: {
    signIn: '/login', // Si no están autenticados, los mandamos a esta ruta
  },
});

// Configuración de las rutas que queremos proteger
export const config = {
  // El matcher define en qué rutas se ejecutará este middleware
  matcher: [
    "/api/users/:path*", // Protegemos todos los endpoints de usuarios
    "/api/posts/:path*", // Protegemos los endpoints de posts
    "/dashboard/:path*", // También podemos proteger rutas del frontend (Vistas)
  ],
};
```
Con estas simples líneas, es imposible que alguien ejecute un método DELETE /api/users/1 si no tiene una sesión activa válida.
## 3. Manejo Global de Errores

A medida que tu API crece, no quieres repetir el mismo bloque try/catch de 20 líneas en todos lados. Es fundamental estandarizar cómo tu backend responde a los errores.

Una buena práctica en el controlador es delegar el formateo del error a una función de utilidad.
```TypeScript

// src/utils/errorHandler.ts
import { NextResponse } from 'next/server';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';

export const handleApiError = (error: unknown) => {
  // 1. Manejo de Errores de Validación (Zod)
  if (error instanceof ZodError) {
    const formattedErrors = error.issues.map(issue => ({
      field: issue.path.join('.'),
      message: issue.message
    }));
    return NextResponse.json({ success: false, errors: formattedErrors }, { status: 400 });
  }

  // 2. Manejo de Errores de Base de Datos (Prisma)
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    // P2002 es el código de Prisma para "violación de restricción única" (ej. email duplicado)
    if (error.code === 'P2002') {
      return NextResponse.json({ success: false, error: 'El registro ya existe.' }, { status: 409 });
    }
  }

  // 3. Errores Generales / Inesperados
  console.error('[API Error]:', error); // Para los logs del servidor
  return NextResponse.json({ success: false, error: 'Error interno del servidor.' }, { status: 500 });
};
```

Luego, en tus controladores, el código se vuelve mucho más limpio:
```TypeScript

// src/controllers/userController.ts
import { handleApiError } from '@/src/utils/errorHandler';

export const handleUpdateUser = async (req: NextRequest, params: { id: string }) => {
  try {
    const body = await req.json();
    const validatedData = updateUserSchema.parse(body); // Validamos
    const updatedUser = await userService.updateUser(params.id, validatedData); // Procesamos
    
    return NextResponse.json({ success: true, data: updatedUser }, { status: 200 });
  } catch (error) {
    // Manejo global estandarizado
    return handleApiError(error); 
  }
};
```
## 4. Review del Código Backend (Checklist)

Antes de pasar al Frontend en la Semana 3, asegurémonos de que nuestro Backend cumple con los estándares profesionales:

- [ ] Base de Datos: Tenemos un diagrama ERD claro y un esquema de Prisma que lo refleja. Las tablas tienen relaciones correctas (1:N, M:N).
- [ ] Arquitectura: Usamos un modelo MVC adaptado. Los Route Handlers son delgados, los Controladores manejan el HTTP, y los Servicios manejan la lógica de negocio y Prisma.
- [ ] Seguridad: Las contraseñas están hasheadas (Bcrypt). Usamos JWT seguros en Cookies HttpOnly a través de NextAuth.
- [ ] Robustez: Zod valida que no entre basura a la base de datos, y el Middleware asegura que no entren usuarios sin permiso. El manejo de errores es predecible y no expone detalles internos al cliente.

¡Nuestro Backend está listo para producción!
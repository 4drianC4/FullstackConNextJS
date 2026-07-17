# Día 7: Backend IV - Lógica de Negocio y Arquitectura (Vertical Slices)

¡Llegamos al Día 7! Ya tenemos nuestra base de datos diseñada (Día 3), conectada (Día 5) y modelada con Prisma (Día 6). Hoy vamos a empezar a interactuar con ella creando nuestros primeros Endpoints (rutas API).

A medida que una aplicación crece, escribir todo el código en un solo archivo o agruparlo por "tipo técnico" (todas las rutas juntas, todos los controladores juntos) se vuelve insostenible. Por eso, en este proyecto utilizaremos una arquitectura basada en **Características (Feature-Sliced Design)**.

## 1. Arquitectura por Módulos en Next.js (App Router)

En lugar del tradicional patrón MVC horizontal, dividiremos nuestra aplicación en "rebanadas verticales" (Features). Como se aprecia en la estructura del proyecto, cada módulo (por ejemplo, `users`) contiene todo lo necesario para funcionar de principio a fin: su propio frontend, backend y recursos compartidos.

Nuestra estructura se mapea de la siguiente manera:

Plaintext

```
src/
├── app/
│   └── api/
│       └── users/
│           └── route.ts               # Las "Puertas": Enrutamiento de Next.js
└── features/
    └── users/                         # El "Módulo": Todo lo relacionado a usuarios
        ├── backend/
        │   ├── controllers/           # Orquestan la petición (req/res) y validan
        │   ├── dto/                   # Data Transfer Objects (Tipos de datos esperados)
        │   ├── middlewares/           # Lógica de protección
        │   └── services/              # Lógica de negocio pesada (Prisma)
        ├── frontend/                  # Vistas y componentes UI
        └── shared/
            ├── schemas/               # Validaciones de Zod compartidas (Front y Back)
            └── types/                 # Interfaces TS compartidas
```

## 2. Separación de Responsabilidades y DTOs

Para tener un código limpio y escalable, cada capa tiene un único trabajo:

1. **Route Handlers (`app/api/...`)**: Interceptan el método HTTP (GET, POST) y lo delegan. No contienen lógica.
    
2. **DTOs y Schemas (`dto/` y `schemas/`)**: **(¡Nuevo concepto!)** Un DTO (Data Transfer Object) define la forma exacta de los datos que viajan entre el cliente y el servidor. Usamos Zod (`schemas/`) para validar que los datos sean correctos en tiempo de ejecución, y extraemos el tipo TypeScript (`dto/`) para usarlo en el código.
    
3. **Controladores (`controllers/`)**: Actúan como recepcionistas. Reciben la petición, usan Zod para validar el `body`, llaman al servicio y empaquetan la respuesta HTTP (ej. 201 Created).
    
4. **Servicios (`services/`)**: Aquí vive la verdadera lógica de negocio. No saben nada de HTTP. Reciben datos limpios (DTOs), ejecutan reglas de negocio, hablan con la base de datos (Prisma) y retornan resultados.
    

## 3. Implementación: Creando el Endpoint para Usuarios

Vamos a crear el flujo completo para registrar un usuario siguiendo nuestra arquitectura modular. Cada archivo cumple una función específica.

### Paso 1: El Schema y el DTO

Primero, definimos cómo deben lucir los datos para crear un usuario. Validamos con Zod y exportamos el tipo.

**src/features/users/shared/schemas/user.schema.ts**

``` Typescript
import { Role } from "@/generated/prisma/client";

import { z } from "zod";

  

const optionalNameSchema = z

.string()

.trim()

.min(1, "Name must contain at least 1 character")

.max(100, "Name must contain at most 100 characters")

.nullable()

.optional();

  

export const userIdSchema = z.object({

id: z.cuid("User id must be a valid cuid"),

});

  

export const userEmailSchema = z.object({

email: z.email("Email must be valid").transform((value) => value.toLowerCase()),

});

  

export const createUserSchema = z.object({

name: optionalNameSchema,

email: z.email("Email must be valid").transform((value) => value.toLowerCase()),

password: z.string().min(6, "Password must contain at least 6 characters"),

role: z.nativeEnum(Role).default(Role.CUSTOMER),

});

  

export const putUserSchema = z.object({

name: optionalNameSchema,

email: z.email("Email must be valid").transform((value) => value.toLowerCase()),

password: z.string().min(6, "Password must contain at least 6 characters"),

role: z.nativeEnum(Role),

});

  

export const patchUserSchema = z

.object({

name: optionalNameSchema,

email: z.email("Email must be valid").transform((value) => value.toLowerCase()).optional(),

password: z.string().min(6, "Password must contain at least 6 characters").optional(),

role: z.nativeEnum(Role).optional(),

})

.refine(

(value) =>

value.name !== undefined ||

value.email !== undefined ||

value.password !== undefined ||

value.role !== undefined,

{

message: "At least one field must be provided",

},

);
```

**`src/features/backend/dtos/create-user.dto.ts`**

```TypeScript
import type { z } from "zod";
import { createUserSchema } from "@/features/users/shared/schemas/user.schema";

// Extraemos el tipo de TypeScript directamente de la validación de Zod
export type CreateUserDto = z.infer<typeof createUserSchema>;
```

### Paso 2: El Servicio

Creamos la lógica pura que habla con la base de datos. Solo recibe el DTO validado.

**src/features/backend/services/create.ts**
``` TypeScript
import { prisma } from "@/shared/lib/prisma";
import type { CreateUserDto } from "@/features/users/backend/dto/create-user.dto";
import { toUserDto } from "@/features/users/backend/services/shared";

export async function createUserService(input: CreateUserDto) {
  const user = await prisma.user.create({
    data: {
      name: input.name?.trim() ? input.name.trim() : null,
      email: input.email,
      passwordHash: input.password, // En el futuro lo encriptaremos
      role: input.role,
    },
  });

  // Convertimos el modelo de base de datos a un formato seguro para el cliente
  return toUserDto(user);
}
```

### Paso 3: El Controlador

Maneja el formato web (Request/Response), valida los datos entrantes y maneja errores, delegando el trabajo duro al servicio.

**src/features/backend/controllers/create.ts**
``` TypeScript
import { createUserSchema } from "@/features/users/shared/schemas/user.schema";
import { createUserService } from "@/features/users/backend/services/create";
import { handleUsersControllerError } from "@/features/users/backend/controllers/shared";
import { ok } from "@/shared/lib/api-response";

export async function createUserController(request: Request) {
  try {
    const body = await request.json();
    // 1. Zod valida que el body cumpla con las reglas. Si falla, lanza un error.
    const payload = createUserSchema.parse(body);
    
    // 2. Delegar al servicio enviando el DTO seguro
    const user = await createUserService(payload);

    // 3. Retornar éxito (201)
    return ok(user, 201);
  } catch (error) {
    // Manejo centralizado de errores (Zod errors, Prisma errors, etc.)
    return handleUsersControllerError(error);
  }
}
```

### Paso 4: El Route Handler

Finalmente, conectamos nuestro controlador a la ruta de Next.js. El archivo queda extremadamente limpio.

**src/app/api/users/route.ts**

``` TypeScript
import { createUserController, getAllUsersController } from "@/features/users";

export async function GET() {
  return getAllUsersController();
}

export async function POST(request: Request) {
  return createUserController(request);
}
```

## 4. Prueba del Endpoint por Consola

Ahora que la arquitectura está completa, podemos probar que nuestro código funciona. Dado que aún no tenemos el formulario en el Frontend (Semana 3), simularemos una petición HTTP directamente desde la consola del navegador o terminal.

**Abre la consola de tu navegador (F12) o una terminal con Node.js y ejecuta este bloque:**

``` JavaScript
fetch('http://localhost:3000/api/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: "Juan Pérez",
    email: "juan@ejemplo.com",
    password: "password123",
    role: "CLIENTE"
  })
})
.then(response => response.json())
.then(data => console.log("Respuesta del servidor:", data))
.catch(error => console.error("Error:", error));
```

Si todo está correcto, deberías ver la respuesta de la API devolviendo el usuario recién creado con su ID (y sin exponer el hash de la contraseña, gracias a `toUserDto`).

## Resumen del Día 7

Hoy aprendimos que una **Arquitectura en Vertical Slices** permite aislar responsabilidades perfectamente:

- **Schemas y DTOs:** Garantizan que la información que entra a la app es válida y predecible.
    
- **Controladores:** Unifican cómo nuestra API responde al cliente y manejan los errores web.
    
- **Servicios:** Encapsulan la lógica de negocio y las consultas a Prisma, haciéndolos reutilizables.
    
- **Rutas:** Quedan únicamente como puntos de entrada limpios.
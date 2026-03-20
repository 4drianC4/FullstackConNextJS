# Día 7: Backend IV - Lógica de Negocio y Arquitectura

¡Llegamos al Día 7! Ya tenemos nuestra base de datos diseñada (Día 3), conectada (Día 5) y modelada con Prisma (Día 6). Hoy vamos a empezar a interactuar con ella creando nuestros primeros Endpoints (rutas API). Pero antes de escribir una sola línea de código, necesitamos hablar de **Arquitectura**.

A medida que una aplicación crece, escribir todo el código en un solo archivo se vuelve insostenible. Aquí es donde entra el patrón de diseño **MVC (Modelo-Vista-Controlador)** y la **Arquitectura en Capas**.

## 1. Adaptando MVC a Next.js (App Router)

Tradicionalmente en Node/Express, tendrías carpetas para `models/`, `views/`, `routes/` y un archivo `index.ts`. En un entorno moderno fullstack con Next.js y Prisma, esta arquitectura se mapea de la siguiente manera para mantener el código limpio y escalable:

* **Models (Modelos):** Ya no necesitamos una carpeta `models/`. Nuestro archivo `prisma/schema.prisma` y el cliente que genera Prisma asumen este rol. Ellos definen la estructura de los datos y cómo interactuar con ellos.
* **Views (Vistas):** En lugar de motores de plantillas tradicionales (como EJS o Pug), nuestras vistas serán los **Componentes de React** que construiremos en la Semana 3 (Frontend).
* **Routes (Rutas):** Next.js utiliza un sistema de enrutamiento basado en archivos (File-based routing). En lugar de un archivo `routes.js`, la estructura de carpetas dentro de `app/api/.../route.ts` define nuestros endpoints.
* **Controllers & Services (Controladores y Servicios):** ¡Estos los crearemos nosotros! Son el cerebro de nuestra aplicación.

### Nuestra Estructura de Carpetas Sugerida:

```text
mi-proyecto/
├── app/
│   └── api/
│       └── users/
│           └── route.ts       # 📍 Definición de Endpoints (Rutas)
├── prisma/
│   └── schema.prisma          # 📍 Modelos de Datos (Models)
└── src/
    ├── controllers/           # 📍 Controladores: Manejan req/res de Next.js
    └── services/              # 📍 Servicios: Lógica de negocio pesada y DB
```
## 2. Separación de Responsabilidades (La Regla de Oro)

Para tener una "Arquitectura Limpia", cada capa debe tener un único trabajo:

1. Route Handlers (route.ts): Su único trabajo es interceptar el método HTTP (GET, POST, etc.) y pasárselo al controlador adecuado. ¡Nada de lógica aquí!
2. Controladores (src/controllers): Actúan como recepcionistas. Extraen los datos de la petición (el body, los parámetros de la URL), se los pasan al Servicio, y luego empaquetan la respuesta del Servicio en un formato HTTP adecuado (con status codes como 200 o 400).
3. Servicios (src/services): Aquí vive la verdadera "Lógica de Negocio". Los servicios no saben nada de HTTP, de Next.js ni de status codes. Solo reciben datos de JavaScript, hacen cálculos, hablan con Prisma (base de datos) y devuelven un resultado o lanzan un error.

## 3. Implementación: Creando un Endpoint GET y POST

Vamos a crear el flujo completo para obtener y crear usuarios siguiendo nuestra arquitectura.
### Paso 1: El Servicio (src/services/userService.ts)

Creamos la lógica pura que habla con la base de datos.
```TypeScript

import prisma from '@/lib/prisma'; // Instancia creada en el Día 5

// Función para obtener todos los usuarios
export const getAllUsers = async () => {
  // Aquí podríamos agregar lógica extra: filtrado, paginación, etc.
  const users = await prisma.user.findMany({
    select: { id: true, name: true, email: true } // Evitamos enviar contraseñas
  });
  return users;
};

// Función para crear un usuario
export const createUser = async (data: { name: string; email: string }) => {
  // Lógica de negocio: Verificar si el usuario ya existe
  const existingUser = await prisma.user.findUnique({
    where: { email: data.email }
  });

  if (existingUser) {
    throw new Error('El correo electrónico ya está registrado.');
  }

  // Si no existe, lo creamos
  const newUser = await prisma.user.create({
    data: {
      name: data.name,
      email: data.email,
      password: 'contraseña_temporal' // En el Día 9 veremos encriptación
    }
  });

  return newUser;
};
```
### Paso 2: El Controlador (src/controllers/userController.ts)

El controlador maneja el formato web (Request/Response) pero delega el trabajo duro al servicio.
```TypeScript

import { NextRequest, NextResponse } from 'next/server';
import * as userService from '@/src/services/userService';

// Controlador para manejar la petición GET
export const handleGetUsers = async (req: NextRequest) => {
  try {
    const users = await userService.getAllUsers();
    return NextResponse.json(users, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: 'Error al obtener usuarios' }, { status: 500 });
  }
};

// Controlador para manejar la petición POST
export const handleCreateUser = async (req: NextRequest) => {
  try {
    // 1. Extraer datos del body de la petición
    const body = await req.json();
    
    // 2. Delegar al servicio
    const newUser = await userService.createUser(body);
    
    // 3. Devolver respuesta exitosa (201 Created)
    return NextResponse.json(newUser, { status: 201 });
    
  } catch (error: any) {
    // Manejo de errores de negocio (ej. "El correo ya existe")
    return NextResponse.json({ error: error.message }, { status: 400 });
  }
};
```
### Paso 3: El Route Handler (app/api/users/route.ts)

Finalmente, conectamos nuestro controlador a una ruta real de Next.js. El archivo es sumamente limpio y fácil de leer.
```TypeScript

import { NextRequest } from 'next/server';
import { handleGetUsers, handleCreateUser } from '@/src/controllers/userController';

// Endpoint: GET /api/users
export async function GET(request: NextRequest) {
  return handleGetUsers(request);
}

// Endpoint: POST /api/users
export async function POST(request: NextRequest) {
  return handleCreateUser(request);
}
```
Resumen del Día 7

Hoy aprendimos que la arquitectura no se trata del framework que uses, sino de cómo separas las responsabilidades.

    Al mantener nuestros Route Handlers delgados, es fácil ver qué endpoints existen.

    Al usar Controladores, unificamos cómo nuestra API responde al cliente.

    Al encapsular la lógica en Servicios, nuestro código de base de datos es reutilizable y fácil de testear.

¡Esta estructura nos salvará de muchos dolores de cabeza cuando la aplicación empiece a crecer masivamente en las siguientes semanas!
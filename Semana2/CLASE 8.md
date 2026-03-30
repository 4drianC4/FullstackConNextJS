# Día 8: Backend V - CRUD Completo y Operaciones Complejas

## 1. Completando el CRUD: Endpoints PUT y DELETE

Para actualizar y eliminar un recurso específico (como un usuario o un post), necesitamos saber su `id`. En Next.js (App Router), esto se logra mediante **Rutas Dinámicas**. En lugar de crear un archivo `route.ts` normal, lo colocamos dentro de una carpeta con corchetes: `app/api/users/[id]/route.ts`.

Siguiendo nuestra arquitectura del Día 7, vamos a implementar la actualización y eliminación de un usuario.

### Paso 1: Los Servicios (`src/services/userService.ts`)
Añadimos las funciones para actualizar y eliminar a nuestro servicio existente.

```Typescript
// Actualizar un usuario existente
export const updateUser = async (id: string, data: { name?: string; email?: string }) => {
  // Prisma actualizará solo los campos que vengan en 'data'
  const updatedUser = await prisma.user.update({
    where: { id: id },
    data: data,
  });
  return updatedUser;
};

// Eliminar un usuario
export const deleteUser = async (id: string) => {
  const deletedUser = await prisma.user.delete({
    where: { id: id },
  });
  return deletedUser;
};
```
### Paso 2: Los Controladores (src/controllers/userController.ts)

Creamos los manejadores para estas nuevas acciones. Observa cómo recibimos el id a través del objeto params que Next.js nos proporciona.
```TypeScript

import { NextRequest, NextResponse } from 'next/server';
import * as userService from '@/src/services/userService';

export const handleUpdateUser = async (req: NextRequest, params: { id: string }) => {
  try {
    const body = await req.json();
    const updatedUser = await userService.updateUser(params.id, body);
    return NextResponse.json(updatedUser, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: 'Error al actualizar el usuario' }, { status: 400 });
  }
};

export const handleDeleteUser = async (req: NextRequest, params: { id: string }) => {
  try {
    await userService.deleteUser(params.id);
    return NextResponse.json({ message: 'Usuario eliminado correctamente' }, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: 'Error al eliminar el usuario' }, { status: 400 });
  }
};
```
### Paso 3: El Route Handler (app/api/users/[id]/route.ts)

Conectamos la ruta dinámica a nuestros controladores.
```TypeScript

import { NextRequest } from 'next/server';
import { handleUpdateUser, handleDeleteUser } from '@/src/controllers/userController';

// Endpoint: PUT /api/users/:id
export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  return handleUpdateUser(request, params);
}

// Endpoint: DELETE /api/users/:id
export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  return handleDeleteUser(request, params);
}
```
## 2. Operaciones Complejas: Filtrado, Paginación y Relaciones

El mundo real requiere consultas más sofisticadas que simplemente traer todos los registros. Prisma hace que operaciones complejas de SQL se sientan como manipular objetos en JavaScript.
### Paginación y Filtrado

Si tuviéramos un millón de posts, un findMany() colapsaría nuestro servidor. Así es como implementamos paginación y ordenamiento en un servicio de Posts (src/services/postService.ts):
```TypeScript

export const getPublishedPosts = async (page: number = 1, limit: number = 10) => {
  const skip = (page - 1) * limit;

  const posts = await prisma.post.findMany({
    where: { published: true },         // Filtrado (solo publicados)
    orderBy: { createdAt: 'desc' },     // Ordenamiento (más recientes primero)
    skip: skip,                         // Paginación: cuántos saltar
    take: limit,                        // Paginación: cuántos tomar
    include: {                          // Traer relaciones unidas (JOIN)
      author: {
        select: { name: true, email: true } // Seleccionamos campos específicos del autor
      },
      categories: true
    }
  });

  return posts;
};
```
### Nested Writes (Escrituras Anidadas)

Prisma te permite insertar datos en múltiples tablas relacionadas con una sola consulta. Por ejemplo, crear un usuario y su perfil al mismo tiempo:
```TypeScript

const newUserWithProfile = await prisma.user.create({
  data: {
    email: 'juan@ejemplo.com',
    name: 'Juan Perez',
    password: 'secure_password',
    profile: {
      create: { // Prisma detecta la relación e inserta en la tabla Profiles
        bio: 'Desarrollador Fullstack aprendiendo Next.js',
      }
    }
  }
});
```
## 3. Manejo de Transacciones (Transactions)

¿Qué pasa si tienes una operación de lógica de negocio que requiere hacer tres cosas en la base de datos (por ejemplo, descontar dinero de una cuenta, sumarlo a otra, y guardar un registro)? Si el paso 1 tiene éxito pero el paso 2 falla (por una caída de red o un error), tus datos quedarán inconsistentes: el dinero desapareció.

Una Transacción asegura que un grupo de operaciones se ejecuten como una sola unidad: O todas tienen éxito (Commit), o todas fallan y la base de datos vuelve a su estado original (Rollback).
### Implementando Transacciones con Prisma

Prisma usa el método $transaction. Veamos un ejemplo en un servicio que transfiere un Post a otro Usuario y elimina el original de su cuenta:
```TypeScript

export const transferPostOwnership = async (postId: string, newAuthorId: string) => {
  // Envolvemos las operaciones en un array dentro de $transaction
  try {
    const result = await prisma.$transaction([
      // Operación 1: Actualizar el Post con el nuevo autor
      prisma.post.update({
        where: { id: postId },
        data: { authorId: newAuthorId }
      }),
      // Operación 2: Crear un registro de auditoría (asumiendo que tenemos esta tabla)
      prisma.auditLog.create({
        data: {
          action: 'POST_TRANSFERRED',
          targetId: postId,
        }
      })
    ]);

    // Si ambas tienen éxito, result contendrá un array con los resultados de ambas
    return result;
    
  } catch (error) {
    // Si *CUALQUIERA* de las dos falla, Prisma hace un rollback automático.
    // Nada se guarda en la base de datos.
    console.error("La transacción falló. Haciendo rollback...", error);
    throw new Error("No se pudo completar la transferencia");
  }
}; 
```
>[!IMPORTANT] Nota de Arquitectura: 
>Las transacciones son el ejemplo perfecto de por qué usamos Servicios. El controlador no debería saber nada sobre "commits" o "rollbacks", solo llama a transferPostOwnership() y espera un éxito o un error.

## Resumen del Día 8

¡Felicidades! Tienes un Backend funcional y robusto.
- Hemos dominado los métodos HTTP principales (GET, POST, PUT, DELETE) conectándolos a las rutas dinámicas de Next.js.
- Integramos la lógica de Prisma para hacer JOINs (con include) e inserts complejos (Nested Writes).
- Aprendimos a garantizar la integridad de nuestra base de datos agrupando operaciones críticas con Transacciones.
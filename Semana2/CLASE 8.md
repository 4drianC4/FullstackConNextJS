# Día 8: Backend V - CRUD Completo y Operaciones Complejas

## 1. Completando el CRUD: Endpoints PUT y DELETE

Para actualizar y eliminar un recurso específico (como un usuario o un post), necesitamos saber su `id`. En Next.js (App Router), esto se logra mediante **Rutas Dinámicas**. En lugar de crear un archivo `route.ts` normal, lo colocamos dentro de una carpeta con corchetes: `app/api/users/[id]/route.ts`.

Siguiendo nuestra arquitectura del Día 7, vamos a implementar la actualización y eliminación de un usuario.

### Paso 1: Los Servicios (`src/services/userService.ts`)
Añadimos las funciones para actualizar y eliminar a nuestro servicio existente.

```typescript
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

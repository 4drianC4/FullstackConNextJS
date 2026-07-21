# Día 8: Backend V - CRUD Completo y Operaciones Complejas

Ayer sentamos las bases de nuestra arquitectura modular construyendo los métodos para leer (GET) y crear (POST) registros. Hoy vamos a completar nuestro CRUD y a enfrentarnos al mundo real: paginación, relaciones y transacciones seguras.

## 1. Completando el CRUD: Endpoints PUT y DELETE

Para actualizar y eliminar un recurso específico, necesitamos saber su `id`. En Next.js (App Router), esto se logra mediante **Rutas Dinámicas**. En lugar de crear un archivo `route.ts` normal, lo colocamos dentro de una carpeta con corchetes: `app/api/users/[id]/route.ts`.

Siguiendo la estructura de la carpeta `features/users` que vimos en el Día 7, vamos a implementar la actualización y eliminación de un usuario paso a paso.

### Paso 1: Schemas y DTOs

Para actualizar, no siempre recibimos todos los campos, por lo que creamos un schema donde los campos son opcionales. Además, necesitamos validar que el `id` que viaja en la URL sea un identificador válido (por ejemplo, un UUID o un CUID).

**`src/features/users/shared/schemas/user.schema.ts`**
```Typescript
import { z } from "zod";

// Schema para actualizar (todos los campos opcionales)
export const updateUserSchema = z.object({
  name: z.string().min(2).optional(),
  email: z.string().email().optional(),
  role: z.string().optional(),
});

// Schema para validar el ID de la URL
export const userIdSchema = z.object({
  id: z.string().uuid("Formato de ID inválido"),
});
```
**`src/features/users/backend/dto/put-user.dto.ts` y `user-id.dto.ts`**
```Typescript
import type { z } from "zod";
import { updateUserSchema, userIdSchema } from "@/features/users/shared/schemas/user.schema";

export type PutUserDto = z.infer<typeof updateUserSchema>;
export type UserIdDto = z.infer<typeof userIdSchema>;
```
### Paso 2: Los Servicios

Añadimos las funciones a nuestra "cocina". Estos servicios solo reciben datos limpios y se comunican con Prisma.

**`src/features/users/backend/services/put.ts`**

```TypeScript
import { prisma } from "@/shared/lib/prisma";
import type { PutUserDto } from "../dto/put-user.dto";
import { toUserDto } from "./shared";

export const updateUserService = async (id: string, data: PutUserDto) => {
  // Prisma actualizará solo los campos que vengan definidos en 'data'
  const updatedUser = await prisma.user.update({
    where: { id },
    data,
  });
  return toUserDto(updatedUser);
};
```
**`src/features/users/backend/services/delete.ts`**
```Typescript
import { prisma } from "@/shared/lib/prisma";

export const deleteUserService = async (id: string) => {
  await prisma.user.delete({
    where: { id },
  });
  return true; 
};
```
### Paso 3: Los Controladores

Creamos los manejadores. Observa cómo validamos no solo el `body` (para el PUT), sino también el parámetro `id` de la URL antes de tocar el servicio.

**`src/features/users/backend/controllers/put.ts`**
```Typescript

import { updateUserSchema, userIdSchema } from "@/features/users/shared/schemas/user.schema";
import { updateUserService } from "../services/put";
import { handleUsersControllerError } from "./shared";
import { ok } from "@/shared/lib/api-response";

export async function putUserController(request: Request, params: { id: string }) {
  try {
    const { id } = userIdSchema.parse(params); // Validamos el ID
    const body = await request.json();
    const payload = updateUserSchema.parse(body); // Validamos el Body

    const updatedUser = await updateUserService(id, payload);
    return ok(updatedUser, 200);
  } catch (error) {
    return handleUsersControllerError(error);
  }
}
```

**`src/features/users/backend/controllers/delete.ts`**
```Typescript

// Importaciones similares...
export async function deleteUserController(request: Request, params: { id: string }) {
  try {
    const { id } = userIdSchema.parse(params);
    await deleteUserService(id);
    return ok({ message: 'Usuario eliminado' }, 200);
  } catch (error) {
    return handleUsersControllerError(error);
  }
}
```

### Paso 4: El Route Handler

Conectamos la ruta dinámica a nuestros controladores. La limpieza de este archivo demuestra el poder de esta arquitectura.

**`src/app/api/users/[id]/route.ts`**
```Typescript

import { putUserController, deleteUserController } from '@/features/users';

export async function PUT(request: Request, { params }: { params: { id: string } }) {
  return putUserController(request, params);
}

export async function DELETE(request: Request, { params }: { params: { id: string } }) {
  return deleteUserController(request, params);
}
```

## 2. Operaciones Complejas: Filtrado, Paginación y Relaciones

El mundo real requiere consultas más sofisticadas que simplemente traer todos los registros. Prisma hace que operaciones complejas de SQL se sientan como manipular objetos en JavaScript.

### Paginación y Filtrado (Ejemplo: Módulo 4 - Catálogo Público)

Si tuviéramos diez mil productos, un `findMany()` colapsaría nuestro servidor y el navegador del cliente. Así es como implementamos paginación y ordenamiento en un servicio de Productos:

**`src/features/catalog/backend/services/get-public-products.ts`**
```Typescript

export const getActiveProductsService = async (page: number = 1, limit: number = 10) => {
  const skip = (page - 1) * limit;

  const products = await prisma.product.findMany({
    where: { isActive: true, stock: { gt: 0 } }, // Filtrado: Solo activos y con stock > 0
    orderBy: { createdAt: 'desc' },              // Ordenamiento: Novedades primero
    skip: skip,                                  // Paginación: Cuántos saltar
    take: limit,                                 // Paginación: Cuántos tomar
    include: {                                   // JOIN: Traer datos de tablas relacionadas
      category: {
        select: { name: true }                   // Solo queremos el nombre de la categoría
      }
    }
  });

  return products;
};
```

### Escrituras Anidadas (Nested Writes)

Prisma te permite insertar datos en múltiples tablas relacionadas con una sola consulta. Por ejemplo, si un administrador crea un Producto y, al mismo tiempo, quiere registrar la entrada inicial de inventario (Módulo 2 y 3):
```Typescript

const newProductWithStock = await prisma.product.create({
  data: {
    name: 'Laptop Gamer',
    price: 1500,
    sku: 'LAP-123',
    inventoryLogs: {
      create: { // Prisma detecta la relación e inserta en la tabla InventoryLog automáticamente
        quantity: 50,
        type: 'ENTRADA_INICIAL',
      }
    }
  }
});
```

## 3. Manejo de Transacciones (Transactions)

¿Qué pasa si tienes una operación crítica que requiere alterar dos tablas? Por ejemplo (Módulo 6), marcar una Orden de Compra como "PAGADA" y descontar las unidades del Inventario.

Si el Paso 1 tiene éxito, pero el Paso 2 falla (por error de red o porque alguien más compró la última unidad un segundo antes), tus datos quedarán inconsistentes: cobraste un producto que ya no tienes.

Una **Transacción** asegura que un grupo de operaciones se ejecuten como una sola unidad: O todas tienen éxito (_Commit_), o todas fallan y la base de datos vuelve a su estado original (_Rollback_).

### Implementando Transacciones con Prisma

Prisma usa el método `$transaction`. Veamos cómo se implementa en un servicio de Órdenes:

**`src/features/orders/backend/services/confirm-order.ts`**
```Typescript

export const confirmOrderPaymentService = async (orderId: string, productId: string, quantityToDeduct: number) => {
  try {
    // Envolvemos las operaciones en un array dentro de $transaction
    const result = await prisma.$transaction([
      
      // Operación 1: Cambiar el estado de la orden
      prisma.order.update({
        where: { id: orderId },
        data: { status: 'PAGADO' }
      }),
      
      // Operación 2: Descontar el stock real del producto
      prisma.product.update({
        where: { id: productId },
        data: { 
          stock: { decrement: quantityToDeduct } 
        }
      })
      
    ]);

    // Si ambas tienen éxito, result contiene los datos actualizados
    return result;
    
  } catch (error) {
    // Si *CUALQUIERA* de las dos falla, Prisma hace un rollback automático.
    // Nada se guarda en la base de datos y lanzamos el error al controlador.
    throw new Error("Transacción fallida: No se pudo procesar la orden y el stock.");
  }
};
```

> **Nota de Arquitectura:** Las transacciones son el ejemplo perfecto de por qué usamos Servicios. El controlador no sabe nada sobre "commits" o "rollbacks", solo llama a `confirmOrderPaymentService()` y espera un resultado o atrapa un error.

## Resumen del Día 8

¡Felicidades! Ahora tienes las herramientas para construir un Backend robusto de grado de producción.

1. Hemos dominado los métodos HTTP (GET, POST, PUT, DELETE) gestionando parámetros dinámicos y validándolos con Zod.
    
2. Integramos la lógica de Prisma para hacer JOINs (con `include`), paginación eficiente, e inserts complejos (_Nested Writes_).
    
3. Aprendimos a blindar la integridad del E-commerce utilizando Transacciones para flujos críticos como el cobro y manejo de stock.
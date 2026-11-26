---
tipo: clase
clase: 4
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 4 — Modelado, Prisma y datos de prueba

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 3|Clase 3]] · [[Semana1/CLASE 5|Clase 5]] →

> [!abstract] Objetivo
> Definir el modelo común y consultar PostgreSQL mediante Prisma 7.

## Antes de empezar

Repasa [[Semana1/CLASE 3|Clase 3]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Del problema del negocio a las entidades

Modelar consiste en decidir qué hechos necesita recordar el sistema y cómo se relacionan. No comenzamos copiando cada campo de un formulario: el formulario es una vista; el modelo debe sostener varios recorridos. Un evento puede existir antes de emitir entradas, y cada entrada debe seguir apuntando al mismo evento aunque este cambie de nombre.

Una entidad tiene identidad y atributos. `Event` contiene nombre, fecha, capacidad y estado. `Admission` contiene titular e ingreso, además de la referencia al evento. Dos eventos pueden compartir nombre y ser distintos; por eso el nombre no sirve como identidad estable.

### Claves, relaciones y restricciones

La **clave primaria** identifica una fila. Una **clave foránea** referencia la identidad de otra y permite impedir referencias inexistentes. En `Admission.eventId`, el valor señala al evento real; no reemplazamos esa relación con el nombre escrito a mano.

Una relación 1:N permite que un evento tenga varias entradas y que cada entrada pertenezca a un evento. Una relación N:M suele requerir una entidad intermedia. `BarSaleItem` conecta ventas y bebidas, pero también recuerda cantidad y precio histórico; no es solo una tabla de IDs.

Una restricción única evita duplicados según una regla elegida. `User.email` es único; `Reservation` tiene una unicidad compuesta por evento y mesa. La mesa puede reservarse en otros eventos, pero no dos veces para el mismo. Un índice ayuda a localizar filas; una restricción única además garantiza una propiedad de los datos.

### Normalizar sin perder historia

Guardar el nombre de la categoría en cada bebida provocaría actualizaciones repetidas al renombrarla. Una FK permite conservar una fuente común. Sin embargo, copiar el precio de una bebida a una línea de venta es deliberado: queremos saber cuánto costó al venderla, aunque hoy el catálogo diga otra cosa.

La normalización reduce duplicaciones inconsistentes; no prohíbe guardar instantáneas con significado histórico. La pregunta útil es «¿este dato debe seguir al valor actual o recordar lo que ocurrió?». En una venta, el precio histórico debe permanecer.

### Apoyo visual: tablas y relaciones

![[SQL VS NOSQL.excalidraw]]

[[SQL VS NOSQL.excalidraw|Abrir el dibujo SQL/NoSQL]] · [[Recursos/Mapa de dibujos Excalidraw|Ver todos los dibujos]].

El ejemplo utiliza estudiantes y cursos. Reconoce las entidades, la clave que identifica un curso y la referencia que conserva cada estudiante. La relación 1:N significa que un curso puede tener varios estudiantes y cada estudiante del ejemplo referencia un curso. Para la discoteca, traslada esa idea a un evento con varias entradas.

Aunque el archivo se llama SQL VS NOSQL, el contenido actual ilustra principalmente tablas y una relación. Una base relacional organiza filas con un esquema y permite restricciones entre entidades; NoSQL agrupa modelos distintos, como documentos, clave-valor o grafos. No significa «sin estructura» ni «sin reglas», y no convierte automáticamente una opción en más rápida para todo.

Elegimos PostgreSQL porque necesitamos relaciones e integridad entre eventos, entradas, ventas y reservas. El dibujo de estudiantes ayuda a entender el concepto; los nombres y campos vigentes del proyecto siguen estando en [[Proyecto/6. Modelo de datos|Modelo de datos]].

### Qué aporta un ORM y qué sigue siendo SQL

Un ORM mapea modelos y operaciones de código a la base. Prisma genera un cliente que conoce los campos y relaciones del esquema. Eso permite detectar errores de nombres y construir consultas sin escribir SQL en cada servicio. No convierte automáticamente cualquier acceso en seguro: aún necesitas permisos, transacciones y validación.

Una consulta SQL parametrizada también puede ser correcta y segura. El problema no es escribir SQL, sino concatenar valores no confiables o desconocer las garantías de la base. Aquí utilizamos Prisma para concentrarnos en reglas y contratos compartidos.

### Diseñar antes de programar

Identificar entidades, PK, FK, relaciones 1:N, restricciones únicas e índices. SQL no es inferior a un ORM: Prisma aporta consultas tipadas, pero seguimos necesitando entender integridad y transacciones. Un UUID no sustituye un control de acceso.

Leer [[Proyecto/6. Modelo de datos|el esquema común completo]]. Todos usan el mismo modelo. Propón cambios mediante PR, sincroniza el historial integrado y acuerda cualquier migración compartida antes de generarla para evitar historiales incompatibles.

### Instalar y configurar

Seguir [[Recursos/Stack y entorno|la familia de versiones del curso]]; Prisma CLI, cliente y adaptador deben compartir versión exacta en el lockfile de la aplicación.

```bash
npm install --save-exact @prisma/client@7 @prisma/adapter-pg@7 pg dotenv
npm install -D --save-exact prisma@7 tsx @types/pg
```

`prisma/schema.prisma` comienza con:

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}
datasource db {
  provider = "postgresql"
}
```

En Prisma 7 la URL va en `prisma.config.ts`:

```ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations", seed: "tsx prisma/seed.ts" },
  datasource: { url: env("DATABASE_URL") },
});
```

Completar con los modelos de la nota del proyecto. Después:

```bash
npx prisma migrate dev --name initial
npx prisma generate
npx prisma db seed
```

El seed se ejecuta explícitamente. `migrate dev` es para desarrollo; en producción se aplican migraciones revisadas con `migrate deploy`.

### Cliente compartido

Crear `src/shared/lib/prisma.ts`:

```ts
import "server-only";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@/generated/prisma/client";
const connectionString = process.env.DATABASE_URL;
if (!connectionString) throw new Error("Falta DATABASE_URL");
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  adapter: new PrismaPg({ connectionString }),
});
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

Reutiliza el cliente durante las recargas de desarrollo. No elimina la necesidad de controlar el pool en producción. Ver la receta de seed en el modelo común.

### Tres piezas que no deben confundirse

`schema.prisma` describe modelos y generación del cliente. Las migraciones son archivos versionados que cambian la estructura real de la base. El cliente generado es el código que permite consultar esos modelos desde TypeScript. Editar uno no actualiza mágicamente los otros dos.

Cuando añades un campo, sigue este recorrido: decide la regla, cambia el esquema, crea la migración en desarrollo, revisa el SQL, aplica y genera el cliente. Después actualiza los servicios y contratos que dependen del campo. Un error de TypeScript tras migrar puede indicar que falta generar o que el código todavía usa el contrato antiguo.

`migrate dev` ayuda a crear y aplicar migraciones en una base de desarrollo. `migrate deploy` aplica las pendientes en un entorno de entrega; no debe inventar nuevas migraciones en producción. `generate` no crea las tablas. `db seed` agrega datos de prueba, no define la estructura.

### Leer el cliente y una consulta

```ts
const drinks = await prisma.drink.findMany({
  where: { available: true },
  select: { id: true, name: true, priceCents: true },
  orderBy: { name: "asc" },
  take: 20,
});
```

`where` filtra filas; `select` controla columnas; `orderBy` establece orden; `take` limita cantidad. La combinación devuelve un listado público reducido de bebidas disponibles. No trae relaciones o campos extra por el simple hecho de existir en el modelo.

Usar `include` solicita relaciones, por ejemplo categoría, pero debe decidirse según la pantalla o servicio. Traer todas las relaciones en cada consulta aumenta trabajo y acopla consumidores a una estructura que quizá no necesitan.

### Relaciones en Prisma: 1:N, 1:1 y N:M

Antes vimos las relaciones como idea; ahora toca escribirlas en `schema.prisma` y consultarlas. Todas se construyen con las mismas tres piezas:

| Pieza | Ejemplo en `Admission` | ¿Existe en la base? |
| --- | --- | --- |
| Campo escalar FK | `eventId String` | Sí, es la columna con la clave foránea |
| Campo de relación | `event Event @relation(fields: [eventId], references: [id])` | No, solo existe en el cliente de Prisma |
| Relación inversa | `admissions Admission[]` en `Event` | No, solo existe en el cliente de Prisma |

`fields` indica qué columna de **este** modelo guarda la referencia; `references` indica a qué campo del **otro** modelo apunta (normalmente su `@id`). El lado que tiene `@relation(fields: …)` es el que guarda la FK. La relación inversa es obligatoria: si falta, `prisma format` la añade y `prisma validate` falla. `onDelete` decide qué pasa al borrar la fila referenciada; en el proyecto usamos `Restrict` para que no se pueda borrar un evento que ya tiene entradas.

#### Uno a muchos (1:N): un evento, muchas entradas

Es la relación más común. El lado «muchos» guarda la FK y el lado «uno» tiene una lista:

```prisma
model Event {
  id         String      @id @default(uuid())
  name       String
  admissions Admission[]          // lado "uno": lista, sin columna
}

model Admission {
  id      String @id @default(uuid())
  eventId String                  // columna FK
  event   Event  @relation(fields: [eventId], references: [id], onDelete: Restrict)
  @@index([eventId])              // PostgreSQL no indexa las FK automáticamente
}
```

En el modelo común siguen este patrón `Category → Drink`, `User → BarSale`, `Event → Reservation` y `ClubTable → Reservation`.

Consultas habituales:

```ts
// Crear una entrada conectándola a un evento existente
await prisma.admission.create({
  data: { holderName: "Ana", event: { connect: { id: eventId } } },
  // equivalente: data: { holderName: "Ana", eventId }
});

// Leer un evento con sus entradas (solo las columnas necesarias)
const event = await prisma.event.findUnique({
  where: { id: eventId },
  include: { admissions: { select: { id: true, holderName: true } } },
});

// Contar sin traer las filas
const withCount = await prisma.event.findMany({
  select: { id: true, name: true, _count: { select: { admissions: true } } },
});

// Filtrar por la relación: eventos con al menos una entrada sin ingresar
const pending = await prisma.event.findMany({
  where: { admissions: { some: { checkedInAt: null } } },
});
```

En listas se filtra con `some`, `every` y `none`; en una relación singular (`admission.event`) se filtra con `is` / `isNot` o directamente con sus campos.

#### Uno a uno (1:1): la FK además es única

Una relación 1:1 es una 1:N donde la FK lleva `@unique`: así ninguna otra fila puede apuntar al mismo registro. El modelo común **no** tiene ninguna 1:1; el siguiente ejemplo es solo ilustrativo y no debe añadirse sin acordarlo por PR:

```prisma
model User {
  id      String        @id @default(uuid())
  profile StaffProfile?           // opcional: un usuario puede no tener perfil
}

model StaffProfile {
  id     String  @id @default(uuid())
  userId String  @unique          // @unique convierte la 1:N en 1:1
  user   User    @relation(fields: [userId], references: [id], onDelete: Restrict)
  phone  String?
}
```

El lado sin FK se declara con `?` (`StaffProfile?`), nunca como lista. ¿Dónde va la FK? En la entidad que depende de la otra: el perfil no tiene sentido sin usuario, pero el usuario sí existe sin perfil.

```ts
// Crear el usuario y su perfil en una sola operación (escritura anidada)
await prisma.user.create({
  data: { name: "Luis", email: "luis@example.com", passwordHash, profile: { create: { phone: "600000000" } } },
});

// Leer el usuario con su perfil (puede venir null)
const user = await prisma.user.findUnique({ where: { id }, include: { profile: true } });
```

Antes de crear una 1:1 pregúntate si esos campos podrían ir en la misma tabla. Separarlos tiene sentido cuando son opcionales, sensibles o los gestiona otro módulo.

#### Muchos a muchos (N:M): implícita o explícita

Prisma admite dos formas.

**Implícita.** Ambos lados tienen una lista y Prisma crea y gestiona por su cuenta una tabla oculta (`_DrinkToTag`) con solo dos IDs:

```prisma
model Drink {
  id   String @id @default(uuid())
  tags Tag[]
}
model Tag {
  id     String  @id @default(uuid())
  drinks Drink[]
}
```

```ts
await prisma.drink.update({
  where: { id: drinkId },
  data: { tags: { connect: [{ id: tagA }, { id: tagB }], disconnect: [{ id: tagC }] } },
});
```

Es cómoda, pero la tabla intermedia no puede guardar ningún dato propio.

**Explícita.** Tú declaras el modelo intermedio con dos relaciones 1:N. Es la que usa el proyecto: `BarSaleItem` une `BarSale` y `Drink` y además recuerda `quantity` y `unitPriceCents`, que una tabla implícita no podría guardar.

```prisma
model BarSale {
  id    String        @id @default(uuid())
  items BarSaleItem[]
}

model Drink {
  id        String        @id @default(uuid())
  saleItems BarSaleItem[]
}

model BarSaleItem {
  id             String  @id @default(uuid())
  saleId         String
  sale           BarSale @relation(fields: [saleId], references: [id], onDelete: Restrict)
  drinkId        String
  drink          Drink   @relation(fields: [drinkId], references: [id], onDelete: Restrict)
  quantity       Int
  unitPriceCents Int     // copia histórica del precio
}
```

`Reservation` es otra N:M explícita entre `Event` y `ClubTable`. Su `@@unique([eventId, tableId])` impide reservar la misma mesa dos veces para el mismo evento. Si un par no debe repetirse nunca, puedes usar `@@unique([a, b])` o hacerlo clave primaria compuesta con `@@id([a, b])`.

```ts
// Crear una venta con sus líneas en una sola escritura anidada
await prisma.barSale.create({
  data: {
    requestKey, requestHash, totalCents,
    createdBy: { connect: { id: userId } },
    items: {
      create: [
        { quantity: 2, unitPriceCents: 1000, drink: { connect: { id: waterId } } },
        { quantity: 1, unitPriceCents: 2500, drink: { connect: { id: beerId } } },
      ],
    },
  },
});

// Leer una venta con sus líneas y el nombre de cada bebida
const sale = await prisma.barSale.findUnique({
  where: { id: saleId },
  include: { items: { include: { drink: { select: { name: true } } } } },
});
```

En una N:M explícita navegas en dos saltos (`sale → items → drink`). Es el precio de poder guardar datos en la relación. Las reglas reales de una venta (idempotencia, precio leído del catálogo, transacción) se trabajan en [[Semana2/CLASE 7|Clase 7]]; aquí solo importa la forma de la relación.

**¿Cuál elegir?** Si la relación es o puede llegar a ser un hecho con datos propios (cantidad, fecha, precio, quién la creó), usa la explícita. Pasar de implícita a explícita más adelante exige migrar datos.

#### Dos relaciones hacia el mismo modelo

Si un modelo apunta dos veces al mismo (por ejemplo, quién creó y quién anuló una venta), Prisma no sabe emparejar cada campo con su inversa. Dales nombre en los dos lados:

```prisma
model BarSale {
  createdById  String
  createdBy    User    @relation("SaleCreatedBy", fields: [createdById], references: [id])
  voidedById   String?
  voidedBy     User?   @relation("SaleVoidedBy", fields: [voidedById], references: [id])
}
model User {
  salesCreated BarSale[] @relation("SaleCreatedBy")
  salesVoided  BarSale[] @relation("SaleVoidedBy")
}
```

(Ejemplo ilustrativo: el modelo común solo tiene `createdBy`.)

#### Errores frecuentes

- Olvidar la relación inversa → `prisma validate` falla; `npx prisma format` la añade.
- Declarar la 1:1 sin `@unique` en la FK → `prisma validate` falla, porque el lado singular (`StaffProfile?`) exige una FK única.
- Creer que `event` o `admissions` son columnas → solo existen en el cliente; la columna es `eventId`.
- Usar `include` en todo → trae filas que nadie usa. Prefiere `select` y `_count` cuando basten.
- Elegir N:M implícita y descubrir después que había que guardar cantidad o precio.

### Configuración y conexiones

Prisma 7 utiliza el adaptador `pg` en este proyecto. La configuración de CLI carga la URL para operaciones como migrar; el módulo de cliente obtiene la URL al ejecutarse la aplicación. El script seed tiene su propio cliente porque no se ejecuta dentro del entorno de servidor de Next.js.

La reutilización del cliente durante hot reload evita crear una instancia nueva por cada edición. No significa una única conexión universal para todos los despliegues: cada proceso puede tener un pool y varias instancias pueden multiplicar conexiones. En hosting revisaremos los límites y el endpoint indicado por el proveedor.

### Seed, fixtures y una base reconstruible

Un seed prepara ejemplos: una cuenta, un evento, una bebida y una mesa que otros módulos pueden usar. Los fixtures son datos controlados para una práctica o prueba. Ninguno debe depender de información real de clientes ni de contraseñas escritas en el repositorio.

El seed utiliza IDs o claves conocidas para no duplicar registros al ejecutarlo otra vez. `upsert` busca por clave única y decide entre crear o actualizar. El ejemplo conserva contraseñas existentes: repetirlo no debe cambiar de forma silenciosa el acceso de alguien.

Antes de integrar una migración, comprueba que un compañero puede reconstruir la base con el historial. No arregles tu entorno editando a mano tablas que luego nadie sabrá reproducir. Si cambias una migración ya aplicada, las copias del equipo dejan de compartir la misma historia.

### Caso desarrollado: una categoría cambia de nombre

La categoría «Bebidas sin alcohol» tiene diez bebidas. Si guardaste el nombre de categoría como texto repetido en cada fila, renombrarla exige cambiar diez datos y evitar que alguno quede distinto. Si guardaste categoryId, cambias una fila de Category y las bebidas siguen referenciando la misma identidad.

Ahora imagina que vendiste un agua por 1000 centavos y después subiste el precio a 1200. En este caso no quieres que la venta histórica cambie. Por eso BarSaleItem conserva unitPriceCents: es una copia intencional del hecho de venta, no un descuido de normalización.

La diferencia se decide por significado. El nombre actual de categoría es una referencia viva; el precio aplicado pertenece a un momento. Un modelo bien razonado no sigue una regla ciega de «nunca duplicar» ni «copiar siempre para no hacer joins».

Comprueba las dos situaciones: renombra una categoría y observa el catálogo; después cambia un precio y observa una venta anterior. Cada resultado esperado define qué dato debe consultarse y cuál debe conservarse.

Antes de modificar el esquema, identifica qué consulta o recorrido lo necesita. Añadir campos porque «tal vez sirvan» aumenta migraciones y contratos sin una función demostrable. El modelo común puede ampliarse, pero cada cambio debe explicar qué regla o comportamiento nuevo sostiene.

## Práctica guiada

Generar la migración inicial y listar bebidas con Prisma Studio o un script de servidor.

## Tarea para casa

Crear fixtures de tu funcionalidad, con IDs conocidos y relaciones válidas. Revisar con otro equipo el contrato.

## Criterios de finalización

- [ ] El esquema valida y el cliente genera.
- [ ] La base se reconstruye con migraciones y seed.
- [ ] No se guardan contraseñas en texto plano.

## Preguntas resueltas

**¿Generate crea las tablas?**

No. Genera el cliente de código. Las migraciones cambian la estructura persistida.

**¿Por qué copiar el precio a la venta?**

Porque representa un hecho histórico, no el precio actual del catálogo.

**¿Puede cada equipo editar la misma migración?**

No conviene alterar un cambio ya aplicado. Coordina el esquema y crea cambios nuevos sobre el historial integrado.

**¿Qué diferencia hay en Prisma entre una 1:N y una 1:1?**

Solo el `@unique` en la FK y que el lado inverso es `Modelo?` en vez de `Modelo[]`.

**¿Por qué `BarSaleItem` no es una N:M implícita?**

Porque la relación guarda datos propios (cantidad y precio histórico) y una tabla implícita solo admite los dos IDs.

## Para profundizar

[Prisma 7](https://www.prisma.io/docs/orm/v7) · [PostgreSQL: restricciones](https://www.postgresql.org/docs/16/ddl-constraints.html).

## Conceptos clave de esta clase

- **PK:** Clave primaria que identifica una fila.
- **FK:** Referencia respaldada por la base hacia otra fila.
- **Índice:** Estructura de búsqueda que acelera determinadas consultas y añade coste a escrituras.
- **Campo de relación:** Campo de Prisma (`event`, `admissions`) que permite navegar la relación; no es una columna.
- **N:M explícita:** Relación muchos a muchos con un modelo intermedio declarado que puede guardar datos propios.
- **Migración:** Cambio versionado de estructura de la base.
- **Seed:** Programa para preparar datos iniciales o de demostración.
- **Pool:** Conjunto de conexiones reutilizables hacia la base.

## Conexiones

[[Proyecto/6. Modelo de datos|Modelo y seed]] · [[Semana2/CLASE 7|Clase 7]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 3|Clase 3]] · [[Semana1/CLASE 5|Clase 5]] →

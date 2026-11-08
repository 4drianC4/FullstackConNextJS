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

### Configuración y conexiones

Prisma 7 utiliza el adaptador `pg` en este proyecto. La configuración de CLI carga la URL para operaciones como migrar; el módulo de cliente obtiene la URL al ejecutarse la aplicación. El script seed tiene su propio cliente porque no se ejecuta dentro del entorno de servidor de Next.js.

La reutilización del cliente durante hot reload evita crear una instancia nueva por cada edición. No significa una única conexión universal para todos los despliegues: cada proceso puede tener un pool y varias instancias pueden multiplicar conexiones. En hosting revisaremos los límites y el endpoint indicado por el proveedor.

### Seed, fixtures y una base reconstruible

Un seed prepara ejemplos: una cuenta, un evento, una bebida y una mesa que otros módulos pueden usar. Los fixtures son datos controlados para una práctica o prueba. Ninguno debe depender de información real de clientes ni de contraseñas escritas en el repositorio.

El seed utiliza IDs o claves conocidas para no duplicar registros al ejecutarlo otra vez. `upsert` busca por clave única y decide entre crear o actualizar. El ejemplo conserva contraseñas existentes: repetirlo no debe cambiar de forma silenciosa el acceso de alguien.

Antes de integrar una migración, comprueba que un compañero puede reconstruir la base con el historial. No arregles tu entorno editando a mano tablas que luego nadie sabrá reproducir. Si cambias una migración ya aplicada, las copias del equipo dejan de compartir la misma historia.

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

## Para profundizar

[Prisma 7](https://www.prisma.io/docs/orm/v7) · [PostgreSQL: restricciones](https://www.postgresql.org/docs/16/ddl-constraints.html).

## Conceptos clave de esta clase

- **PK:** Clave primaria que identifica una fila.
- **FK:** Referencia respaldada por la base hacia otra fila.
- **Índice:** Estructura de búsqueda que acelera determinadas consultas y añade coste a escrituras.
- **Migración:** Cambio versionado de estructura de la base.
- **Seed:** Programa para preparar datos iniciales o de demostración.
- **Pool:** Conjunto de conexiones reutilizables hacia la base.

## Conexiones

[[Proyecto/6. Modelo de datos|Modelo y seed]] · [[Semana2/CLASE 7|Clase 7]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · ← [[Semana1/CLASE 3|Clase 3]] · [[Semana1/CLASE 5|Clase 5]] →

# Día 6: Backend III - Modelado de Datos

## 1. Creación del `schema.prisma`

El archivo `schema.prisma` es el corazón de tu backend. Es la fuente de la verdad para la estructura de tu base de datos. Aquí es donde traducimos el Diagrama Entidad-Relación (ERD) que diseñamos en el Día 3 a código real que Prisma pueda entender.

### Anatomía de un Modelo
Los modelos en Prisma representan las tablas de tu base de datos. Se componen de campos (columnas), tipos de datos y atributos (reglas y comportamientos).

**Atributos Clave:**
* `@id`: Define la clave primaria (Primary Key) de la tabla.
* `@default(valor)`: Establece un valor por defecto si no se proporciona al crear el registro. Usualmente usamos `uuid()` o `cuid()` para generar IDs alfanuméricos seguros y evitar ataques de enumeración.
* `@unique`: Asegura que el valor de esa columna no se repita en toda la tabla (ej. correos electrónicos, nombres de usuario).
* `@updatedAt`: Prisma actualiza automáticamente este campo con la fecha y hora actual cada vez que el registro se modifica.
* `@@map("nombre_tabla")`: Permite nombrar el modelo en singular en tu código (ej. `User`), pero guardarlo en plural en la base de datos real (ej. `users`), siguiendo las convenciones y buenas prácticas.

**Ejemplo de Modelo Base:**
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?  // El '?' indica que este campo es opcional (NULL)
  password  String
  role      Role     @default(USER) // Uso de Enums para restringir valores
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("users")
}

enum Role {
  USER
  ADMIN
}
```
## 2. Relaciones entre Modelos
Las bases de datos relacionales brillan por su capacidad de conectar información. Prisma facilita la definición de estas conexiones a través de "campos de relación" que no existen como columnas en la base de datos, sino que sirven para que Prisma Client sepa cómo unir la información en nuestro código JavaScript/TypeScript.
### A. Relación Uno a Uno (1:1)

Un registro de la Tabla A se asocia con exactamente un registro de la Tabla B.
Ejemplo: Un User tiene un único Profile.

``` Typescript

model User {
  id      String   @id @default(uuid())
  profile Profile? // Relación virtual para Prisma Client
}

model Profile {
  id     String @id @default(uuid())
  bio    String?
  
  // Llave Foránea (Foreign Key)
  userId String @unique // El @unique es obligatorio en relaciones 1:1
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

>[!INFO] Nota sobre onDelete: 
>Cascade: Significa que si eliminas al usuario de la base de datos, su perfil también se eliminará automáticamente, manteniendo la integridad de los datos.

### B. Relación Uno a Muchos (1:N)

Un registro de la Tabla A se asocia con múltiples registros de la Tabla B.
Ejemplo: Un User puede crear muchos Post.

``` Typescript
model User {
  id    String @id @default(uuid())
  posts Post[] // Un usuario tiene un array de Posts
}

model Post {
  id       String @id @default(uuid())
  title    String
  
  // Llave Foránea
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
}
```

### C. Relación Muchos a Muchos (M:N)

Múltiples registros de la Tabla A se asocian con múltiples de la Tabla B.
Ejemplo: Un Post tiene muchas Category, y una Category pertenece a muchos Post.

Prisma permite manejar esto de forma "implícita", creando la tabla intermedia (join table) por ti automáticamente por detrás:
```Typescript
model Post {
  id         String     @id @default(uuid())
  categories Category[] // M:N implícita
}
model Category {
  id    String @id @default(uuid())
  name  String @unique
  posts Post[] // M:N implícita
}
```

## 3. Generación de Migraciones

El schema.prisma solo vive en tu código. Para que estos cambios se reflejen en tu base de datos real (Supabase, Neon, PostgreSQL local), usamos migraciones.

Una migración es como un commit de Git pero para tu base de datos. Mantiene un historial exacto de cómo evoluciona la estructura de tus tablas a lo largo del tiempo.
### El Comando Principal

Abre tu terminal y ejecuta:
```Bash
npx prisma migrate dev --name init_schema
```
#### ¿Qué hace este comando paso a paso?
1. Compara tu esquema actual con el estado de la base de datos.
2. Genera un archivo .sql dentro de la carpeta prisma/migrations/ con las instrucciones necesarias (ej. CREATE TABLE, ALTER TABLE).
3. Ejecuta ese código SQL en tu base de datos.
4. Genera nuevamente el Prisma Client en la carpeta node_modules para que tu TypeScript conozca los nuevos modelos y el autocompletado funcione.

|**Comando**|**Cuándo Usarlo**|
|---|---|
|`npx prisma migrate dev`|**Desarrollo Local.** Crea el historial SQL de forma permanente, actualiza la DB y regenera el cliente. Es el estándar.|
|`npx prisma db push`|**Prototipado rápido.** Sincroniza el esquema sin generar ni guardar un historial SQL. Útil cuando estás experimentando mucho y borrando tablas constantemente.|

## 4. Seeding: Sembrado de Datos de Prueba

Trabajar en el backend y frontend con una base de datos vacía es frustrante. El "Seeding" nos permite poblar automáticamente la base de datos con información inicial (ej. un usuario administrador, categorías por defecto, posts de prueba).
### Paso 1: Crear el Script (prisma/seed.ts)

Crea un archivo TypeScript en la carpeta prisma. Utilizaremos el método upsert (actualizar o insertar) en lugar de create. Esto hace que nuestro script sea idempotente: si lo ejecutamos varias veces, no nos dará errores por intentar crear datos que ya existen.
```TypeScript

import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Iniciando seed...');

  // Creamos un usuario admin con un post anidado usando las relaciones
  const admin = await prisma.user.upsert({
    where: { email: 'admin@miblog.com' },
    update: {}, // Si existe, no hacemos nada
    create: {
      email: 'admin@miblog.com',
      name: 'Admin Principal',
      password: 'hashed_password_123',
      posts: {
        create: {
          title: 'Primer Post de Prueba',
        }
      }
    },
  })
  
  console.log('✅ Seed completado con éxito:', admin.email)
}

main()
  .catch((e) => {
    console.error('❌ Error en seed:', e)
    process.exit(1)
  })
  .finally(async () => {
    // Es vital desconectar el cliente al terminar
    await prisma.$disconnect()
  })
```

### Paso 2: Configurar package.json

Dile a Prisma cómo debe ejecutar tu script agregando este bloque al final de tu archivo package.json:
```JSON
"prisma": {
  "seed": "ts-node --compiler-options {\"module\":\"CommonJS\"} prisma/seed.ts"
}
```

>[!INFO] Nota: 
>Esto requiere tener ts-node instalado en el proyecto. Si no lo tienes, ejecuta: npm i -D ts-node

### Paso 3: Ejecutar el Seed

En la terminal, corre el siguiente comando para ejecutar el script y llenar tu base de datos:
```Bash
npx prisma db seed
```
>[!TIP] Tip Extra (Prisma Studio): 
>Puedes ver todos los datos que acabas de sembrar y gestionar tu base de datos fácilmente ejecutando npx prisma studio. Esto abrirá un panel de administración visual y moderno directamente en tu navegador web.

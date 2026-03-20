# Backend II - ORMs y Conexión a la Base de Datos

---

## 1. ¿Qué es un ORM?

Un **ORM (Object-Relational Mapping)** es una herramienta que actúa como un traductor bilingüe entre nuestro código (JavaScript/TypeScript) y nuestra base de datos (SQL).

### El Problema sin ORM (Raw SQL)
Tradicionalmente, para comunicarnos con la base de datos, debíamos escribir consultas SQL puras dentro de cadenas de texto (strings) en nuestro código.
* **Desventajas:** No hay autocompletado, es fácil cometer errores de tipeo (ej. escribir `SELET` en vez de `SELECT`), y TypeScript no tiene forma de saber qué datos devuelve esa consulta, perdiendo toda la seguridad de tipos.

### La Solución con ORM
El ORM nos permite interactuar con las tablas de la base de datos como si fueran simples objetos y métodos de JavaScript. 

| Acción                        | Usando Raw SQL (Antiguo)                               | Usando un ORM (Moderno)                     |
| :---------------------------- | :----------------------------------------------------- | :------------------------------------------ |
| **Buscar todos los usuarios** | `db.query("SELECT * FROM users;")`                     | `db.user.findMany()`                        |
| **Crear un usuario**          | `db.query("INSERT INTO users (name) VALUES ('Ana');")` | `db.user.create({ data: { name: 'Ana' } })` |
| **Seguridad**                 | Vulnerable a inyecciones SQL si no se limpia.          | Sanitiza los datos automáticamente.         |

>[!IMPORTANT] Decisión del Proyecto:
> Existen muchos ORMs en el ecosistema Node (TypeORM, Sequelize, Drizzle). Nosotros usaremos **Prisma ORM** porque tiene la mejor experiencia de desarrollador (DX), una documentación impecable y genera tipos de TypeScript automáticamente basándose en nuestra base de datos.

---

## 2. Configuración de Prisma ORM

Vamos a integrar Prisma en nuestro proyecto base de Next.js. El proceso se divide en la instalación de las herramientas de desarrollo y la inicialización del esquema.

### Pasos de Instalación
1.  **Instalar la CLI de Prisma:** Esta herramienta nos permitirá usar comandos en la terminal para gestionar la base de datos.
    ```bash
    npm install prisma --save-dev
    ```
2.  **Inicializar Prisma:** Esto creará la carpeta `prisma` y el archivo `.env` (si no existía).
    ```bash
    npx prisma init
    ```

### El Archivo schema.prisma
Al inicializar, se crea un archivo `prisma/schema.prisma`. Este es el corazón de nuestro backend. Aquí definiremos qué base de datos usamos y, más adelante, escribiremos las tablas que diseñamos en el Día 3.
* Contiene el bloque `generator` (que le dice a Prisma que genere código para un cliente de JavaScript).
* Contiene el bloque `datasource` (que le dice a Prisma dónde está alojada la base de datos y qué motor usa, en nuestro caso, PostgreSQL).

---

## 3. Conexión a Base de Datos en la Nube (Neon / Supabase)

Tener una base de datos local instalada en la computadora de cada alumno es un dolor de cabeza (versiones distintas, problemas de puertos, etc.). La solución moderna es usar **Serverless Postgres** en la nube.

### Proveedores Recomendados
* **Supabase:** Un ecosistema completo (Firebase alternativo) que nos da una base de datos PostgreSQL pura.
* **Neon:** Una plataforma especializada en Postgres "Serverless" que se enciende y apaga según la demanda, ideal para integrarse con Vercel.

### Flujo de Conexión
1.  Crear una cuenta gratuita en Neon o Supabase y crear un nuevo proyecto.
2.  Copiar la **Connection String (Cadena de conexión)**. Se ve algo así:
    `postgresql://usuario:contraseña@servidor.nube.com:5432/nombre_db`
3.  Pegar esta cadena en nuestro archivo `.env` local en la variable `DATABASE_URL`.
4.  *Importante:* Asegurarse de que el archivo `.env` esté en `.gitignore` para no subir nuestra contraseña a GitHub.

---

## 4. Primeras Queries con Prisma Client

Una vez conectada la base de datos, necesitamos instalar el "cliente" que se ejecutará en nuestro código de producción para hacer las consultas.

### Instalación del Cliente
```bash
npm install @prisma/client
```
### El Problema de Next.js en Desarrollo (¡Atención aquí!)
Next.js, en modo desarrollo (`npm run dev`), recarga los archivos constantemente cada vez que guardamos un cambio (Hot Reloading). Si instanciamos una conexión a la base de datos de forma normal, Next.js abrirá una conexión nueva con cada guardado, agotando el límite de conexiones de nuestra base de datos gratuita en minutos.

### La Solución: El Patrón Singleton
Para evitar esto, debemos crear un archivo en la raíz de nuestro proyecto (ej. `lib/prisma.ts`) que guarde la conexión de Prisma en el objeto global de Node. Así, Next.js reciclará la misma conexión en cada recarga.

``` Typescript
import { PrismaClient } from '@prisma/client'

const prismaClientSingleton = () => {
  return new PrismaClient()
}

declare global {
  var prismaGlobal: undefined | ReturnType<typeof prismaClientSingleton>
}

const prisma = globalThis.prismaGlobal ?? prismaClientSingleton()

export default prisma

if (process.env.NODE_ENV !== 'production') globalThis.prismaGlobal = prisma
```

### Ejecutando la Primera Query

Ahora, en cualquier parte de nuestro Backend (ej. un archivo Route Handler en `app/api/users/route.ts`), podemos importar esta instancia y hablar con la base de datos:

```Typescript
import prisma from '@/lib/prisma';
import { NextResponse } from 'next/server';

export async function GET() {
  // Prisma va a la DB, busca todos los usuarios y los devuelve.
  const users = await prisma.user.findMany();
  
  // Respondemos al cliente con un JSON de los usuarios
  return NextResponse.json(users);
}
```
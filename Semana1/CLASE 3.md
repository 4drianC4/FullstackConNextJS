# Diseño de Bases de Datos y Modelado de Datos

---

## 1. Bases de Datos: Relacionales vs No Relacionales

Antes de crear tablas, debemos elegir el motor adecuado para nuestro proyecto. El mundo de las bases de datos se divide en dos grandes familias: SQL (Relacionales) y NoSQL (No Relacionales).

### Bases de Datos Relacionales (SQL)
Imagina hojas de cálculo estrictas conectadas entre sí. Usan un lenguaje estándar llamado SQL (Structured Query Language).
* **Estructura:** Los datos se guardan en Tablas compuestas por Filas (registros) y Columnas (atributos).
* **Esquema Rígido:** Debes definir qué tipo de dato va en cada columna antes de guardar información. Si una columna dice "Número", no puedes guardar texto.
* **Relaciones:** Su superpoder es conectar tablas a través de "Llaves" (Keys), asegurando que los datos huérfanos no existan.
* **Ejemplos:** PostgreSQL, MySQL, SQLite.

### Bases de Datos No Relacionales (NoSQL)
Imagina un archivero flexible donde puedes guardar documentos con diferentes formatos.
* **Estructura:** Los datos suelen guardarse como Documentos tipo JSON, Pares Clave-Valor o Grafos.
* **Esquema Flexible:** Cada documento puede tener campos diferentes. Un usuario puede tener el campo "edad" y otro no, sin romper la base de datos.
* **Escalabilidad:** Son excelentes para guardar volúmenes masivos de datos no estructurados rápidamente.
* **Ejemplos:** MongoDB, Redis, DynamoDB.

### Tabla Comparativa

| Característica           | Relacional (SQL)                              | No Relacional (NoSQL)                             |
| :----------------------- | :-------------------------------------------- | :------------------------------------------------ |
| **Estructura de datos**  | Tablas, filas y columnas                      | Documentos (JSON), grafos, clave-valor            |
| **Esquema**              | Rígido (Predefinido)                          | Flexible (Dinámico)                               |
| **Relaciones complejas** | Excelentes y seguras                          | Difíciles de mantener                             |
| **Ideal para...**        | Sistemas financieros, ERPs, gestión de tareas | Redes sociales, catálogos mutables, logs de datos |

>[!INFO] Decisión del Proyecto:
>Para nuestro Sistema de Gestión de Tareas, utilizaremos una **Base de Datos Relacional (PostgreSQL)**. La naturaleza del proyecto exige relaciones estrictas (Un usuario *tiene* tableros, un tablero *tiene* columnas, una columna *tiene* tareas).

---

## 2. Diseño de Base de Datos del Proyecto

El primer paso del diseño es identificar las "Entidades" (los sustantivos principales de nuestra aplicación) y cómo se relacionan entre sí.

### Entidades Principales
* **User (Usuario):** Quien interactúa con el sistema.
* **Workspace (Espacio de trabajo):** El contenedor principal (ej. "Equipo de Marketing").
* **Board (Tablero):** Un proyecto específico dentro del espacio de trabajo.
* **Column (Columna/Estado):** Las listas dentro del tablero (ej. "To Do", "Done").
* **Task (Tarea):** La unidad de trabajo asignada a un usuario.
* **Comment (Comentario):** Notas dejadas en una tarea específica.
* **Tag (Etiqueta):** Categorías visuales para las tareas.

### Tipos de Relaciones
* **Uno a Muchos (1:N):** Un `Workspace` tiene muchos `Boards`, pero un `Board` pertenece a un solo `Workspace`. (La relación más común).
* **Muchos a Muchos (N:M):** Una `Task` puede tener múltiples `Tags`, y un `Tag` puede estar en múltiples `Tasks`. (Requiere una tabla intermedia).

---

## 3. Diagrama Entidad-Relación (ERD)

Un ERD es el plano arquitectónico de nuestra base de datos. Nos permite visualizar las tablas y las líneas que las conectan antes de escribir código.

### Conceptos Clave del Diagrama
* **Primary Key (PK - Llave Primaria):** El identificador único e irrepetible de cada fila en una tabla (ej. `id: 1` o un UUID). Toda tabla debe tener una PK.
* **Foreign Key (FK - Llave Foránea):** Una columna que hace referencia a la Llave Primaria de otra tabla. Es el "gancho" que crea la relación. Ejemplo: La tabla `Task` tendrá una columna `columnId` (FK) para saber a qué columna pertenece.

---

## 4. Normalización y Buenas Prácticas

La normalización es el proceso de organizar los datos para reducir la redundancia y mejorar la integridad. 

### Reglas de Oro para el Backend
1. **No repetir información (Evitar redundancia):** No guardes el "Nombre del Usuario" dentro de la tabla "Task". Guarda solo el `userId` (FK). Si el usuario cambia su nombre, se actualizará automáticamente en todas sus tareas.
2. **Tipos de datos correctos:** Usa `boolean` para verdadero/falso, `timestamp` para fechas y horas, y `varchar` o `text` para cadenas. No guardes números como texto.
3. **Soft Deletes (Borrados Lógicos):** En aplicaciones reales, rara vez borramos registros permanentemente (`DELETE`). Es mejor agregar una columna `deletedAt` (tipo fecha). Si está nula, el registro está activo; si tiene fecha, se considera "eliminado" para el usuario, pero lo conservamos en la base de datos por seguridad.
4. **Uso de UUIDs:** En lugar de usar IDs incrementales (1, 2, 3...), usaremos identificadores universales (UUIDs, ej: `123e4567-e89b-12d3-a456-426614174000`). Esto evita que un usuario malintencionado adivine cuántos registros tenemos o intente acceder a IDs consecutivos.
5. **Auditoría básica:** Toda tabla importante debe tener al menos dos columnas automáticas: `createdAt` (fecha de creación) y `updatedAt` (fecha de última modificación).
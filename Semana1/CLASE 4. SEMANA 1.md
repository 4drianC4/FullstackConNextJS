# Backend I - Fundamentos de APIs RESTful

---

## 1. ¿Qué es una API REST?

Una **API (Application Programming Interface)** es un conjunto de reglas que permite que dos aplicaciones se comuniquen entre sí. 
* **La analogía del restaurante:** Tú eres el Cliente, la cocina es el Servidor/Base de datos. La API es el *Mesero*: tú le das tu orden (petición), el mesero va a la cocina, y te trae tu comida (respuesta). Tú no necesitas saber cómo cocinaron el plato, solo necesitas el resultado.

**REST (Representational State Transfer)** no es una tecnología, es un *estilo arquitectónico* o un conjunto de acuerdos sobre cómo deben construirse estas APIs. 
* **JSON como idioma universal:** Las APIs REST modernas se comunican casi exclusivamente enviando y recibiendo texto en formato JSON (JavaScript Object Notation), el cual es ligero y fácil de leer tanto para humanos como para máquinas.
* **Sin Estado (Stateless):** Cada petición que el cliente envía al servidor debe contener toda la información necesaria para ser procesada. El servidor no guarda "recuerdos" de peticiones anteriores por defecto.

---

## 2. Métodos HTTP (El CRUD de la Web)

Si las URLs (ej. `/api/users`) son los **sustantivos**, los Métodos HTTP son los **verbos**. Nos indican qué acción queremos realizar sobre un recurso. Esto se mapea directamente con el concepto de CRUD (Create, Read, Update, Delete).

| Operación CRUD | Método HTTP | Descripción para nuestro proyecto                                                          |
| :------------- | :---------- | :----------------------------------------------------------------------------------------- |
| **Create**     | `POST`      | Crea un nuevo recurso. (Ej: Crear una nueva Tarea en un Tablero).                          |
| **Read**       | `GET`       | Obtiene información. No modifica nada. (Ej: Traer la lista de Proyectos).                  |
| **Update**     | `PUT`       | Reemplaza un recurso **por completo**. Si falta un campo, se borra.                        |
| **Update**     | `PATCH`     | Actualiza un recurso **parcialmente**. (Ej: Solo cambiar el estado de una tarea a "Done"). |
| **Delete**     | `DELETE`    | Elimina un recurso específico de la base de datos.                                         |

---

## 3. Status Codes y Mejores Prácticas

Cuando el "mesero" (la API) regresa de la cocina, siempre trae un código numérico. Este es el **HTTP Status Code**, y es la forma en que el servidor nos dice rápidamente cómo nos fue, antes de que leamos el cuerpo del mensaje.

### Categorías de Códigos de Estado
* **2xx (Éxito):** Todo salió bien.
  * `200 OK`: Petición exitosa estándar (usado en GET, PUT, PATCH).
  * `201 Created`: Se creó un recurso exitosamente (usado al responder un POST).
  * `204 No Content`: Petición exitosa, pero no hay datos para devolver (común en DELETE).
* **4xx (Error del Cliente):** El frontend o el usuario se equivocó.
  * `400 Bad Request`: Faltan datos o están mal formateados (ej. no enviaste el título de la tarea).
  * `401 Unauthorized`: No tienes sesión iniciada o te falta el token.
  * `403 Forbidden`: Tienes sesión, pero no tienes permisos para esa acción.
  * `404 Not Found`: El recurso que buscas no existe (ej. la tarea con ID 999 fue borrada).
* **5xx (Error del Servidor):** El backend falló.
  * `500 Internal Server Error`: Nuestro código falló, la base de datos se cayó o hay un bug en el servidor.

### Buenas Prácticas de Diseño REST
1. **Usar sustantivos en plural:** Usa `/api/tasks` y no `/api/getTask`. El verbo (`GET`) ya dice qué quieres hacer.
2. **URLs predecibles:** Para afectar a un recurso específico, pasa su ID en la URL. Ejemplo: `DELETE /api/tasks/123`.
3. **No enmascarar errores:** Nunca devuelvas un error con un status `200 OK`. Si algo falló por culpa del usuario, devuelve un `400`.

---

## 4. Testing de Endpoints con Postman o Thunder Client

El navegador web (Chrome, Edge) solo sabe hacer peticiones `GET` por defecto cuando escribes una URL en la barra de direcciones. Para probar nuestros métodos `POST`, `PUT` o `DELETE` antes de construir el Frontend en React, necesitamos herramientas especializadas.

### Las Herramientas
* **Postman:** Es el estándar de la industria. Un programa independiente muy robusto para organizar colecciones de APIs.
* **Thunder Client:** Una extensión dentro de VSCode. Es más ligera y excelente para este curso porque nos permite probar la API sin salir de nuestro editor de código.



### Anatomía de una Petición en Thunder Client
Para probar que nuestro backend funciona, siempre configuraremos tres partes en la herramienta:
1. **La URL y el Método:** Seleccionamos `POST` y escribimos `http://localhost:3000/api/tasks`.
2. **Los Headers (Cabeceras):** Metadatos ocultos. El más importante que usaremos es `Content-Type: application/json` para avisarle al servidor que le enviaremos datos en formato JSON.
3. **El Body (Cuerpo):** El "paquete" de datos que enviamos. Aquí escribimos el objeto JSON:
```json
{
  "title": "Aprender Next.js",
  "columnId": "123-abc"
}
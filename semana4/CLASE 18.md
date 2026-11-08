---
tipo: clase
clase: 18
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 18 — IA I - Desarrollo con OpenCode y NVIDIA

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 17|Clase 17]] · [[semana4/CLASE 19|Clase 19]] →

> [!abstract] Objetivo
> Usar OpenCode con un proveedor NVIDIA disponible sin depender de una suscripción de pago.

## Antes de empezar

Repasa [[semana4/CLASE 17|Clase 17]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Qué puede aportar un agente al desarrollo

Un modelo genera respuestas a partir de un contexto. Un agente de programación combina esa capacidad con herramientas para leer archivos, proponer cambios y ejecutar operaciones permitidas. OpenCode proporciona esa interacción con el repositorio; el proveedor sirve la inferencia y un modelo concreto responde.

Esta separación explica por qué instalar OpenCode no garantiza acceso a cualquier modelo ni cuota ilimitada. También explica por qué una respuesta buena en conversación no equivale a un cambio correcto en tu proyecto: debe respetar versiones, contratos y archivos reales.

### Contexto útil frente a contexto abundante

El contexto es la información que el modelo recibe para el trabajo: petición, instrucciones, fragmentos de archivos, resultados de herramientas y conversación. Tiene límites. Un token es una unidad de procesamiento de texto, no necesariamente una palabra ni una medida de calidad.

Enviar todo el repositorio sin selección no garantiza comprensión. Identifica la funcionalidad, sus rutas, contrato, tests y dependencias. Un error concreto con pasos de reproducción aporta más que veinte capturas sin explicación. No incluyas `.env`, cookies ni datos personales para que la respuesta parezca más real.

### Requisitos y criterios de aceptación

«Haz un buscador» deja decisiones abiertas: qué campos, si distingue mayúsculas, qué pasa con vacío, cuánto texto admite y quién puede usarlo. Un criterio de aceptación debe poder comprobarse: consulta parcial de nombre, hasta 80 caracteres, permisos actuales conservados y estado vacío visible.

Además define límites de edición. En una mejora de bebidas no hace falta cambiar autenticación, reestructurar todo src ni regenerar migraciones. Pedir primero un plan hace posible detectar ese desvío antes de aceptar modificaciones.

### Planificación y ejecución por pasos

Empieza con una rama y un estado conocido. Pide al agente localizar archivos y explicar el contrato que observó. Revisa la propuesta, permite un cambio pequeño y lee el diff antes de continuar. Ejecuta controles y recorre el comportamiento real.

La versión de herramienta del curso determina los comandos disponibles. No copies configuración de otra versión solo porque tiene el mismo nombre. Si una opción de conexión cambió, revisa ayuda y documentación correspondiente antes de editar el proyecto para compensar un problema de instalación.

### Herramienta, proveedor y modelo

**OpenCode** es el agente de programación que trabaja con el repositorio. **NVIDIA** proporciona inferencia; el modelo elegido responde. No son tres nombres de la misma herramienta. No se requiere OpenAI ni una suscripción de ChatGPT.

Usaremos los endpoints alojados de NVIDIA disponibles en su catálogo para desarrollo. Ejecutar NVIDIA NIM localmente es otra opción que puede requerir hardware/licencia/configuración adicional; no es requisito del curso.

### Preparación gratuita y reproducible

Esta guía utiliza la interfaz de OpenCode 1 descrita en [su referencia correspondiente](https://docs.opencode.ai/docs/). Comprueba `opencode --version` y no mezcles sus instrucciones con OpenCode 2. Consulta [[Recursos/Stack y entorno|las versiones y comandos comunes]] y confirma que tu cuenta ofrece un modelo disponible sin pago antes de empezar.

```bash
npm install -g opencode-ai@1
opencode --version
cd discoteca
opencode
```

Dentro de OpenCode:

```text
/connect
/models
```

En `/connect` seleccionar **NVIDIA** y proporcionar la clave creada en [build.nvidia.com](https://build.nvidia.com/). Elegir en `/models` un modelo realmente disponible; no copiar un identificador inventado. Revisar que el modelo soporte las herramientas necesarias para la práctica.

La clave se guarda mediante la conexión local, nunca en el repositorio, prompt o apuntes compartidos. No activar facturación para seguir la clase. El acceso gratuito tiene límites que pueden cambiar; si no hay cuota, trabajar en parejas o usar el ejercicio de revisión de código sin inferencia de la clase 19. No exigir compra ni asumir NIM alojado ilimitado.

### Contexto antes de generar

Trabajar en rama nueva, con pruebas de referencia y un commit limpio. Preparar en el repositorio de aplicación un `AGENTS.md` sin secretos con arquitectura, comandos, reglas, contratos y alcance. Revisar cualquier archivo generado por inicialización automática antes de versionarlo.

Prompt de trabajo:

```text
Proyecto: gestión de discoteca, Next.js y arquitectura por funcionalidades.
Tarea: añadir búsqueda por nombre al listado de bebidas.
Revisa features/drinks y su contrato. No modifiques autenticación ni migraciones.
Primero explica los archivos implicados, los casos de error y un plan breve.
Criterios: coincidencia parcial, entrada limitada a 80 caracteres,
permisos actuales conservados y estado vacío visible.
No leas .env ni archivos de credenciales. No ejecutes despliegues.
Espera mi revisión del plan antes de editar.
```

Usar el modo de planificación de la versión instalada. Después aprobar un cambio pequeño, leer el diff y ejecutar controles. No aceptar una dependencia nueva, borrado de pruebas o modificación de permisos sin entender por qué.

La búsqueda es ampliación del CRUD ya terminado, no requisito para desbloquear otros equipos. El servicio sigue parametrizando consultas mediante Prisma; no concatenar SQL con el texto del usuario.

### Qué debería contener el contexto del repositorio

Un archivo de instrucciones para el agente puede describir arquitectura, scripts de comprobación, ubicación de contratos y reglas del producto. Incluye convenciones técnicas y conserva las credenciales fuera de ese archivo. Su propósito es explicar cómo trabajar con ese código.

Ejemplo de contenido para AGENTS.md en la aplicación:

```markdown
# Trabajo en Discoteca

- Organiza cambios dentro de src/features/<funcionalidad>.
- No importes backend en componentes cliente.
- El actor viene de sesión y el servidor calcula totales.
- Conserva restricciones únicas y guards existentes.
- No leas .env ni archivos de credenciales.
- Antes de terminar ejecuta lint, typecheck, tests relevantes y build.
- Describe límites y no declares pruebas ejecutadas si no las corriste.
```

Estas instrucciones orientan el agente; no son una barrera de acceso por sí mismas. Las opciones de permisos de la herramienta y la revisión humana deben acompañar el alcance de trabajo.

### Un ejemplo de cambio pequeño: búsqueda de bebidas

Primero acuerda `GET /api/drinks?query=agua`. Define que query vacío lista según el límite existente; máximo 80 caracteres; coincidencia parcial sin distinguir mayúsculas si esa es la política elegida. Valida el parámetro antes de consultar y conserva el guard del listado.

Después incorpora el filtro a Prisma mediante su API parametrizada, no concatenando SQL. Actualiza la interfaz para representar carga, resultados y vacío. Finalmente prueba una coincidencia, ninguna, espacios y un texto demasiado largo. El cambio de contrato debe ser visible en la documentación de la funcionalidad.

El agente puede proponer una dependencia para debounce. Antes de instalarla, pregunta si es necesaria para el alcance. Empezar con botón «Buscar» puede demostrar el comportamiento sin agregar temporizadores y cancelación extra. La herramienta ayuda a implementar una decisión; no necesita ampliar el producto en cada respuesta.

### Evaluar una respuesta convincente

Revisa los nombres de imports, la versión de APIs, la existencia de archivos y el contrato de datos. Un fragmento elegante puede usar una función de otra versión. Que compile no prueba permisos; que una prueba pase no prueba que el test esté observando la regla relevante.

Si el agente cambia una restricción para que un test deje de fallar, revisa si eliminó la garantía que querías conservar. Una respuesta rápida no compensa una reserva duplicada o una venta calculada por el navegador.

### Gratuidad, cuota y continuidad del ejercicio

Usa el acceso sin pago que tu cuenta tenga disponible y selecciona modelos realmente listados. Si recibes rate limit o falta de cuota, no habilites facturación por impulso para completar la tarea. Conserva el trabajo y realiza la revisión equivalente con un compañero.

Los endpoints alojados de NVIDIA y ejecutar NIM en tu equipo son opciones distintas. No necesitas instalar un servidor de inferencia local para practicar este flujo. La nota [[Recursos/Conceptos/Contexto tokens y agentes|Contexto, tokens y agentes]] explica herramienta, proveedor, modelo y límites sin confundirlos con capacidades del producto.

### Qué entregar para que otro pueda revisar

Incluye intención, alcance, diff, pruebas realizadas y una decisión humana. Por ejemplo: «El modelo propuso borrar el guard para probar la consulta; conservé el guard y adapté la prueba a una sesión válida». No necesitas publicar la conversación completa ni atribuirle a la IA una aprobación que debe hacer una persona.

### Caso desarrollado: la búsqueda propuesta elimina el permiso

Pides añadir búsqueda por nombre de bebidas. El agente cambia el controlador, pero elimina requireRoles porque la prueba inicial recibía 401. Ahora el filtro funciona para cualquiera. Solucionó una dificultad de su prueba degradando una garantía del producto.

La revisión del plan debía exigir conservar permisos; el diff permite comprobar si lo hizo. Recupera el guard y adapta la prueba para usar una sesión válida. Añade el caso sin sesión para impedir que el mismo error regrese al extender el listado.

Comprueba también que la consulta tiene límite y valida longitud. Un input libre no necesita convertirse en SQL concatenado ni añadir una dependencia grande. Compara el cambio real con el alcance: esquema de query, servicio, UI y pruebas son candidatos razonables; autenticación global no lo es.

Pide explicación si propone otro enfoque, pero contrástala con contratos y documentación de la versión usada. Un argumento convincente no transforma un requisito en opcional. La responsabilidad de integrar la decisión sigue siendo humana.

Documenta qué detectaste y cómo se comprobó la corrección. Ese registro muestra un uso valioso de IA: aceleró una implementación y tú conservaste la regla que daba sentido al acceso. La ayuda no se evalúa por aceptar todas las sugerencias, sino por producir un cambio comprendido y verificado.

## Práctica guiada

Configurar el proveedor, explicar un módulo y preparar un plan para una mejora pequeña.

## Tarea para casa

Implementar la mejora en rama propia. Documentar modelo, archivos cambiados, pruebas y una sugerencia que corregiste.

## Criterios de finalización

- [ ] Distingues OpenCode, proveedor y modelo.
- [ ] La práctica no requiere pagar.
- [ ] Revisaste el diff y no compartiste secretos.

## Preguntas resueltas

**¿Instalar OpenCode incluye cualquier modelo gratis?**

No. Herramienta, proveedor, acceso y cuotas son piezas distintas.

**¿Pedir actuar como senior reemplaza el contexto?**

No. Necesita conocer contratos y archivos reales para proponer cambios adecuados.

**¿Una instrucción evita por sí sola leer secretos?**

Orienta el trabajo, pero no sustituye permisos de herramienta y control del alcance.

## Para profundizar

[OpenCode 1](https://docs.opencode.ai/docs/) · [NVIDIA en OpenCode](https://docs.opencode.ai/docs/providers/#nvidia).

## Conceptos clave de esta clase

- **Modelo:** Sistema que produce respuestas a partir de un contexto.
- **Proveedor:** Servicio que ofrece acceso a inferencia de modelos.
- **Agente:** Herramienta que coordina un modelo con acciones y contexto de trabajo.
- **Token:** Unidad de procesamiento que puede representar parte de una palabra o símbolos.
- **Diff:** Representación de cambios entre dos estados de archivos.
- **Criterio de aceptación:** Condición observable para decidir si una tarea cumple su objetivo.

## Conexiones

[[Recursos/Fullstack con IA/Programemos como si estuviéramos en la matrix... o quizá si estamos|Mapa de IA]] · [[semana4/CLASE 19|Clase 19]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 17|Clase 17]] · [[semana4/CLASE 19|Clase 19]] →

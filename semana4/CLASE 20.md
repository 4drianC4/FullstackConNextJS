---
tipo: clase
clase: 20
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 20 — Presentación, evaluación y retrospectiva

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 19|Clase 19]]

> [!abstract] Objetivo
> Demostrar el proyecto y explicar el aporte individual con sus límites.

## Antes de empezar

Repasa [[semana4/CLASE 19|Clase 19]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Explicar una aplicación demuestra cómo la entiendes

Una presentación técnica relaciona un problema con decisiones y evidencia. No consiste en recorrer cada carpeta ni memorizar nombres de librerías. Al mostrar una venta, debes poder decir quién la realiza, qué valida el servidor, qué se guarda y cómo se evita duplicarla.

El mismo recorrido permite repasar el curso: contrato tipado, validación, identidad, permisos, regla de negocio, persistencia y respuesta de interfaz. Saber seguirlo ayuda a responder preguntas incluso si el archivo fue escrito con ayuda de otro compañero o un agente.

### Del requisito a una demostración verificable

Elige una historia concreta. «Como STAFF, registro una venta de bebidas disponibles y consulto su detalle» tiene comienzo y resultado. Antes de la demo prepara datos sintéticos suficientes y decide qué estado inicial necesita.

No depende solo de mostrar un toast. Comprueba la venta en un listado o detalle y explica sus precios históricos. Repite un caso rechazado, como una reserva duplicada o un acceso sin permiso. La persona que observa debe distinguir una operación real de una pantalla con fixtures.

### Diferenciar alcance, limitación y fallo

Un alcance excluido es algo que el MVP nunca prometió: no procesa tarjetas bancarias. Una limitación es una condición del comportamiento actual, como listado acotado a 50 filas. Un fallo es una promesa incumplida, por ejemplo crear dos reservas para una mesa/evento.

Declarar estas diferencias permite evaluar con justicia y planificar mejoras. No presentes ausencia de pagos como bug si el producto no los incluyó. Tampoco llames «limitación» a una operación administrativa accesible por cualquiera.

### Estructura de una respuesta técnica

Responde primero qué hace la parte consultada, luego dónde decide la regla y finalmente cómo se comprobó. Si te preguntan por idempotencia, explica la intención repetida y la clave antes de hablar del nombre de la función.

Si no sabes un detalle, delimita qué conoces y qué consultarías. Inventar una garantía para sonar seguro puede hacer que otra persona confíe datos a un comportamiento que no existe. Las pruebas y documentación acotan lo que puedes afirmar.

### Preparación

Verificar la URL antes de presentar, usar datos de demostración y cerrar sesiones ajenas. Tener disponible un recorrido local si falla la conexión; declarar si no se pudo verificar producción. No mostrar claves, paneles privados ni información real de clientes.

### Preparar tu participación

Acuerda con tu equipo un recorrido breve y reparte las explicaciones para que cada integrante muestre una decisión propia. Lleva los PR y pruebas que respaldan tu aporte. La evaluación individual también considera el trabajo acumulado; no depende solo de quién maneja el teclado durante la demo.

### Guion de demostración

1. Problema y alcance de la funcionalidad.
2. Recorrido desde interfaz hasta base de datos.
3. Caso exitoso y caso rechazado por validación o permisos.
4. Prueba o evidencia del fallo más importante que corrigieron.
5. Aporte de cada integrante y uso de OpenCode, si lo hubo.
6. Limitaciones y siguiente mejora razonable.

### Entrega

Repositorio de aplicación con README de arranque, migraciones, seed de prueba, `.env.example`, URL y PR relevantes. Añadir resultados de controles y una lista de limitaciones conocidas. No marcar una funcionalidad como completa porque se ve bien si la operación todavía usa un mock.

### Retrospectiva

¿Qué contrato evitó un bloqueo? ¿Qué dependencia apareció igual? ¿Qué prueba encontró un error real? ¿Cuándo la IA ayudó y cuándo hubo que corregirla?

Los siguientes pasos pueden incluir paginación avanzada, inventario, reportes, QR o una función de IA dentro del producto. Cada uno necesita nuevo alcance, pruebas y revisión de costos; no se presenta como capacidad ya adquirida.

### Preguntas de repaso razonadas

**¿Por qué el formulario valida y el backend repite la validación?** El primero mejora la interacción; el segundo recibe datos no confiables incluso desde clientes que omiten la pantalla. La base añade integridad para relaciones y carreras.

**¿Dónde se decide el precio de una venta?** En el servidor, consultando catálogo disponible y guardando el precio aplicado en las líneas. El navegador puede estimar, pero no fijar la autoridad del total.

**¿Qué ocurre si dos empleados emiten la última entrada?** La condición de plazas y el incremento se evalúan en una escritura atómica; la transacción crea la entrada junto al contador. Solo una emisión debe cumplir la condición.

**¿Cómo llega el actor a la venta?** Desde la sesión y la consulta de cuenta vigente. El body no elige el empleado al que se atribuye la operación.

**¿Por qué aparecen server y client en un mismo proyecto?** Next.js integra ambos entornos, pero cada uno tiene capacidades y restricciones. El contrato público puede compartirse; Prisma y secretos permanecen del lado del servidor.

**¿Qué prueba un build correcto?** Que se pudo generar un artefacto con ese código y entorno de construcción. No demuestra que la base productiva esté configurada ni que un usuario tenga los permisos esperados.

Estas preguntas sirven para practicar una explicación propia. Repite el análisis con tu funcionalidad y utiliza datos distintos del ejemplo para evitar memorizar respuestas sin entender el recorrido.

### Documentación que permite continuar sin ti

Un README de aplicación debe explicar requisitos, instalación, variables sin valores reales, migraciones, datos de prueba, comandos y recorrido básico. Añade URL si hay despliegue y los límites conocidos. No obligues al siguiente compañero a recuperar una conversación de chat para descubrir cómo arrancar.

El lockfile y las migraciones forman parte de esa reproducción. Las claves no. Si una cuenta de demostración necesita contraseña, define un mecanismo local o controlado para prepararla; no publiques la contraseña de un sistema abierto junto al enlace.

### Evidencia del aporte individual

Muestra tu tarea, los archivos de la funcionalidad, un PR y una prueba o revisión que realizaste. El número de commits o líneas no describe calidad por sí mismo. Una corrección pequeña que evita una venta duplicada puede aportar más que una pantalla grande que no guarda datos.

Si trabajaste con IA, explica una propuesta aceptada y una decisión que revisaste. Puedes demostrar comprensión siguiendo el contrato y señalando los límites de la prueba. No necesitas atribuirte escritura manual de cada carácter para ser responsable del resultado.

### Retrospectiva con acciones concretas

En vez de «hay que organizarnos mejor», identifica qué contrato llegó tarde, qué dato compartido faltó y qué cambio habría reducido el bloqueo. Por ejemplo: definir IDs y DTO de eventos antes de construir reservas permite avanzar sin esperar toda su interfaz.

En vez de «más tests», señala el caso que escapó y el nivel adecuado: carrera real en integración, formulario en E2E o cálculo puro en unitarias. La mejora tiene valor cuando se puede convertir en una tarea comprobable.

### Siguientes pasos con alcance propio

QR, pagos, reportes o funciones de IA dentro del producto añaden nuevas entradas, permisos, errores y costes de operación. Elige una mejora por problema y define su contrato antes de sumar tecnologías. Un MVP pequeño terminado es una base desde la que puedes ampliar con evidencia.

Al cerrar el curso conserva instrucciones reproducibles y una lista honesta de pendientes. La demo termina en una fecha; la capacidad de comprender y mejorar el proyecto continúa cuando otra persona puede recorrerlo contigo o a partir de tus apuntes.

### Caso desarrollado: explicar tu venta en una defensa técnica

Comienza por la intención: el personal registra bebidas y cantidades. Explica el contrato de entrada sin total ni actor confiables. Sigue al guard que obtiene identidad, al esquema que limita líneas y al servicio que consulta precios, crea líneas históricas y calcula el total.

Después muestra el caso de reintento. La clave de intención evita duplicar la venta si no llegó la primera respuesta. Señala la restricción y la comparación de actor/contenido, y enseña una evidencia con una sola cabecera persistida.

Conecta la interfaz: el borrador mantiene valores mientras hay un fallo incierto, el botón representa envío pendiente y el listado se actualiza solo al confirmar. No afirmes que deshabilitar el botón sea la garantía principal contra duplicados.

Finalmente declara el alcance: registra una venta interna, no un pago bancario ni una factura fiscal. Si todavía no existe una ampliación, nómbrala como trabajo futuro. La presentación permite comprender qué resolviste y dónde empieza un nuevo problema.

Puedes adaptar este guion a entradas, eventos o reservas: intención, contrato, identidad, regla, persistencia, respuesta y evidencia. Si entiendes esa cadena, podrás responder una variación sin recitar archivos de memoria. Practica con un compañero que pregunte qué ocurre si falla cada frontera.

## Práctica guiada

Presentar y responder preguntas del flujo, permisos y datos.

## Tarea para casa

Escribir una retrospectiva individual breve y dejar instrucciones reproducibles para otro desarrollador.

## Criterios de finalización

- [ ] La demo muestra un flujo real.
- [ ] Cada integrante explica su aporte.
- [ ] El repositorio documenta límites y ejecución.

## Preguntas resueltas

**¿La presentación reemplaza pruebas?**

No. Permite explicar el recorrido; las verificaciones aportan evidencia repetible más allá de la demo.

**¿Qué hago si falla internet?**

Utiliza un recorrido local preparado y declara qué parte de producción no se pudo verificar en ese momento.

**¿Cómo explico una limitación sin esconder un bug?**

Compárala con el contrato: lo excluido o acotado debe estar documentado; una garantía prometida que falla es un defecto.

## Para profundizar

[[Proyecto/5. Evaluacion y entregables|Rúbrica y entregables]] · [[Proyecto/4. Arquitectura vertical y contratos|Contratos del proyecto]].

## Conceptos clave de esta clase

- **Demo:** Recorrido preparado que muestra comportamiento observable de una versión.
- **Alcance:** Comportamientos incluidos y excluidos del producto.
- **Limitación:** Condición reconocida bajo la que opera la versión actual.
- **Defensa técnica:** Explicación razonada de decisiones y garantías del trabajo.
- **Retrospectiva:** Revisión de la colaboración para proponer mejoras comprobables.
- **Trazabilidad:** Relación entre requisito, cambio, prueba y resultado.

## Conexiones

[[Proyecto/5. Evaluacion y entregables|Rúbrica]] · [[README|Mapa completo del curso]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]


---

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 19|Clase 19]]

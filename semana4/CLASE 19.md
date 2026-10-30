---
tipo: clase
clase: 19
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 19 — IA II - Depuración y revisión con OpenCode

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 18|Clase 18]] · [[semana4/CLASE 20|Clase 20]] →

> [!abstract] Objetivo
> Depurar con evidencia y evaluar código generado sin delegar el criterio técnico.

## Antes de empezar

Repasa [[semana4/CLASE 18|Clase 18]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Depuración dirigida

1. Reproducir el error con datos sintéticos.
2. Describir esperado y obtenido, status HTTP y pasos mínimos.
3. Pedir hipótesis y una comprobación para cada una.
4. Ejecutar la comprobación y descartar hipótesis sin evidencia.
5. Aplicar la corrección mínima y probar regresiones.

Ejemplo de prompt:

```text
La API devuelve 409 al reservar una mesa que parece libre.
Estos son el contrato, un request anonimizado y el esquema de Reserva.
No cambies la restricción única para hacer pasar la prueba.
Explica si la interfaz está desactualizada o si el servidor aplica mal la regla.
Propón una prueba que reproduzca el fallo antes de modificar código.
```

No enviar registros con datos personales, tokens, cookies ni URLs privadas. Los errores del modelo también incluyen APIs inexistentes, imports incorrectos y versiones mezcladas. Verificar contra documentación oficial y contra el proyecto real.

### Ejercicio de revisión con o sin cuota

Este código es deliberadamente incorrecto; **no debe copiarse a la aplicación**:

```ts
// Pseudocódigo defectuoso para revisión, no implementación.
async function createSale(body: { totalCents: number; userId: string }) {
  return database.sale.create({ data: body });
}
```

Problemas: confía en total y actor del cliente; no tiene guard, validación, líneas, precios históricos ni idempotencia. En parejas, escribir el contrato correcto, enumerar controles y diseñar pruebas. Este ejercicio permite completar los mismos objetivos si NVIDIA no responde o agotó la cuota.

### Revisar un PR asistido

| Revisar | Evidencia |
| --- | --- |
| Alcance | Solo modifica la funcionalidad acordada |
| Contratos | Request y response siguen documentados |
| Seguridad | Guards, selección pública y origen conservados |
| Datos | Migraciones justificadas, reglas atómicas |
| Pruebas | Detectan un caso que fallaba antes |
| Comprensión | El autor explica el cambio sin leer la respuesta de la IA |

La IA no aprueba su propio trabajo. Un compañero revisa y el instructor integra. Ejecutar `lint`, `typecheck`, tests y build, además del flujo manual afectado. Si la herramienta modifica archivos ajenos, revisar y revertir solo esos cambios propios mediante Git, conservando el trabajo del compañero.

### Cierre antes de las demos

Corregir los bloqueantes del día 16, comprobar la URL final y congelar funcionalidades nuevas. Registrar las limitaciones conocidas con honestidad. La función opcional de IA dentro del producto no forma parte de la nota obligatoria.

## Práctica guiada

Revisar el PR asistido de otro equipo e identificar una mejora o un defecto verificable.

## Tarea para casa

Preparar demo y evidencia de pruebas. Adjuntar al PR un resumen breve del uso de IA y decisiones humanas.

## Criterios de finalización

- [ ] Puedes explicar cada cambio.
- [ ] La prueba no se debilitó para aprobar.
- [ ] El proyecto desplegado está listo para demo.

## Conexiones

[[semana4/CLASE 18|Clase 18]] · [[Proyecto/5. Evaluacion y entregables|Evaluación individual]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[semana4/0 INDICE|Semana 4]] · ← [[semana4/CLASE 18|Clase 18]] · [[semana4/CLASE 20|Clase 20]] →

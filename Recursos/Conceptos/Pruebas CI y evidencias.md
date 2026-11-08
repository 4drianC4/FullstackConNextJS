---
tipo: concepto
tags:
  - curso/conceptos
---

# Pruebas, CI y evidencias

[[Semana2/CLASE 10|Pruebas de backend]] · [[semana4/CLASE 16|E2E]] · [[semana4/CLASE 17|CI y entrega]]

## Cada control responde una pregunta

Lint observa reglas estáticas; TypeScript observa tipos del código conocido; unitarias observan funciones; integración observa colaboración real; E2E observa recorridos externos; build observa construcción del artefacto. Una colección de indicadores verdes es útil si conocemos sus límites.

CI ejecuta controles en un entorno automatizado. No crea por sí sola un sistema de calidad. Si el job solo ejecuta pruebas puras, no afirma nada sobre una base real o el flujo de login. Para agregar integración, preparar servidor, migraciones, fixtures y variables sin secretos productivos.

## Afirmaciones proporcionadas a evidencia

| Evidencia | Puedes afirmar | No puedes concluir todavía |
| --- | --- | --- |
| Esquema rechaza capacidad cero | Ese caso de validación funciona | La API llama al esquema |
| Endpoint rechaza STAFF | Ese permiso de integración funciona | Todos los endpoints están protegidos |
| Flujo E2E crea y lista un evento | Ese recorrido funciona en ese entorno | Producción tiene las mismas variables |
| Build correcto | Se generó el artefacto | Migraciones y credenciales productivas están correctas |
| Smoke test en producción | Recorridos observados funcionan en la versión entregada | Ausencia de cualquier bug |

Escribir límites no debilita el trabajo. Evita convertir una comprobación parcial en una promesa que el siguiente compañero no puede sostener.

## Preparación reproducible

El lockfile fija un árbol resuelto y npm ci lo instala. Las migraciones reconstruyen estructura; el seed de test prepara datos. Variables y versiones documentadas completan el contexto. Si una prueba requiere un evento abierto con una plaza, debe preparar ese estado sin depender de lo que otro alumno haya hecho.

No limpies tablas productivas desde una suite. Los tests que modifican datos necesitan una base identificada y aislada. Los artefactos pueden contener información visible o red; utiliza fixtures sintéticos y revisa lo que publicas.

## Regresiones y fallos intermitentes

Un test que a veces pasa puede estar observando condiciones mal controladas: orden, hora actual, datos compartidos, red o esperas fijas. Repetir hasta que pase no demuestra corrección. Identifica la condición y reemplaza la suposición por una preparación o espera explícita.

Cuando arreglas un bug, busca una reproducción que falle antes y pase después. No cambies el esperado para adaptarlo a una salida defectuosa sin justificar el nuevo comportamiento del producto.

## Entrega y recuperación

Después de integrar, el despliegue configura runtime, base y origen. Aplica migraciones de forma controlada y verifica login, permiso, escritura y lectura. No confundas entorno preview con privado ni lo apuntes a una base que no debe modificarse.

Volver a código anterior no borra columnas, revierte datos ni restaura un backup. Diseña cambios compatibles por etapas y planifica recuperación de datos según el riesgo real. En el MVP no hay información real, pero las instrucciones deben enseñar a distinguir esas responsabilidades.

[Vitest](https://vitest.dev/guide/) · [Playwright webServer](https://playwright.dev/docs/test-webserver) · [GitHub Actions](https://docs.github.com/en/actions).

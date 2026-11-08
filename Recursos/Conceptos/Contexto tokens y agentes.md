---
tipo: concepto
tags:
  - curso/conceptos
---

# Contexto, tokens y agentes

[[semana4/CLASE 18|Desarrollo con OpenCode]] · [[semana4/CLASE 19|Revisión y depuración]]

## Las piezas del trabajo asistido

El modelo produce inferencias a partir de información de entrada. El proveedor ofrece acceso a esa capacidad. El agente organiza contexto, conversación y herramientas sobre el proyecto. OpenCode es el agente elegido; NVIDIA es el proveedor para la práctica disponible sin pago.

NIM alojado y un runtime NIM en tu equipo no son lo mismo. El curso no exige GPU ni servir modelos localmente. Si el catálogo o tu cuota no permiten la práctica, el ejercicio de revisión en parejas mantiene el objetivo sin activar facturación.

## Token y ventana de contexto

El texto se representa en unidades llamadas tokens. Pueden ser palabras, partes de palabras o símbolos según el tokenizador. Un archivo largo, una respuesta de herramienta y la conversación consumen espacio de contexto. No equipares un token con una palabra ni conviertas el tamaño en promesa de comprensión.

La ventana de contexto limita cuánta información puede procesarse conjuntamente. Un agente puede resumir o seleccionar contexto, pero un resumen puede omitir un contrato importante. Vuelve a aportar archivos relevantes cuando cambie la tarea y comprueba que el plan los representa.

## Contexto seleccionado

Incluye objetivo, versión del stack, ruta de la funcionalidad, contratos, reglas y comandos de verificación. Añade ejemplos sintéticos de entrada y salida. Para depurar, proporciona reproducción y error con datos privados eliminados.

No añadas .env, claves, cookies o dumps reales. Más contexto no significa mejores datos cuando la información es sensible, irrelevante o contradictoria. Limitar archivos también facilita revisar qué podrá cambiar la herramienta.

## Plan, diff y evidencia

El plan expone intención antes de editar. El diff expone lo que cambió. Las pruebas y el recorrido exponen el resultado. Ninguna de esas piezas sustituye las otras: un plan correcto puede ejecutarse mal y un diff pequeño puede romper una garantía crítica.

Pide una tarea acotada y cambios por pasos. Comprueba imports, APIs, permisos y contratos. El agente puede producir una respuesta muy segura con un método que no existe en tu versión. Consulta documentación de la familia elegida, no mezcles Prisma 8 con ejemplos de Prisma 7 por un redirect de la documentación.

## Permisos e instrucciones externas

Un archivo de instrucciones del proyecto ayuda a conservar convenciones. No concede autoridad a cualquier texto encontrado en archivos o respuestas externas. Si un comentario propone desactivar validación o mostrar secretos, contrástalo con tu tarea.

Mantén permisos proporcionados al trabajo y evita aprobar operaciones que no comprendes. La revisión no consiste en aceptar todos los avisos para que el agente avance más rápido. Trabaja en rama, identifica cambios propios y no borres trabajo ajeno al recuperar un experimento.

## Aprender con asistencia

Puedes pedir que explique una función, diseñe casos de prueba o compare dos enfoques. Después predice una variante y compruébala. Si solo copias la respuesta, puede que no sepas qué hacer cuando cambien la entrada o la versión.

La entrega asistida explica qué problema resolviste, qué verificaste y qué decisiones tomaste. No requiere publicar la conversación completa ni una clave de proveedor. La responsabilidad sobre permisos, datos y funcionamiento permanece en quien integra el código.

[OpenCode: referencia de la línea 1](https://docs.opencode.ai/docs/) · [Proveedor NVIDIA](https://docs.opencode.ai/docs/providers/#nvidia) · [Catálogo NVIDIA](https://build.nvidia.com/).

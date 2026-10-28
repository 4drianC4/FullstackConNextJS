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

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[semana4/CLASE 17|Clase 17]] · [[semana4/CLASE 19|Clase 19]] →

> [!abstract] Objetivo
> Usar OpenCode con un proveedor NVIDIA disponible sin depender de una suscripción de pago.

## Antes de empezar

Repasa [[semana4/CLASE 17|Clase 17]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Herramienta, proveedor y modelo

**OpenCode** es el agente de programación que trabaja con el repositorio. **NVIDIA** proporciona inferencia; el modelo elegido responde. No son tres nombres de la misma herramienta. No se requiere OpenAI ni una suscripción de ChatGPT.

Usaremos los endpoints alojados de NVIDIA disponibles en su catálogo para desarrollo. Ejecutar NVIDIA NIM localmente es otra opción que puede requerir hardware/licencia/configuración adicional; no es requisito del curso.

### Preparación gratuita y reproducible

Esta guía utiliza la interfaz de OpenCode 1 documentada en [opencode.ai/docs](https://opencode.ai/docs/). No mezclar sus comandos de instalación con una instalación de OpenCode 2. Antes de la edición el instructor verifica versiones, acceso sin pago y cuotas; registra el resultado en [[Recursos/Stack y entorno|el checklist de preparación]].

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

## Práctica guiada

Configurar el proveedor, explicar un módulo y preparar un plan para una mejora pequeña.

## Tarea para casa

Implementar la mejora en rama propia. Documentar modelo, archivos cambiados, pruebas y una sugerencia que corregiste.

## Criterios de finalización

- [ ] Distingues OpenCode, proveedor y modelo.
- [ ] La práctica no requiere pagar.
- [ ] Revisaste el diff y no compartiste secretos.

## Conexiones

[[Recursos/Fullstack con IA/Programemos como si estuviéramos en la matrix... o quizá si estamos|Mapa de IA]] · [[semana4/CLASE 19|Clase 19]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[semana4/CLASE 17|Clase 17]] · [[semana4/CLASE 19|Clase 19]] →

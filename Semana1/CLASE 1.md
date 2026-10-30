---
tipo: clase
clase: 1
semana: 1
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/1
---

# Clase 1 — Introducción, entorno y trabajo colaborativo

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · [[Semana1/CLASE 2|Clase 2]] →

> [!abstract] Objetivo
> Comprender el proyecto, abrir los apuntes en Obsidian y colaborar mediante ramas y PR.

## Antes de empezar

Requisitos: JavaScript, HTML y CSS; terminal básica. No se presupone React ni TypeScript. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### El recorrido del curso

Primero construimos backend (semanas 1–2), después interfaz (semana 3) y finalmente integramos, desplegamos y trabajamos con IA (semana 4). No repasaremos JavaScript, HTML ni CSS.

Una petición recorre navegador → ruta HTTP → servicio de una funcionalidad → PostgreSQL → respuesta. En esta etapa no necesitamos construir componentes de React.

### Obsidian desde el primer día

Instala [Obsidian](https://obsidian.md/download), clona este repositorio y elige **Abrir carpeta como bóveda**. Abre `README.md`, después el índice de la semana. Activa enlaces salientes, backlinks, esquema y grafo local. No se necesitan plugins comunitarios para seguir el curso.

Los enlaces `[[nota|nombre legible]]` conectan temas; los bloques de información destacan objetivos y errores. Consulta [[Recursos/Obsidian - Guia del curso|Cómo recorrer y ampliar los apuntes]]. Los dibujos Excalidraw son complementarios y requieren su plugin si se quieren editar.

### Crear la aplicación del grupo

Este repositorio contiene apuntes, no la aplicación. El instructor crea **otro repositorio** para el código, siguiendo [[Recursos/Stack y entorno|las versiones y comandos comunes]]. Cada alumno trabaja en una funcionalidad vertical de la discoteca. El instructor integra un esqueleto vacío de carpetas y scripts; todavía no hay backend resuelto.

### Flujo mínimo de Git

```bash
git clone URL_DEL_REPOSITORIO_DE_APLICACION
cd discoteca
git switch main
git pull --ff-only
git switch -c feat/events-create
```

Después de trabajar: revisar `git diff`, seleccionar archivos, hacer commit y push. Abrir PR hacia `main`; un compañero revisa y el instructor integra. No usamos una rama `dev` adicional en este curso.

```bash
git add src/features/events
git commit -m "feat: agrega contrato de eventos"
git push -u origin feat/events-create
```

`git add` debe mencionar los archivos que realmente existan en la tarea. Ante un conflicto, hablar con quien modificó la misma zona y verificar el resultado; no aceptar ambas versiones sin leerlas.

## Práctica guiada

Abrir la bóveda; localizar proyecto, tareas e índice. Crear el repositorio de aplicación y el primer PR de documentación.

## Tarea para casa

Leer el proyecto, elegir funcionalidad y acordar compañeros. Instalar entorno y documentar cómo ejecutar el proyecto. No subir secretos.

## Criterios de finalización

- [ ] Puedes recorrer los apuntes mediante enlaces.
- [ ] Existe una rama y un PR revisable.
- [ ] Cada integrante identifica su tarea vertical.

## Conexiones

[[Recursos/Obsidian - Guia del curso|Obsidian]] · [[Proyecto/3. Guía de Contribución y Estándares del Proyecto|Contribución]] · [[Proyecto/2. Tareas por funcionalidad|Asignaciones]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[Semana1/0 INDICE|Semana 1]] · [[Semana1/CLASE 2|Clase 2]] →

---
tipo: clase
clase: 16
semana: 4
duracion_minutos: 90
proyecto: Discoteca
tags:
  - curso/fullstack
  - semana/4
---

# Clase 16 — Integración fullstack y pruebas de flujos

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[Semana3/CLASE 15|Clase 15]] · [[semana4/CLASE 17|Clase 17]] →

> [!abstract] Objetivo
> Verificar flujos completos y resolver fallos antes de preparar producción.

## Antes de empezar

Repasa [[Semana3/CLASE 15|Clase 15]] y completa su tarea. Consulta [[Recursos/Stack y entorno|Stack y entorno]] y [[Proyecto/1. Sistema de Gestion de Discoteca|Proyecto Discoteca]].

## Desarrollo de la clase

### Proteger la vista y la operación

Un layout puede redirigir al login para mejorar la experiencia, pero cada API y cada lectura privada de servidor vuelve a verificar permisos. No confiar exclusivamente en el layout: las navegaciones y cachés pueden reutilizarlo.

En una página de servidor leer sesión con `auth()` y usar `redirect("/login")` si falta. Antes de recuperar datos privados invocar el guard de la clase 9. Ocultar acciones administrativas según rol es UX, no una autorización adicional suficiente.

### Escenarios E2E

| Flujo | Resultado esperado |
| --- | --- |
| ADMIN crea evento y lo abre | STAFF puede consultarlo |
| STAFF intenta editar capacidad | Backend rechaza 403 |
| Personal emite entrada e ingresa dos veces | Segundo ingreso rechazado |
| Dos personas reservan la misma mesa/evento | Una reserva y un conflicto |
| Personal vende bebidas | Total del servidor y precios históricos |
| Cuenta desactivada mantiene cookie antigua | Próxima operación rechazada |
| API desconectada | Mensaje y opción de reintento |

El equipo de ventas debe probar la misma clave de petición dos veces; ni un doble clic ni un reintento deben duplicar la venta.

### Un flujo automatizado con Playwright

Instalar `@playwright/test`, instalar el navegador de pruebas y configurar `webServer` o una `baseURL` local. Usar base de prueba y credenciales locales de test, nunca producción.

```ts
// tests/login.spec.ts
import { test, expect } from "@playwright/test";
test("el personal inicia sesión", async ({ page }) => {
  const email = process.env.TEST_EMAIL;
  const password = process.env.TEST_PASSWORD;
  if (!email || !password) throw new Error("Faltan credenciales de prueba");
  await page.goto("/login");
  await page.getByLabel("Correo").fill(email);
  await page.getByLabel("Contraseña").fill(password);
  await page.getByRole("button", { name: "Entrar", exact: true }).click();
  await expect(page).toHaveURL(/\/dashboard/);
});
```

Acordar esos labels en el formulario real. Una prueba que solo abre login no verifica permisos: mantener además la matriz de peticiones directas del backend. Ampliar el flujo a crear y consultar un evento con fixtures aislados.

### Refactorizar con evidencia

Resolver errores primero, extraer lógica repetida cuando tenga el mismo significado y volver a ejecutar pruebas. No separar en diez archivos una función de cinco líneas sin necesidad. Abrir Issues con pasos, esperado, obtenido y evidencia sin datos privados.

## Práctica guiada

Intercambiar módulos entre equipos y registrar bugs reproducibles. Automatizar el login y un flujo del proyecto.

## Tarea para casa

Corregir bloqueantes, revisar responsive y preparar instrucciones de ejecución desde un clon limpio.

## Criterios de finalización

- [ ] Los escenarios críticos están probados.
- [ ] Un compañero puede ejecutar el módulo.
- [ ] No hay bloqueantes conocidos sin registrar.

## Conexiones

[[Semana2/CLASE 10|Clase 10]] · [[Proyecto/5. Evaluacion y entregables|Hito fullstack]] · [[Proyecto/4. Arquitectura vertical y contratos|Arquitectura vertical]] · [[Proyecto/5. Evaluacion y entregables|Evaluación y entregables]]

> [!tip] Distribución orientativa de los 90 minutos
> 10 min de repaso, 20 de explicación, 50 de práctica y 10 de cierre. El trabajo del módulo continúa en casa.

---

[[README|Inicio]] · [[semana4/INDICE|Semana 4]] · ← [[Semana3/CLASE 15|Clase 15]] · [[semana4/CLASE 17|Clase 17]] →

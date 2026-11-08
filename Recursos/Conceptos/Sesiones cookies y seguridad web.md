---
tipo: concepto
tags:
  - curso/conceptos
---

# Sesiones, cookies y seguridad web

[[Semana2/CLASE 8|Autenticación]] · [[Semana2/CLASE 9|Autorización]] · [[Semana3/CLASE 14|Login y formularios]]

## La identidad necesita continuidad

HTTP transporta peticiones; una aplicación necesita asociar algunas a una identidad ya autenticada. Una sesión proporciona esa continuidad durante un tiempo y bajo condiciones. Puede utilizar un ID opaco consultado en servidor o un token protegido. El curso utiliza la estrategia JWT de Auth.js y no implementa manualmente su criptografía.

El navegador guarda una cookie según dominio, path y reglas configuradas. Una cookie no es por definición segura ni insegura: importa qué contiene, cómo se verifica, cuándo se envía y cuándo deja de ser válida. No hay que enviar la contraseña en cada petición al panel.

## Propiedades de cookies

| Propiedad | Qué aporta | Qué no resuelve |
| --- | --- | --- |
| HttpOnly | Impide lectura mediante JS del navegador | No impide que un script malicioso actúe desde la página |
| Secure | Restringe envío a HTTPS en uso normal | No valida permisos del usuario |
| SameSite | Limita determinados envíos entre sitios | No reemplaza el análisis completo de CSRF/XSS |
| Expiración | Acota conservación o validez temporal | No refleja por sí sola una desactivación inmediata |

Origen y sitio no son conceptos idénticos. Un origen se define por esquema, host y puerto. SameSite emplea reglas de sitio del navegador, no una comparación literal de esos tres elementos. Para nuestras APIs de escritura usamos además una comprobación explícita de Origin.

## XSS y CSRF

XSS aparece cuando contenido no confiable termina ejecutándose como código en el contexto de tu página. Evita interpretar nombres o descripciones como HTML arbitrario. Que React escape texto ayuda, pero usar APIs de inserción de HTML cambia esa frontera y exige tratamiento específico.

CSRF intenta provocar una acción usando credenciales que el navegador adjunta automáticamente. Una página externa puede intentar originar un envío aunque no pueda leer la respuesta. Las mutaciones propias del curso comprueban origen además de sesión y permiso; los endpoints de Auth.js usan su protocolo y protecciones.

CORS regula determinados accesos de scripts del navegador a respuestas entre orígenes. No es una autorización de negocio y no garantiza impedir todos los envíos ni peticiones desde otras herramientas. «El navegador no dejó leer la respuesta» no equivale a «el servidor no ejecutó la acción».

## Estado vigente de la cuenta

La cookie identifica y el guard consulta la cuenta actual. Esto permite rechazar una cuenta desactivada o un rol cambiado antes de que expire el token. Para recursos privados de un usuario también se filtra propietario: un UUID desconocido no otorga privacidad por sí mismo.

Cerrar sesión limpia el flujo de acceso de esa sesión, pero administrar todas las sesiones y revocaciones globales es otra capacidad. No la atribuyas al MVP si no se implementó y probó.

## Cómo probar la frontera

Usa la misma operación sin sesión, con rol insuficiente, con cuenta desactivada y desde origen ajeno. Comprueba que no cambian los datos. No publiques cookies o tokens al pedir ayuda; una evidencia puede describir el estado y omitir el secreto.

[Guía de autenticación Next.js](https://nextjs.org/docs/app/guides/authentication) · [Auth.js](https://authjs.dev/getting-started/installation) · [Cookies en MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies).

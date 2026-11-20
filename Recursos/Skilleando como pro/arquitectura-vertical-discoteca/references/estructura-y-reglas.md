# Estructura y reglas de fronteras

## Por qué vertical slice con frontend/ y backend/

- **Aporte vertical por persona.** Cada integrante entrega datos + endpoint + pantalla del mismo comportamiento (`Proyecto/2`). Si el código se organizara por capas (`controllers/`, `components/`…), cada PR tocaría carpetas de todos los equipos y los conflictos se multiplicarían.
- **Dos apartados explícitos.** La secuencia del curso enseña backend (semanas 1–2) y luego frontend (semana 3). Separar `backend/` y `frontend/` dentro del módulo hace visible esa frontera y permite que `server-only` + ESLint la vigilen.
- **Contrato en la raíz.** El esquema Zod es lo único que cruza: el formulario lo usa con `zodResolver`, el controlador lo vuelve a validar. Al ser puro, importarlo desde el cliente no arrastra Prisma al bundle.
- **Monolito.** Un solo `package.json`, un solo build, un solo despliegue en Vercel / imagen Docker. Las fronteras son de carpetas, no de procesos.

## Anatomía de un módulo

```text
src/features/<modulo>/
├─ <entidad>.schema.ts        # contrato puro (zod + tipos)
├─ <entidad>.schema.test.ts
├─ backend/
│  ├─ <entidad>.controller.ts # server-only; un export por verbo HTTP
│  ├─ <entidad>.service.ts    # server-only; reglas + Prisma
│  └─ <entidad>.service.test.ts (integración, base de test)
└─ frontend/
   ├─ <entidad>-api.ts        # fetch tipado (cliente)
   ├─ <entidad>-form.tsx
   ├─ <entidad>-list.tsx
   └─ <modulo>-panel.tsx      # compone y coordina (revision/onSaved)
```

Módulos con dos entidades (`drinks`: category + drink; `reservations`: table + reservation) repiten el trío por entidad dentro de las mismas carpetas: `category.schema.ts`, `backend/category.service.ts`, `frontend/category-form.tsx`, etc.

Si `frontend/` supera ~8 archivos, se permite subdividir en `frontend/components/` y `frontend/hooks/`; no antes.

## Hacer cumplir las fronteras con ESLint

`create-next-app@16` genera `eslint.config.mjs` con un array. Añade estos objetos al final, sin borrar lo existente:

```js
// eslint.config.mjs
import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const serverOnlyInfra = [
  "@/shared/lib/prisma", "@/shared/lib/access", "@/shared/lib/origin",
  "@/shared/lib/api-error", "@/auth", "@/generated/**",
];

export default defineConfig([
  ...nextVitals,
  ...nextTs,
  globalIgnores([".next/**", "out/**", "build/**", "next-env.d.ts", "src/generated/**"]),

  // 1. El frontend no toca backend ni infraestructura de servidor ni UI de otros módulos.
  {
    files: ["src/features/*/frontend/**/*.{ts,tsx}"],
    rules: {
      "no-restricted-imports": ["error", { patterns: [
        { group: ["**/backend", "**/backend/**"], message: "El frontend no importa backend: usa el contrato (*.schema.ts) o la API HTTP." },
        { group: serverOnlyInfra, message: "Infraestructura de servidor: prohibida en frontend." },
        { group: ["@/features/*/frontend/**", "../../*/frontend/**"], message: "No importes la UI de otro módulo; súbela a src/shared/ui si es común." },
      ] }],
    },
  },

  // 2. El backend no importa UI.
  {
    files: ["src/features/*/backend/**/*.ts"],
    rules: {
      "no-restricted-imports": ["error", { patterns: [
        { group: ["**/frontend", "**/frontend/**", "@/shared/ui/**"], message: "El backend no importa componentes." },
      ] }],
    },
  },

  // 3. El contrato es puro.
  {
    files: ["src/features/*/*.schema.ts"],
    rules: {
      "no-restricted-imports": ["error", { patterns: [
        { group: ["**/backend/**", "**/frontend/**", ...serverOnlyInfra], message: "Un contrato solo importa zod y otros contratos." },
      ] }],
    },
  },

  // 4. shared no depende de features.
  {
    files: ["src/shared/**/*.{ts,tsx}"],
    rules: {
      "no-restricted-imports": ["error", { patterns: [
        { group: ["@/features/**"], message: "shared es transversal: no conoce módulos." },
      ] }],
    },
  },
]);
```

Si tu plantilla de `eslint.config.mjs` difiere (cambia entre versiones de `eslint-config-next`), conserva sus imports y añade solo los cuatro objetos. Prueba la regla creando temporalmente un import prohibido y ejecutando `npm run lint`.

Segunda red: `import "server-only"` en todo archivo de `backend/` y en `shared/lib/{prisma,access,origin}.ts` hace fallar el build si un Client Component los alcanza.

## Dependencias reales entre módulos

```text
users ◄── (actor de sesión) ── todos
events ◄── admissions (aforo, estado OPEN)
events ◄── reservations (evento futuro)
drinks ◄── bar-sales (precio y disponibilidad)
```

- Las FK se mantienen; no se eliminan para "aparentar independencia".
- `admissions` y `bar-sales` hacen la escritura condicional en **su** servicio y dentro de **su** transacción (p. ej. `tx.event.updateMany({ where: { id, status: "OPEN", admissionCount: { lt: capacity } } … })`). Eso es acceso a una tabla ajena acordado en el contrato, no una llamada al servicio de eventos.
- Para lecturas simples de otro módulo se puede importar una función de su `backend/*.service.ts` desde otro `backend/`. Nunca desde `frontend/`.
- Mientras otro equipo no termina: usar el seed y fixtures compatibles con el contrato, marcados como simulados.

## Errores típicos que esta estructura evita

| Síntoma | Causa | Corrección |
| --- | --- | --- |
| `server-only` rompe el build | Un componente `"use client"` importa un servicio | Mover la lectura a un Server Component o usar `*-api.ts` |
| El bundle incluye Prisma | El contrato importa `@/generated/prisma` para un enum | Declarar el enum con `z.enum([...])` en el contrato |
| Un STAFF crea eventos | Se ocultó el botón pero no hay `requireRoles` | Guard en el controlador, siempre |
| `role: "ADMIN"` aceptado | Esquema sin `.strict()` o body pasado a `data` | `.strict()` y construir `data` campo a campo |
| Lógica en `app/api/.../route.ts` | Atajo | `route.ts` solo re-exporta del controlador |
| Formulario vacía datos tras un 409 | `reset()` antes de comprobar `response.ok` | `fetchJson` lanza en no-OK; resetear solo en éxito |
| Página llama `fetch("http://localhost:3000/api/...")` | Fetch del servidor contra sí mismo | Server Component llama al servicio tras `requirePageRoles` |

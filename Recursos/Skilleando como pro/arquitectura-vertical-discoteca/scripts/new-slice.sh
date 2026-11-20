#!/usr/bin/env bash
# Genera el esqueleto de un módulo vertical (contrato + backend + frontend + ruta API).
# Uso (desde la raíz del repositorio de aplicación):
#   bash <ruta-skill>/scripts/new-slice.sh <modulo-plural-kebab> <entidad-singular-kebab>
# Ejemplos:
#   bash new-slice.sh bar-sales bar-sale
#   bash new-slice.sh reservations reservation
# No sobrescribe archivos existentes.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Uso: $0 <modulo-plural-kebab> <entidad-singular-kebab>" >&2
  exit 1
fi

module="$1"
entity="$2"
kebab='^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
[[ "$module" =~ $kebab && "$entity" =~ $kebab ]] || { echo "Usa kebab-case en minúsculas." >&2; exit 1; }
[[ -f package.json && -d src ]] || { echo "Ejecuta desde la raíz del repo de aplicación (package.json + src/)." >&2; exit 1; }

pascal() { perl -pe 's/(^|-)([a-z0-9])/\U$2/g' <<<"$1"; }
camel()  { perl -pe 's/-([a-z0-9])/\U$1/g' <<<"$1"; }

Entity="$(pascal "$entity")"      # BarSale
Entities="$(pascal "$module")"    # BarSales
entityCamel="$(camel "$entity")"  # barSale
prismaModel="$entityCamel"        # prisma.barSale (ajusta si el modelo se llama distinto)

base="src/features/$module"
mkdir -p "$base/backend" "$base/frontend" "src/app/api/$module"

write() { # write <ruta> ; contenido por stdin
  if [[ -e "$1" ]]; then echo "  = existe, se omite: $1"; cat >/dev/null; else cat >"$1"; echo "  + $1"; fi
}

write "$base/$entity.schema.ts" <<EOF
import { z } from "zod";

// TODO: campos que el cliente PUEDE enviar. Nunca actor, totales, contadores ni roles.
export const create${Entity}Schema = z.object({
  name: z.string().trim().min(1).max(100),
}).strict();
export type Create${Entity}Input = z.infer<typeof create${Entity}Schema>;

export const ${entityCamel}IdSchema = z.uuid();

// TODO: forma pública de la respuesta (fechas como string ISO).
export const ${entityCamel}DtoSchema = z.object({
  id: z.string(),
  name: z.string(),
});
export const ${entityCamel}ListSchema = z.array(${entityCamel}DtoSchema);
export type ${Entity}Dto = z.infer<typeof ${entityCamel}DtoSchema>;
EOF

write "$base/$entity.schema.test.ts" <<EOF
import { describe, expect, it } from "vitest";
import { create${Entity}Schema } from "./$entity.schema";

describe("create${Entity}Schema", () => {
  it("rechaza campos no permitidos", () => {
    expect(create${Entity}Schema.safeParse({ name: "x", id: "forzado" }).success).toBe(false);
  });
});
EOF

write "$base/backend/$entity.service.ts" <<EOF
import "server-only";
import { prisma } from "@/shared/lib/prisma";
import type { Create${Entity}Input } from "../$entity.schema";

// TODO: ajustar al modelo real de prisma/schema.prisma. Select público siempre.
const public${Entity} = { id: true, name: true } as const;

export function list${Entities}() {
  return prisma.${prismaModel}.findMany({ select: public${Entity}, take: 50 });
}

export function create${Entity}(input: Create${Entity}Input) {
  // Construir data campo a campo; nunca pasar el body completo.
  return prisma.${prismaModel}.create({ data: { name: input.name }, select: public${Entity} });
}
EOF

write "$base/backend/$entity.controller.ts" <<EOF
import "server-only";
import { create${Entity}Schema } from "../$entity.schema";
import { create${Entity}, list${Entities} } from "./$entity.service";
import { requireRoles } from "@/shared/lib/access";
import { requireSameOrigin } from "@/shared/lib/origin";
import { apiError } from "@/shared/lib/api-error";

// TODO: roles según la matriz de permisos de Proyecto/4.
export async function get${Entities}() {
  try {
    await requireRoles(["ADMIN", "STAFF"]);
    return Response.json(await list${Entities}());
  } catch (error: unknown) { return apiError(error); }
}

export async function post${Entity}(request: Request) {
  try {
    await requireRoles(["ADMIN"]);
    requireSameOrigin(request);
    const input = create${Entity}Schema.parse(await request.json());
    return Response.json(await create${Entity}(input), { status: 201 });
  } catch (error: unknown) { return apiError(error); }
}
EOF

write "src/app/api/$module/route.ts" <<EOF
export { get${Entities} as GET, post${Entity} as POST } from "@/features/$module/backend/$entity.controller";
EOF

write "$base/frontend/$entity-api.ts" <<EOF
import { fetchJson } from "@/shared/lib/api-client";
import { ${entityCamel}DtoSchema, ${entityCamel}ListSchema, type Create${Entity}Input } from "../$entity.schema";

export function fetch${Entities}(signal?: AbortSignal) {
  return fetchJson("/api/$module", ${entityCamel}ListSchema, { signal });
}

export function submit${Entity}(input: Create${Entity}Input) {
  return fetchJson("/api/$module", ${entityCamel}DtoSchema, { method: "POST", body: JSON.stringify(input) });
}
EOF

write "$base/frontend/$entity-list.tsx" <<EOF
"use client";
import { useEffect, useState } from "react";
import type { ${Entity}Dto } from "../$entity.schema";
import { fetch${Entities} } from "./$entity-api";

export function ${Entity}List({ revision }: { revision: number }) {
  const [items, setItems] = useState<${Entity}Dto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true); setError("");
    fetch${Entities}(controller.signal)
      .then((data) => { if (!controller.signal.aborted) setItems(data); })
      .catch((err: unknown) => {
        if (!controller.signal.aborted) setError(err instanceof Error ? err.message : "Error de conexión");
      })
      .finally(() => { if (!controller.signal.aborted) setLoading(false); });
    return () => controller.abort();
  }, [revision]);

  if (loading) return <p role="status">Cargando…</p>;
  if (error) return <p role="alert">{error}</p>;
  if (items.length === 0) return <p>No hay registros.</p>;
  return <ul>{items.map((item) => <li key={item.id}>{item.name}</li>)}</ul>;
}
EOF

write "$base/frontend/$module-panel.tsx" <<EOF
"use client";
import { useState } from "react";
import { ${Entity}List } from "./$entity-list";

// TODO: añadir ${Entity}Form (React Hook Form + zodResolver(create${Entity}Schema)) y llamar onSaved.
export function ${Entities}Panel() {
  const [revision, setRevision] = useState(0);
  return (
    <section className="grid gap-6">
      <h1 className="text-2xl font-semibold">${Entities}</h1>
      <button type="button" onClick={() => setRevision((r) => r + 1)}>Actualizar</button>
      <${Entity}List revision={revision} />
    </section>
  );
}
EOF

mkdir -p "src/app/dashboard/$module"
write "src/app/dashboard/$module/page.tsx" <<EOF
import { requirePageRoles } from "@/shared/lib/access";
import { ${Entities}Panel } from "@/features/$module/frontend/$module-panel";

export default async function ${Entities}Page() {
  await requirePageRoles(["ADMIN", "STAFF"]);
  return <${Entities}Panel />;
}
EOF

echo "Listo. Revisa los TODO, ajusta el modelo Prisma (prisma.${prismaModel}) y ejecuta: npm run lint && npm run typecheck"

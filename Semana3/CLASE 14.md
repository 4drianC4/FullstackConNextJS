# Día 14: Frontend IV - Integración (Lectura de Datos)

## 1. El Dilema: ¿Dónde pedir los datos? (Server vs. Client Fetching)

En Next.js App Router, tenemos dos estrategias principales para obtener información. Entender la diferencia es la clave para una aplicación de alto rendimiento.

### A. Fetching en Server Components (La opción recomendada)

Como vimos en el Día 11, los Server Components pueden hablar directamente con la base de datos o con tu API sin pasar por el navegador.

- **Cómo se hace:** Simplemente defines tu componente como `async` y usas `await fetch()` o incluso llamadas directas a **Prisma**.
    
- **Vacío Teórico:** Al hacer el fetch en el servidor, el usuario recibe el HTML ya con los datos. Esto es excelente para el SEO y elimina los "parpadeos" de carga. Además, las credenciales (como tokens de API) nunca viajan al navegador, lo que es mucho más seguro.
    

### B. Fetching en Client Components (TanStack Query)

A veces necesitas interactividad: buscadores en tiempo real, filtros dinámicos o datos que se actualizan cada 30 segundos sin recargar la página. Aquí es donde entra **TanStack Query** (antes conocido como React Query).

**¿Por qué no usar un simple `useEffect`?** Hacer un `fetch` dentro de un `useEffect` tiene muchos problemas:

1. **No hay Caché:** Si el usuario sale de la página y vuelve, tiene que esperar a que los datos se carguen de nuevo.
    
2. **"Race Conditions":** Si el usuario hace clic rápido en varios filtros, las respuestas de red pueden llegar en desorden y mostrar datos incorrectos.
    
3. **Manejo de estados manual:** Tienes que crear manualmente estados para `loading`, `error` y `data` cada vez.

---

# Día 17: Fullstack II - Refactorización y Clean Code

## 1. Identificación de "Code Smells" (Olores de Código)

### El Vacío Teórico: ¿Qué es un Code Smell?

Un _Code Smell_ no es un bug. Tu código compila, funciona y pasa los tests. Sin embargo, "huele mal". Es un indicador, una pista visual de que hay un problema de diseño subyacente que, si tu aplicación crece, se convertirá en un dolor de cabeza gigante (Deuda Técnica).

**Ejemplos clásicos de Code Smells en React/Next.js:**

1. **Componentes Dios (God Components):** Un archivo `page.tsx` que tiene 500 líneas de código, maneja peticiones a la base de datos, tiene 10 estados (`useState`) y renderiza toda la interfaz visual.
    
2. **Números o Strings Mágicos:** Ver un `if (status === 3)` en tu código. ¿Qué significa el 3? Nadie lo sabe.
    
3. **Código Duplicado:** Copiar y pegar el mismo bloque de validación de un formulario en tres páginas distintas.
    
4. **Código Flecha (Arrow Code):** Múltiples `if/else` anidados que hacen que tu código se vaya empujando hacia la derecha formando la punta de una flecha `>>>>`.
    

---

## 2. Refactorización de Componentes Grandes

El problema más común en el Frontend es meter toda la lógica y toda la vista en un solo lugar. Para solucionar el "Componente Dios", usamos un patrón clásico de React adaptado a la era moderna.

### Patrón Contenedor / Presentador (Separation of Concerns)

La regla es: **Un componente debe saber CÓMO se ven las cosas, o de DÓNDE vienen los datos, pero nunca ambas.**

### El Componente Dios (Antes de refactorizar):
```Typescript

export default function PerfilUsuario() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/user/me')
      .then(res => res.json())
      .then(data => { setUser(data); setLoading(false); });
  }, []);

  if (loading) return <div>Cargando el perfil súper complejo...</div>;

  return (
    <div className="bg-white p-10 rounded shadow-xl border">
      <h1 className="text-3xl font-bold text-blue-600">Perfil de {user.name}</h1>
      <p className="text-gray-500">{user.email}</p>
      {/* ... 100 líneas más de HTML ... */}
    </div>
  );
}
```

**Refactorizado (Separando responsabilidades):**

1. Creamos un **Componente Presentacional** (Solo le importa cómo se ve. Es "tonto", recibe datos por _props_):
```Typescript

// components/UI/UserCard.tsx
export const UserCard = ({ name, email }) => (
  <div className="bg-white p-10 rounded shadow-xl border">
    <h1 className="text-3xl font-bold text-blue-600">Perfil de {name}</h1>
    <p className="text-gray-500">{email}</p>
  </div>
);
```

2. Nuestro archivo principal se vuelve un **Componente Contenedor** (Solo le importa la lógica):
```Typescript

// app/profile/page.tsx
import { UserCard } from '@/components/UI/UserCard';
import { useQuery } from '@tanstack/react-query'; // Usamos lo aprendido en el Día 14

export default function PerfilUsuario() {
  const { data: user, isLoading } = useQuery({ queryKey: ['user'], queryFn: fetchUser });

  if (isLoading) return <div>Cargando...</div>;

  return <UserCard name={user.name} email={user.email} />;
}
```

---
## 3. Eliminación de Código Duplicado (DRY)

El principio **DRY (Don't Repeat Yourself)** es fundamental. En React, la mejor forma de extraer lógica duplicada que usa _Hooks_ es creando tus propios **Custom Hooks**.

Imagina que en 5 páginas distintas necesitas saber si el usuario hizo scroll hacia abajo para cambiar el color del menú superior. Si repites el `useEffect` de escuchar el scroll 5 veces, tienes un problema.

**La Refactorización (Creando un Custom Hook):**
```Typescript

// src/hooks/useScrollPosition.ts
import { useState, useEffect } from 'react';

export const useScrollPosition = () => {
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 50);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll); // Limpieza (Cleanup)
  }, []);

  return isScrolled; // El hook solo devuelve un booleano limpio
};
```
Ahora, en cualquier componente que lo necesite, solo escribes una línea: `const isScrolled = useScrollPosition();`

---
## 4. Mejores Prácticas: Early Returns (Retornos Tempranos)

Este es el truco más rápido para que tu código pase de verse "Junior" a "Senior". Consiste en eliminar los `else` innecesarios invirtiendo la lógica de los `if` y retornando la función lo antes posible.

**Código Flecha (Difícil de leer):**
```Typescript

const procesarPago = (usuario, monto) => {
  if (usuario != null) {
    if (usuario.isVerified) {
      if (monto > 0) {
        // Lógica de pago real
        return true;
      } else {
        throw new Error("El monto debe ser mayor a 0");
      }
    } else {
      throw new Error("Usuario no verificado");
    }
  } else {
    throw new Error("Usuario no encontrado");
  }
}
```

** Early Returns (Código plano y elegante):** Comprobamos los errores primero y "expulsamos" la ejecución. Si el código sobrevive a la barrera de `ifs`,sabemos que todo está correcto.
```
```
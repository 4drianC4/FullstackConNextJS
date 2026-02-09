# 🚀 Desarrollo Web Intermedio/Intro FullStack

**React • Tailwind CSS • Next.js**

Un curso intensivo de 3 semanas diseñado para dominar el desarrollo web moderno con enfoque en arquitectura, rendimiento y buenas prácticas.

---

## 📋 Descripción

Este curso va más allá de la sintaxis básica, enfocándose en **conceptos fundamentales**, **patrones de diseño** y **arquitectura de aplicaciones** reales. Aprenderás a construir aplicaciones web escalables y performantes utilizando el ecosistema más demandado de la industria.

### 🎯 Objetivos

- Dominar React con un enfoque en ciclo de vida y flujo de datos
- Construir interfaces profesionales con Tailwind CSS
- Desarrollar aplicaciones fullstack con Next.js
- Entender patrones de rendering (CSR, SSR, SSG)
- Implementar optimizaciones de rendimiento y SEO
- Desplegar aplicaciones en producción

---

## 📚 Contenido del Curso

### **Semana 1: Lógica Moderna y Arquitectura de Componentes**
*Enfoque: Entender el flujo de datos y el ciclo de vida, no solo la sintaxis*

#### **Lunes: JavaScript Moderno & Asincronía**
- Repaso ES6+ (Arrow functions, Destructuring)
- Spread/Rest Operators: Clonado de objetos y arrays (inmutabilidad)
- Promesas y Async/Await: Event Loop y manejo de errores con try/catch

#### **Martes: Pensamiento en React y Virtual DOM**
- JSX bajo el capó (¿en qué se convierte?)
- Componentes Puros vs Impuros
- Props Avanzados: `children` prop y composición de componentes
- Evitar el "prop drilling" excesivo

#### **Miércoles: Estado (useState) y Formularios**
- Inmutabilidad del estado
- Controlled Components: Manejo correcto de inputs y formularios complejos
- Renderizado Condicional: Operadores ternarios y `&&`

#### **Jueves: Efectos (useEffect) y Ciclo de Vida**
- Array de dependencias (cuándo se ejecuta y por qué)
- Cleanup Function: Evitar memory leaks
- Consumo de APIs: Patrones de carga (loading, error, data)

#### **Viernes: Context API y Hooks Personalizados**
- Context API: Estado global sin librerías externas (Theme, Auth)
- Custom Hooks: Extraer lógica repetitiva (ej. `useFetch`)

---

### **Semana 2: Ingeniería de UI con Tailwind CSS**
*Enfoque: Sistemas de diseño, mantenibilidad y configuración*

#### **Lunes: Fundamentos y Configuración**
- Filosofía Utility-First vs Component-Based
- Tailwind Config: Personalización de `tailwind.config.js`
- Directiva `@apply`: Cuándo usarla y cuándo no

#### **Martes: Layouts Avanzados (Flexbox & Grid)**
- Ejes (Main vs Cross)
- Grid Template Areas: Maquetar dashboards complejos
- Gap, Order y Z-Index

#### **Miércoles: Diseño Atómico y Componentes**
- Estrategias para nombrar y organizar componentes
- Pseudo-clases avanzadas: `group-hover`, `peer-checked`

#### **Jueves: Responsive Design y Mobile First**
- Breakpoints predeterminados vs personalizados
- Diseño Fluido: Medidas arbitrarias (`w-[350px]`) y `calc()`
- Estrategia para imágenes responsivas

#### **Viernes: Temas y Modo Oscuro**
- Estrategia `class` vs `media` para Dark Mode
- Animaciones: `animate-spin`, `transition`, `duration`
- Micro-interacciones UI

---

### **Semana 3: Next.js Ecosystem & Fullstack**
*Enfoque: Rendimiento, SEO y Arquitectura Servidor-Cliente*

#### **Lunes: App Router y Enrutamiento**
- Sistema de archivos como rutas
- Layouts Anidados: Persistir navegación entre páginas
- Metadata API: SEO dinámico (títulos, descripciones, Open Graph)

#### **Martes: Rendering Patterns (La teoría pesada)**
- **CSR** (Client Side Rendering) vs **SSR** (Server Side Rendering)
- **SSG** (Static Site Generation): Blogs y e-commerce
- Límites de los Server Components

#### **Miércoles: Optimización y Navegación**
- Componente `<Link>` y `useRouter`
- `next/image`: Optimización automática (Lazy loading, WebP/AVIF, CLS)
- `next/font`: Carga de fuentes sin layout shift

#### **Jueves: Backend Integrado (API Routes)**
- Creación de Endpoints REST
- Request/Response Helpers: `NextResponse`
- Variables de Entorno: `.env.local` (servidor vs cliente)

#### **Viernes: Despliegue (Deploy) y CI/CD**
- Flujo de trabajo con Git y Vercel
- Conceptos de CI/CD: Qué pasa cuando haces `git push`
- Vercel Analytics/Speed Insights: Monitoreo básico

---

## 🛠️ Tecnologías

| Tecnología   | Versión | Descripción                         |
| ------------ | ------- | ----------------------------------- |
| React        | 18+     | Librería para interfaces de usuario |
| Next.js      | 14+     | Framework React fullstack           |
| Tailwind CSS | 3+      | Framework CSS utility-first         |
| JavaScript   | ES6+    | Lenguaje de programación            |

---

## 📂 Estructura del Repositorio

```
📦 FullstackConNextJS
├── 📁 Semana 1/          # JavaScript Moderno & React Fundamentals
├── 📁 Semana 2/          # Tailwind CSS & UI Engineering
├── 📁 Semana 3/          # Next.js Fullstack
├── 📁 Recursos/          # Recursos adicionales y cheat sheets
├── 📁 Images/            # Imágenes y assets del curso
└── 📄 README.md          # Este archivo
```

---

## 🚀 Requisitos Previos

- Conocimientos básicos de HTML, CSS y JavaScript
- Node.js instalado (v18 o superior)
- Editor de código (VS Code recomendado)
- Git instalado
- Cuenta en GitHub
- Cuenta en Vercel (para deploy)

---

## 💡 Metodología de Aprendizaje

Este curso sigue una metodología **práctica y conceptual**:

1. **Teoría Profunda**: Entender el "por qué" detrás de cada concepto
2. **Práctica Guiada**: Ejercicios incrementales durante las sesiones
3. **Proyectos Reales**: Aplicaciones del mundo real en cada semana
4. **Best Practices**: Patrones de la industria desde el día 1

---

## 📖 Recursos Adicionales

- [Documentación oficial de React](https://react.dev)
- [Documentación oficial de Next.js](https://nextjs.org/docs)
- [Documentación oficial de Tailwind CSS](https://tailwindcss.com/docs)
- [MDN Web Docs](https://developer.mozilla.org)

---

## 👨‍💻 Contribuir

Si encuentras errores o tienes sugerencias para mejorar el contenido del curso:

1. Haz fork del repositorio
2. Crea una rama con tu feature (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m 'Añade nueva mejora'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

---

## 📝 Licencia

Este material educativo está disponible bajo la licencia MIT.

---

## 📧 Contacto

¿Preguntas o sugerencias? No dudes en abrir un issue en este repositorio.

---

**¡Feliz aprendizaje! 🎉**

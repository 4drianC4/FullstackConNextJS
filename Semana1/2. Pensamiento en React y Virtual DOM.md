>[!INFO] Objetivo de la Clase
>Dejar de escribir componentes "monoliticos" (todo en un archivo) y empezar a pensar en piezas de LEGO reutilizables. Entender qué hace React tras bambalinas para ser tan rápido

---

# 0. Configuración del Entorno (Vite)
Antes de entender la teoría, necesitamos un lugar donde trabajar. Ya no usamos `create-react-app` (es lento y pesado). El estándar moderno es **Vite**.

> [!CHECK] Requisito Previo
> Tener **Node.js** instalado (versión 18 o superior). 
> Comprobar en terminal: `node -v`

### Paso 1: Crear el proyecto
Abre tu terminal en la carpeta donde guardas tus proyectos y ejecuta:

```bash
npm create vite@latest mi-primer-react
# Selecciona: React
# Selecciona: JavaScript (o TypeScript si te animas, pero empezaremos con JS)
```
### Paso 2: Instalación de dependencias

Vite crea la carpeta vacía de módulos para ser rápido. Debemos instalarlos:
```Bash
cd mi-primer-react
npm install
npm run dev
```
### Paso 3: Limpieza inicial (Boilerplate)

Vite trae archivos de ejemplo que no necesitamos.
1. Ve a src/App.jsx.
2. Borra todo el contenido del return (...).
3. Déjalo así para empezar limpio:

```JavaScript

function App() {
  return (
    <div>
      <h1>Hola Mundo desde React</h1>
    </div>
  )
}
export default App
```

# 1. JSX Bajo el Capó (Under the hood)
JSX no es HTML. Los navegadores no entienden JSX. Necesitan un traductor (Babel/SWC) que convierte esas etiquetas en **Objetos de JavaScript**.

## Análisis de Código: La Transpilación

Lo que tú escribes:
```jsx
const elemento = (
  <h1 className="saludo">
    Hola, mundo!
  </h1>
);
```

Lo que React realmente ve (y ejecuta):

```jsx
const elemento = React.createElement(
'h1',                    // Tipo de etiqueta
  { className: 'saludo' }, // Props (atributos)
  'Hola, mundo!'           // Children (contenido)
);
```

Resultando en este objeto JS:
```JavaScript
const objeto = {
  type: 'h1',
  props: {
    className: 'saludo',
    children: 'Hola, mundo!'
  }
};
```
>[!NOTE] ¿Por qué importa esto?
>Porque demuestra que los componentes son solo objetos. Puedes pasarlos como variables, retornarlos en funciones o guardarlos en arrays. React compara estos objetos (Virtual DOM) para saber qué cambiar en la pantalla real.

# 2. Componentes Puros vs. Impuros

React se basa en el concepto de Funciones Puras (traído de la programación funcional).
## Regla de Oro de la Pureza

=="Para las mismas entradas (Props), siempre debe devolver la misma salida (JSX)".==

## Componente Impuro (Mala Práctica)

Este componente cambia cada vez que se renderiza, aunque las props no cambien. Esto causa bugs visuales y problemas de rendimiento.
```JavaScript
let invitados = 0; // Variable externa (Side Effect)

function CopaVino() {
  invitados = invitados + 1; // Modifica algo fuera de su scope
  return <h2>Copa para el invitado #{invitados}</h2>;
}
```
## Componente Puro

No depende de nada externo ni modifica nada fuera de él. Solo usa sus props.
```JavaScript
function CopaVino({ numeroInvitado }) {
  return <h2>Copa para el invitado #{numeroInvitado}</h2>;
}
```
>[!WARNING] Strict Mode
>¿Notaste que en desarrollo tus console.log salen dobles? Es el React Strict Mode. React renderiza tus componentes dos veces a propósito para detectar si son impuros. Si la UI se ve diferente entre el render 1 y el 2, tienes un componente impuro.

# 3. Props Avanzados: La prop children

Hasta ahora pasamos datos (nombre="Juan"). Pero, ¿cómo pasamos otros componentes o HTML dentro de un componente?

Imagina un marco de fotos. El marco no sabe qué foto pondrás dentro, pero la envuelve. Eso es children.
## Análisis de Código: El componente "Wrapper"
```JavaScript
// Definición del componente contenedor
function Tarjeta({ titulo, children }) {
  return (
    <div className="borde-negro p-4 shadow-lg">
      <h3 className="text-xl bold">{titulo}</h3>
      <div className="contenido-dinamico">
        {children} {/* Aquí se "imprime" lo que pongas dentro */}
      </div>
    </div>
  );
}

// Uso (Composición)
function App() {
  return (
    <main>
       {/* Caso A: Con texto */}
       <Tarjeta titulo="Bienvenida">
          <p>Hola a todos</p>
       </Tarjeta>

       {/* Caso B: Con formulario */}
       <Tarjeta titulo="Login">
          <input type="text" placeholder="Usuario" />
          <button>Entrar</button>
       </Tarjeta>
    </main>
  );
}
```
# 4. Evitar el "Prop Drilling" (Taladrado de Props)

El problema: Pasar un dato del Abuelo -> Padre -> Hijo -> Nieto, cuando solo el Nieto lo necesita. El Padre y el Hijo solo "pasan el paquete" sin usarlo.
## El Problema (Drilling)
```JavaScript
function App() {
  const usuario = { name: "Alex" };
  return <Navbar usuario={usuario} />; // App pasa a Navbar
}

function Navbar({ usuario }) {
  return <Avatar usuario={usuario} />; // Navbar pasa a Avatar (¡Navbar no usa usuario!)
}

function Avatar({ usuario }) {
  return <img src={usuario.avatar} />; // Avatar finalmente lo usa
}
```

## La Solución: Composición de Componentes

En lugar de pasar el dato, pasamos el componente ya armado como prop (generalmente como children o un prop personalizado).

```JavaScript

function App() {
  const usuario = { name: "Alex" };
  // App conecta directamente App -> Avatar. Navbar ya no estorba.
  return (
    <Navbar>
      <Avatar usuario={usuario} />
    </Navbar>
  );
}

function Navbar({ children }) {
  return (
    <nav className="barra-superior">
      <h1>Mi Logo</h1>
      {children} {/* Aquí renderiza el Avatar que le enviaron */}
    </nav>
  );
}
```

>[!TIP]
>No siempre necesitas Context API (que veremos después) para solucionar el Prop Drilling. A veces solo necesitas acomodar mejor tus componentes ("Lift Content Up").

# Practica del día

Objetivo: Crear un layout reutilizable usando children.

Instrucciones:

1. Crear un componente llamado Layout que tenga:
    - Un header fijo que diga "Mi App Increíble".
    - Un footer fijo que diga "Derechos Reservados 2024".
    - Un main en el centro que reciba children.

2. Crear dos "Páginas" (componentes simples): Home y Contacto.

3. Usar el Layout para envolver a Home y luego a Contacto.
   
4. Pregunta trampa: ¿El header se vuelve a crear (desmonta/monta) cuando cambiamos el contenido de children? (Respuesta teórica: React es inteligente y trata de mantener lo estático, pero depende de cómo gestionemos el estado).

Solución:
```JavaScript

const Layout = ({ children }) => (
  <div className="contenedor">
    <header>Mi App Increíble</header>
    <main style={{ minHeight: '80vh' }}>
      {children}
    </main>
    <footer>Derechos Reservados</footer>
  </div>
);

const App = () => (
  <Layout>
     <h1>Bienvenido al Home</h1>
     <button>Click</button>
  </Layout>
);
```
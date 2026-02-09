const usuario = {
    nombre: "Ana",
    edad: 28,
    ciudad: "Cochabamba",
    // un objeto anidado dentro de usuario
    redes: { twitter: "@ana" }
};

// // Forma vieja
// const nombre = usuario.nombre;
// const ciudad = usuario.ciudad;

// Forma moderna
// "Busca la propiedad 'nombre' y 'ciudad' dentro de usuario y crea variables"
const { nombre, ciudad } = usuario;

// También funciona con objetos anidados
const { twitter } = usuario.redes;

console.log(nombre);
console.log(ciudad);
console.log(twitter);
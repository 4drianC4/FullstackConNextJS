function sumarv1(a, b) {
    return a + b;
}

// JAVASCRIPT MODERNO (Arrow Function)
const sumarv2 = (a, b) => {
    return a + b;
}
// RETORNO IMPLÍCITO (La forma más común en React)
// "Si lo que sigue a la flecha es una expresión, retórnala automáticamente"
const sumarv3 = (a, b) => a + b;

console.log(sumarv1(2, 3));
console.log(sumarv2(2, 3));
console.log(sumarv3(2, 3));
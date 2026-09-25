// =============================================================================
//  datos.js - Carga el juego de datos del curso en la base de datos "tienda"
//
//  Desde el toolbox:   mongosh "$RS" /scripts/datos.js
//  Parámetro opcional: mongosh "$RS" --eval "var N_PEDIDOS=50000" /scripts/datos.js
//
//  Colecciones: clientes (5.000), productos (500), pedidos (200.000 por defecto)
//  Sin índices secundarios a propósito: los crearemos en los laboratorios.
// =============================================================================

const TOTAL_PEDIDOS = (typeof N_PEDIDOS !== "undefined") ? N_PEDIDOS : 200000;
const LOTE = 5000;
const tienda = db.getSiblingDB("tienda");

const ciudades = ["Madrid", "Barcelona", "Valencia", "Sevilla", "Bilbao", "Zaragoza",
                  "Málaga", "Murcia", "Palma", "Valladolid", "Vigo", "Alicante"];
const estados = ["pendiente", "pagado", "enviado", "entregado", "cancelado"];
const categorias = ["electrónica", "hogar", "deporte", "libros", "moda", "juguetes", "jardín"];

function azar(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function entero(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

print("Borrando datos anteriores de 'tienda'...");
tienda.dropDatabase();

// ---- clientes --------------------------------------------------------------
let docs = [];
for (let i = 1; i <= 5000; i++) {
  docs.push({
    _id: i,
    nombre: "Cliente " + i,
    email: "cliente" + i + "@ejemplo.com",
    ciudad: azar(ciudades),
    alta: new Date(Date.now() - entero(0, 1000) * 86400000),
    vip: Math.random() < 0.05
  });
}
tienda.clientes.insertMany(docs);
print("clientes: " + tienda.clientes.countDocuments());

// ---- productos -------------------------------------------------------------
docs = [];
for (let i = 1; i <= 500; i++) {
  docs.push({
    _id: i,
    nombre: "Producto " + i,
    categoria: azar(categorias),
    precio: Math.round(Math.random() * 50000) / 100,
    stock: entero(0, 1000)
  });
}
tienda.productos.insertMany(docs);
print("productos: " + tienda.productos.countDocuments());

// ---- pedidos ---------------------------------------------------------------
let insertados = 0;
while (insertados < TOTAL_PEDIDOS) {
  docs = [];
  const n = Math.min(LOTE, TOTAL_PEDIDOS - insertados);
  for (let i = 0; i < n; i++) {
    const nLineas = entero(1, 5);
    const lineas = [];
    let total = 0;
    for (let l = 0; l < nLineas; l++) {
      const precio = Math.round(Math.random() * 20000) / 100;
      const cantidad = entero(1, 4);
      total += precio * cantidad;
      lineas.push({ producto_id: entero(1, 500), cantidad: cantidad, precio: precio });
    }
    docs.push({
      cliente_id: entero(1, 5000),
      fecha: new Date(Date.now() - entero(0, 730) * 86400000 - entero(0, 86399) * 1000),
      estado: azar(estados),
      ciudad: azar(ciudades),
      total: Math.round(total * 100) / 100,
      lineas: lineas
    });
  }
  tienda.pedidos.insertMany(docs, { ordered: false });
  insertados += n;
  if (insertados % 50000 === 0 || insertados === TOTAL_PEDIDOS) print("pedidos: " + insertados);
}

print("Carga terminada.");
printjson(tienda.stats({ scale: 1024 * 1024 }));

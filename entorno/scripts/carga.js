// =============================================================================
//  carga.js - Genera carga de consultas variadas sobre "tienda"
//
//  Desde el toolbox:   mongosh "$RS" --quiet /scripts/carga.js
//  Duración por defecto 5 minutos. Para cambiarla:
//     mongosh "$RS" --quiet --eval "var MINUTOS=2" /scripts/carga.js
//
//  Mezcla consultas "buenas" y "malas" (sin índice) para que el profiler,
//  PMM Query Analytics y mongostat tengan algo interesante que mostrar.
// =============================================================================
const minutos = (typeof MINUTOS !== "undefined") ? MINUTOS : 5;
const fin = Date.now() + minutos * 60 * 1000;
const t = db.getSiblingDB("tienda");
const estados = ["pendiente", "pagado", "enviado", "entregado", "cancelado"];
const ciudades = ["Madrid", "Barcelona", "Valencia", "Sevilla", "Bilbao"];
function entero(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

let n = 0;
print("Generando carga durante " + minutos + " minutos...");
while (Date.now() < fin) {
  const tipo = n % 6;
  try {
    if (tipo === 0) {        // lectura por _id: rápida
      t.clientes.findOne({ _id: entero(1, 5000) });
    } else if (tipo === 1) { // SIN índice: pedidos de un cliente
      t.pedidos.find({ cliente_id: entero(1, 5000) }).toArray();
    } else if (tipo === 2) { // SIN índice: filtro por estado y ciudad, ordenado por fecha
      t.pedidos.find({ estado: estados[entero(0, 4)], ciudad: ciudades[entero(0, 4)] })
        .sort({ fecha: -1 }).limit(20).toArray();
    } else if (tipo === 3) { // agregación: facturación por ciudad
      t.pedidos.aggregate([
        { $match: { estado: "entregado" } },
        { $group: { _id: "$ciudad", total: { $sum: "$total" } } }
      ]).toArray();
    } else if (tipo === 4) { // escritura: actualizar stock
      t.productos.updateOne({ _id: entero(1, 500) }, { $inc: { stock: -1 } });
    } else {                 // escritura: nuevo pedido
      t.pedidos.insertOne({
        cliente_id: entero(1, 5000), fecha: new Date(), estado: "pendiente",
        ciudad: ciudades[entero(0, 4)], total: entero(10, 500), lineas: []
      });
    }
  } catch (e) {
    print("Error: " + e.message);
    sleep(1000);
  }
  n++;
  if (n % 500 === 0) print(new Date().toISOString() + "  operaciones: " + n);
}
print("Fin de la carga. Operaciones totales: " + n);

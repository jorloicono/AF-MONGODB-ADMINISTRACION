// =============================================================================
//  escritor.js - Simula una aplicación que escribe sin parar
//
//  Desde el toolbox:   mongosh "$RS" --quiet /scripts/escritor.js
//  Detener: Ctrl+C
//
//  Cada medio segundo inserta un documento en tienda.latidos y muestra
//  qué nodo es el primario. Durante un failover el driver espera a que haya
//  un nuevo primario (retryWrites + serverSelectionTimeoutMS), así que lo
//  normal NO es ver un error, sino una escritura que tarda varios segundos.
//  El script avisa de cualquier escritura lenta y de cualquier error.
// =============================================================================
const col = db.getSiblingDB("tienda").latidos;
let ultimoPrimario = "";

print("Escribiendo cada 500 ms. Pulsa Ctrl+C para parar.\n");
while (true) {
  const inicio = new Date();
  try {
    col.insertOne({ ts: inicio }, { writeConcern: { w: "majority", wtimeout: 5000 } });
    const ms = (new Date()) - inicio;
    if (ms > 1000) {
      print(inicio.toISOString() + "  ESCRITURA LENTA: " + (ms / 1000).toFixed(1) + " s (¿elección en curso?)");
    }
    const primario = db.hello().primary;
    if (primario !== ultimoPrimario) {
      print(new Date().toISOString() + "  PRIMARIO ACTUAL: " + primario);
      ultimoPrimario = primario;
    }
  } catch (e) {
    const ms = (new Date()) - inicio;
    print(inicio.toISOString() + "  ERROR tras " + (ms / 1000).toFixed(1) + " s (" +
          (e.codeName || e.name) + "): " + String(e.message).substring(0, 90));
  }
  sleep(500);
}

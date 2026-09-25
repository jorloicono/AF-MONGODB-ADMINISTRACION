// =============================================================================
//  .mongoshrc.js de ejemplo (Laboratorio 04)
//  mongosh lo carga automáticamente desde el directorio HOME del usuario.
//  Copia:  cp /scripts/.mongoshrc.js ~/.mongoshrc.js
// =============================================================================

// Prompt con rol del nodo, base de datos actual y hora
prompt = function () {
  let rol = "standalone";
  try {
    const h = db.hello();
    if (h.setName) rol = h.isWritablePrimary ? "PRIMARY" : (h.secondary ? "SECONDARY" : "OTHER");
  } catch (e) { rol = "?"; }
  const hora = new Date().toLocaleTimeString("es-ES");
  return rol + " " + db.getName() + " [" + hora + "]> ";
};

// Utilidad: tamaño de cada colección de la base de datos actual en MB
globalThis.tamanos = function () {
  db.getCollectionNames().forEach(function (c) {
    const s = db.getCollection(c).stats({ scale: 1024 * 1024 });
    print(c.padEnd(25) + " docs: " + String(s.count).padStart(9) +
          "   datos: " + String(s.size).padStart(6) + " MB" +
          "   disco: " + String(s.storageSize).padStart(6) + " MB" +
          "   índices: " + String(s.totalIndexSize).padStart(6) + " MB");
  });
};

// Utilidad: operaciones activas que llevan más de N segundos
globalThis.lentas = function (segundos) {
  return db.currentOp({ active: true, secs_running: { $gte: segundos || 1 } }).inprog
    .map(op => ({ opid: op.opid, seg: op.secs_running, ns: op.ns, op: op.op, cliente: op.client }));
};

print("Perfil del curso cargado. Funciones disponibles: tamanos(), lentas(segundos)");

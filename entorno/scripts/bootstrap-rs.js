// =============================================================================
//  bootstrap-rs.js - Puesta en marcha RÁPIDA del replica set del curso
//
//  Úsalo solo si llegas a los días 3 o 4 sin el entorno del día 2 o si
//  necesitas reconstruirlo desde cero. En el Laboratorio 05 lo hacemos a mano.
//
//  Se ejecuta DENTRO de mongo1 para aprovechar la "localhost exception":
//    docker compose exec mongo1 mongosh --quiet /scripts/bootstrap-rs.js
// =============================================================================

const cfg = {
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 },
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
};

const hello = db.hello();
if (!hello.setName) {
  print("Iniciando el replica set rs0...");
  printjson(rs.initiate(cfg));
} else {
  print("El replica set " + hello.setName + " ya existe (primario actual: " + (hello.primary || "en eleccion") + "). No hay nada que iniciar.");
  quit(0);
}

print("Esperando a que mongo1 sea PRIMARY...");
let esPrimario = false;
for (let i = 0; i < 60 && !esPrimario; i++) {
  esPrimario = db.hello().isWritablePrimary;
  if (!esPrimario) sleep(1000);
}
if (!esPrimario) {
  print("mongo1 no es PRIMARY. Revisa 'docker compose ps' y los logs de los tres nodos.");
  quit(1);
}

try {
  db.getSiblingDB("admin").createUser({
    user: "admin",
    pwd: "CursoMongo2026",
    roles: [{ role: "root", db: "admin" }]
  });
  print("Usuario 'admin' creado.");
} catch (e) {
  print("No se crea el usuario admin (" + e.codeName + "): probablemente ya existía.");
}
print("Listo. Entra en el toolbox con:  docker compose exec toolbox bash   y luego:  mongosh \"$RS\"");

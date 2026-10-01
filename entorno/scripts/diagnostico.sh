#!/bin/bash
# Diagnóstico del replica set nodo a nodo (no depende de que haya primario)
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/diagnostico.sh
for h in mongo1 mongo2 mongo3; do
  echo "================ $h"
  mongosh "mongodb://$h:27017/?directConnection=true&serverSelectionTimeoutMS=5000" --quiet --eval '
    const h = db.hello();
    printjson({ setName: h.setName, esPrimario: h.isWritablePrimary, secundario: h.secondary,
                primario: h.primary, miembros: h.hosts, info: h.info });' 2>&1 | tail -15
  mongosh "mongodb://admin:CursoMongo2026@$h:27017/?authSource=admin&directConnection=true&serverSelectionTimeoutMS=5000" --quiet --eval '
    try { rs.status().members.forEach(m => print("   " + m.name + "  " + m.stateStr + "  salud=" + m.health + "  " + (m.lastHeartbeatMessage || ""))); }
    catch (e) { print("   rs.status(): " + (e.codeName || e.message)); }' 2>&1 | tail -6
done

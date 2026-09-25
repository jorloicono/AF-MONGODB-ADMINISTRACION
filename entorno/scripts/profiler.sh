#!/bin/bash
# Activa el profiler (nivel 1, 50 ms) en la BD tienda de los tres nodos.
# Uso: docker compose exec toolbox bash /scripts/profiler.sh
for h in mongo1 mongo2 mongo3; do
  mongosh "mongodb://admin:CursoMongo2026@$h:27017/tienda?authSource=admin&directConnection=true" --quiet \
    --eval 'const r = db.setProfilingLevel(1, { slowms: 50 }); print(db.hello().me + " profiler activado")'
done

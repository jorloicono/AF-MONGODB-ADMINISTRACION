#!/bin/bash
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/primario.sh
mongosh "$RS" --quiet --eval 'print("Primario actual: " + db.hello().primary)'

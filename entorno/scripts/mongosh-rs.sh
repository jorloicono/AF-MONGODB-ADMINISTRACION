#!/bin/bash
# Abre mongosh contra el replica set como admin.
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/mongosh-rs.sh
exec mongosh "$RS" "$@"

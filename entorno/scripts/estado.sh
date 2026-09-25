#!/bin/bash
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/estado.sh
mongosh "$RS" --quiet /scripts/estado.js

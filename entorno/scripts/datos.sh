#!/bin/bash
# Carga los datos del curso. Uso: docker compose exec toolbox bash /scripts/datos.sh
mongosh "$RS" --quiet /scripts/datos.js

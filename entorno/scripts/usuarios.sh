#!/bin/bash
# Crea los usuarios de PBM y PMM. Uso: docker compose exec toolbox bash /scripts/usuarios.sh
mongosh "$RS" --quiet /scripts/usuarios-pbm-pmm.js

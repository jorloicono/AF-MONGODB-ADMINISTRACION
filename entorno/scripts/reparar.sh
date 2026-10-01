#!/bin/bash
# reparar.sh - Deja el replica set listo (inicio, admin, datos, tags, usuarios PBM/PMM)
# Se ejecuta DENTRO de mongo1 (necesita la localhost exception si el replica set es nuevo):
#   docker compose exec mongo1 bash /scripts/reparar.sh
RS="mongodb://admin:CursoMongo2026@mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0&authSource=admin"
echo "== 1/5 Replica set y usuario admin"
mongosh --quiet /scripts/bootstrap-rs.js
sleep 5
echo "== 2/5 Datos de tienda (solo si faltan)"
n=$(mongosh "$RS" --quiet --eval 'db.getSiblingDB("tienda").pedidos.estimatedDocumentCount()')
if [ "${n:-0}" -gt 0 ] 2>/dev/null; then echo "tienda.pedidos ya tiene $n documentos"; else mongosh "$RS" --quiet /scripts/datos.js | tail -3; fi
echo "== 3/5 Tags del laboratorio 06"
mongosh "$RS" --quiet /scripts/tags.js
echo "== 4/5 Usuarios de PBM y PMM"
mongosh "$RS" --quiet /scripts/usuarios-pbm-pmm.js
echo "== 5/5 Estado final"
mongosh "$RS" --quiet /scripts/estado.js
echo "== TERMINADO"

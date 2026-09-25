#!/bin/bash
# Bloquea o desbloquea las escrituras de un nodo concreto (laboratorio 11)
# Uso (desde tu equipo, carpeta entorno/):
#   docker compose exec toolbox bash /scripts/fsync.sh lock   mongo2
#   docker compose exec toolbox bash /scripts/fsync.sh unlock mongo2
ACCION="$1"
NODO="$2"
if [ -z "$NODO" ]; then echo "Uso: fsync.sh lock|unlock <nodo>"; exit 1; fi
URI="mongodb://admin:CursoMongo2026@${NODO}:27017/?authSource=admin&directConnection=true"
case "$ACCION" in
  lock)   mongosh "$URI" --quiet --eval 'printjson(db.fsyncLock())' ;;
  unlock) mongosh "$URI" --quiet --eval 'printjson(db.fsyncUnlock())' ;;
  *)      echo "Acción desconocida: $ACCION (usa lock o unlock)"; exit 1 ;;
esac

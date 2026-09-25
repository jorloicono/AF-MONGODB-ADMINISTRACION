#!/bin/bash
# Igual que mongosh-rs.sh, pero conectando con TLS (laboratorio 09)
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/mongosh-rs-tls.sh
exec mongosh "$RS&tls=true&tlsCAFile=/certs/ca.pem" "$@"

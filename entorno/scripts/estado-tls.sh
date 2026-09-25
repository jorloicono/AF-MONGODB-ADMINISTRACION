#!/bin/bash
# Igual que estado.sh, pero conectando con TLS (laboratorio 09, a partir de requireTLS)
# Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/estado-tls.sh
mongosh "$RS&tls=true&tlsCAFile=/certs/ca.pem" --quiet /scripts/estado.js

#!/bin/sh
# =============================================================================
#  gen-certs.sh - Crea una CA privada y los certificados del curso
#
#  Se ejecuta con:   docker compose run --rm certgen
#  Resultado (volumen "certs"):
#    ca.pem                      certificado de la CA
#    mongo1.pem mongo2.pem mongo3.pem   clave + certificado de cada nodo
#    client.pem                  clave + certificado del cliente x.509
#    client-subject.txt          subject del cliente (para crear el usuario)
#  SOLO PARA LABORATORIO: en producción usad la PKI de vuestra organización.
# =============================================================================
set -e
cd /certs

if [ -f ca.pem ]; then
  echo "Los certificados ya existen en el volumen. Para regenerarlos: docker volume rm curso-mongo_certs"
  exit 0
fi

echo "== Creando la CA del curso"
openssl req -x509 -newkey rsa:4096 -nodes -days 365 \
  -keyout ca.key -out ca.pem \
  -subj "/O=CursoMongo/CN=CursoMongo CA" 2>/dev/null

for n in mongo1 mongo2 mongo3; do
  echo "== Certificado del servidor $n"
  cat > $n.ext <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=DNS:$n,DNS:localhost,IP:127.0.0.1
EOF
  openssl req -newkey rsa:2048 -nodes -keyout $n.key -out $n.csr \
    -subj "/O=CursoMongo/OU=Servidores/CN=$n" 2>/dev/null
  openssl x509 -req -in $n.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
    -days 365 -out $n.crt -extfile $n.ext 2>/dev/null
  cat $n.key $n.crt > $n.pem
done

echo "== Certificado del cliente x.509 (appx509)"
cat > client.ext <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=clientAuth
EOF
openssl req -newkey rsa:2048 -nodes -keyout client.key -out client.csr \
  -subj "/O=CursoMongo/OU=Clientes/CN=appx509" 2>/dev/null
openssl x509 -req -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
  -days 365 -out client.crt -extfile client.ext 2>/dev/null
cat client.key client.crt > client.pem

openssl x509 -in client.crt -noout -subject -nameopt RFC2253 | sed 's/^subject=//' > client-subject.txt

rm -f *.csr *.ext *.srl
chmod 644 *.pem *.crt client-subject.txt
chmod 600 ca.key

echo "== Certificados generados:"
ls -l /certs
echo "== Subject del cliente x.509:"
cat client-subject.txt

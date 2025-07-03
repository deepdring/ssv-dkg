#!/bin/sh

# Setup directory for certificates
CERT_DIR=./data/ssl
mkdir -p "$CERT_DIR"

# Paths to the certificate and key files
CERT_FILE="$CERT_DIR/tls.crt"
KEY_FILE="$CERT_DIR/tls.key"


# Generate a self-signed SSL certificate only if it doesn't exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "Certificate or key file not found. Generating new SSL certificate and key."
  if [ -z "$CN" ] || [ -z "$CA" ] || [ -z "$CAkey" ]; then
    echo "Generating self-signed certificate..."
    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
      -keyout "$KEY_FILE" -out "$CERT_FILE" \
      -subj "/C=CN/ST=GD/L=SZ/O=localhost, Inc./CN=localhost" || {
        echo "Error: Failed to generate self-signed certificate."
        exit 1
      }
  else 
    echo "Generating CA-signed certificate..."
    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
      -keyout "$KEY_FILE" -out "$CERT_FILE" \
      -subj "/C=CN/ST=GD/L=SZ/O=$CN, Inc./CN=$CN" \
      -addext "subjectAltName=DNS:$CN" \
      -CA "$CA" -CAkey "$CAkey" || {
        echo "Error: Failed to generate CA-signed certificate."
        exit 1
      }
  fi
else
  echo "Existing SSL certificate and key found. Using them."
fi


# Execute the main binary and pass all script arguments
exec /bin/ssv-dkg "$@"

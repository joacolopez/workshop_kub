#!/bin/bash

# URL a comprobar
URL="http://localhost:8080"

# Ejecutar la prueba
echo "## Running test ##"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $RESPONSE -eq 200 ]; then
    echo "OK: Page response is 200."
else
    echo "FAILED: Page is either not returning 200 or not responding at all."
    exit 1
fi

#!/bin/bash


# Create server key & certificate signing request(.csr file)
# openssl genrsa -out ca.key
# openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -out ca.crt   -extfile ca.cnf

for i in kafka-1 kafka-2 kafka-3
do
	echo "------------------------------- $i -------------------------------"

    # Create server key & certificate signing request(.csr file)
    openssl req -new \
    -newkey rsa:2048 \
    -keyout $i.key \
    -out $i.csr \
    -config $i.cnf \
    -nodes


    # Sign server certificate with CA
    openssl x509 -req \
    -days 3650 \
    -in $i.csr \
    -CA ../ca.crt \
    -CAkey ../ca.key \
    -CAcreateserial \
    -out $i.crt \
    -extfile $i.cnf \
    -extensions v3_req

    # Convert server certificate to pkcs12 format
    openssl pkcs12 -export \
    -in $i.crt \
    -inkey $i.key \
    -chain \
    -CAfile ca.pem \
    -name $i \
    -out $i.p12 \
    -password pass:confluent

    # Create server keystore
    keytool -importkeystore \
    -deststorepass confluent \
    -destkeystore kafka.$i.keystore.pkcs12 \
    -srckeystore $i.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass confluent

    Save creds
    echo "confluent" > ${i}_sslkey_creds
    echo "confluent" > ${i}_keystore_creds

done

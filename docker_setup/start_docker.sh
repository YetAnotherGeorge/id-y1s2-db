#!/bin/bash

# Port 1522 ca sa nu se suprapuna cu db-ul de curs
docker run -d --name oracle-db-proiect -p 1522:1521 \
   --restart unless-stopped -e ORACLE_PASSWORD=parola123 \
   gvenzl/oracle-xe

# Conexiune 1:
#   ADDR: 10.19.49.10:1522 
#   USER: "SYS"
#   PAROLA: "parola123"
#   Service Name: "XE"
# 
# Conexiune 2:
#   ADDR: 10.19.49.10:1522 
#   USER: "proiect"
#   PAROLA: "parola123"
#   Service Name: "XE"
# 
#!/bin/bash

# Port 1522 ca sa nu se suprapuna cu db-ul de curs
docker run -d --name oracle-db-proiect -p 1522:1521 \
   --restart unless-stopped -e ORACLE_PASSWORD=parola123 \
   gvenzl/oracle-xe

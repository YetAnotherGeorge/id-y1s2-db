#!/bin/bash

docker run -d --name oracle-db-proiect -p 1521:1521 -e ORACLE_PASSWORD=parola123 gvenzl/oracle-xe
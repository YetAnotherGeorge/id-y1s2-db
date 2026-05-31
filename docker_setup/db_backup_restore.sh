#!/bin/bash

# Make backup
docker exec -it oracle-db-proiect expdp \"sys/parola123@//localhost:1521/XE as sysdba\" schemas=proiect directory=DATA_PUMP_DIR dumpfile=proiect_snapshot.dmp logfile=export.log
docker exec -it oracle-db-proiect rm /opt/oracle/admin/XE/dpdump/proiect_snapshot.dmp
docker cp oracle-db-proiect:/opt/oracle/admin/XE/dpdump/proiect_snapshot.dmp ./proiect_snapshot.dmp && gzip ./proiect_snapshot.dmp

# Restore backup
gunzip ./proiect_snapshot.dmp.gz;
docker cp ./proiect_snapshot.dmp oracle-db-proiect:/opt/oracle/admin/XE/dpdump/;
docker exec -it oracle-db-proiect impdp \"sys/parola123@//localhost:1521/XE as sysdba\" \
  schemas=proiect \
  directory=DATA_PUMP_DIR \
  dumpfile=proiect_snapshot.dmp \
  logfile=import.log \
  TABLE_EXISTS_ACTION=REPLACE;
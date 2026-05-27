/*
Cerinta 10: Crearea unei secvente utilizata la inserarea inregistrarilor.

Script dedicat pentru secventa globala folosita la PK-uri numerice in insert-uri manuale.
*/

-- Cleanup safe pentru rerulare
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE seq_global_id';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN -- sequence does not exist
         RAISE;
      END IF;
END;
/

CREATE SEQUENCE seq_global_id
   START WITH 20
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 999999999999
   NOCACHE 
   NOCYCLE;

-- Exemple de utilizare in INSERT (punctul 11):
INSERT INTO investitor (id_investitor, nume, prenume, email, data_inregistrare)
VALUES (seq_global_id.NEXTVAL, 'Vlad', 'Constantin', 'vlad.constantin.seq@example.com', TO_DATE('2026-01-01', 'YYYY-MM-DD'));

COMMIT;

-- Verificare 
SELECT seq_global_id.NEXTVAL AS seq_test_value FROM dual;

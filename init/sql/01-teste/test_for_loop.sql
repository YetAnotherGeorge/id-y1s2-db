
-- Drop table if exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE test_01 PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
      RAISE;
      END IF;
END;
/

CREATE TABLE test_01 (
   id NUMBER PRIMARY KEY,
   full_name VARCHAR2(100)
);

DELETE FROM test_01;
BEGIN 
   FOR i in 1..10 LOOP
      INSERT INTO test_01 (id, full_name) VALUES (i, 'Test User ' || TO_CHAR(i));
   END LOOP;
END;
/
COMMIT;

SELECT * FROM test_01;
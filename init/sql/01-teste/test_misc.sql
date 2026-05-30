BEGIN 
   EXECUTE IMMEDIATE 'DROP TABLE test_02 PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE test_02 (
   id NUMBER PRIMARY KEY,
   full_name VARCHAR2(100),
   salary NUMBER
);

DELETE FROM test_02;
-- fill with some dummy data
BEGIN 
   FOR i in 1..10 LOOP
      INSERT INTO test_02 (id, full_name, salary) VALUES (i, 'Test User ' || TO_CHAR(i), 3000 + i*500);
   END LOOP;
END;
/

SELECT full_name, salary * 3.1415 FROM test_02;
COMMIT;
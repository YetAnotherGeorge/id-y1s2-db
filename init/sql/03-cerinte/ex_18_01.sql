/*
18. Exemplificarea isolation levels prin exemple de tranzactii care se executa in paralel
in conditii de concurenta, evidentiind efectele diferitelor niveluri de izolare asupra
concurentei si integritatii datelor.

Rulare:
- Deschide 2 worksheet-uri SQL Developer in aceeasi schema: "Sesiunea A" si "Sesiunea B".
- Ruleaza sectiunile in ordinea indicata.
*/

-- Setup initial
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ex18_test_concurenta PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN -- ORA-00942: table or view does not exist
         RAISE;
      END IF;
END;
/

CREATE TABLE ex18_test_concurenta (
   id_demo NUMBER PRIMARY KEY,
   valoare NUMBER NOT NULL,
   descriere VARCHAR2(100)
);

INSERT INTO ex18_test_concurenta (id_demo, valoare, descriere) VALUES (1, 100, 'valoare initiala');
COMMIT;

-- Caz 1: READ COMMITTED (default); Efect: non-repeatable read
PROMPT 'Caz 1: READ COMMITTED (default)'
-- Sesiunea A (pasul 1)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT id_demo, valoare FROM ex18_test_concurenta WHERE id_demo = 1;
-- Rezultat asteptat: valoare = 100

-- Sesiunea A (pasul 3)
SELECT id_demo, valoare FROM ex18_test_concurenta WHERE id_demo = 1;
-- Rezultat asteptat: valoare = 150 (non-repeatable read)
COMMIT;


-- Caz 2: SERIALIZABLE; Efect: snapshot consistent + posibil ORA-08177 la update concurent
PROMPT 'Caz 2: SERIALIZABLE';
-- Reset stare (ruleaza o singura data, in orice sesiune)
UPDATE ex18_test_concurenta SET valoare = 100 WHERE id_demo = 1;
PROMPT 'Valoare resetata la 100 pentru id_demo = 1';
COMMIT;

-- Sesiunea A (pasul 1)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

PROMPT 'Sesiunea A: tranzactie SERIALIZABLE inceputa -> citeste valoarea (ar tb sa fie 100)';
SELECT id_demo, valoare FROM ex18_test_concurenta WHERE id_demo = 1;

-- Sesiunea A (pasul 3)
PROMPT 'SESIUNEA A: valoarea ar tb sa fie 200, dar datorita SERIALIZABLE, ramane 100 (snapshot) -> incercare update va esua';
SELECT id_demo, valoare FROM ex18_test_concurenta WHERE id_demo = 1;
-- Rezultat asteptat: valoare ramane 100 in aceeasi tranzactie (snapshot)

-- Sesiunea A (pasul 4)
UPDATE ex18_test_concurenta SET valoare = valoare + 10 WHERE id_demo = 1;
-- Rezultat posibil/asteptat: ORA-08177: can't serialize access for this transaction
ROLLBACK;


-- Caz 3: READ ONLY; Efect: consistenta maxima pentru citire, fara DML in tranzactia curenta

-- Sesiunea A (pasul 1)
SET TRANSACTION READ ONLY;
SELECT id_demo, valoare FROM ex18_test_concurenta WHERE id_demo = 1;

-- Sesiunea A (pasul 2)
UPDATE ex18_test_concurenta SET valoare = 999 WHERE id_demo = 1;
-- Rezultat asteptat: ORA-01456 (nu se permite DML in read-only transaction)
ROLLBACK;


/* Concluzii:
   - READ COMMITTED: concurenta mai buna, dar permite non-repeatable read.
   - SERIALIZABLE: integritate mai stricta, dar poate esua cu ORA-08177 la conflict.
   - READ ONLY: ideal pentru rapoarte consistente; interzice modificarile.
*/

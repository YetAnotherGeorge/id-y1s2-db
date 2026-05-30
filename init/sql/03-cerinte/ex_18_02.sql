-- Varianta 2 pentru a testa concurenta (rulat in paralel cu ex_18_01.sql)


-- Caz 1: READ COMMITTED (default); Efect: non-repeatable read
PROMPT 'Caz 1: READ COMMITTED (default)'

-- Sesiunea B (pasul 2)
UPDATE ex18_test_concurenta SET valoare = 150 WHERE id_demo = 1;
COMMIT;


-- Caz 2: SERIALIZABLE; Efect: snapshot consistent + posibil ORA-08177 la update concurent
PROMPT 'Caz 2: SERIALIZABLE';
-- Sesiunea B (pasul 2)
PROMPT 'Sesiunea B: incearca sa updateze valoarea la 200 + commit';
UPDATE ex18_test_concurenta SET valoare = 200 WHERE id_demo = 1;
COMMIT;
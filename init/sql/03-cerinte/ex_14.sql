/*
14. Crearea unei vizualizări complexe. Dați un exemplu de operație LMD permisă pe 
vizualizarea respectivă și un exemplu de operație LMD nepermisă.
*/

CREATE OR REPLACE VIEW v_ordine_vechi AS
SELECT o.id_ordin FROM ordin o
WHERE o.status_ordin IN ('NOU', 'PARTIAL')
AND o.data_ordin < DATE '2026-02-20'
AND NOT EXISTS (
   SELECT 1
   FROM executie_ordin eo
   WHERE eo.id_ordin = o.id_ordin
);

-- Operatie LMD permisa: stergere ordin vechi cu cantitatea cea mai mica
CREATE OR REPLACE VIEW v_ordin_cantitate_min AS
SELECT o.*
FROM ordin o
JOIN simbol_bursier sb ON o.ticker = sb.ticker
WHERE o.id_ordin IN (SELECT id_ordin FROM v_ordine_vechi)
AND o.cantitate = (
   SELECT MIN(o2.cantitate)
   FROM ordin o2
   WHERE o2.id_ordin IN (SELECT id_ordin FROM v_ordine_vechi)
);

-- SELECT * FROM v_ordin_cantitate_min;

-- Operatie LMD permisa
SAVEPOINT sp_ex14_delete;
DELETE FROM v_ordin_cantitate_min;
ROLLBACK TO sp_ex14_delete;

-- Operatie LMD nepermisa: insert rand care nu satisface conditiile din view (valori default null)
INSERT INTO v_ordin_cantitate_min (id_ordin) VALUES (1234);
/*
13. Implementarea a 3 operații de actualizare și de suprimare a datelor utilizând subcereri.
*/

-- Update ordine vechi in anulat
SELECT * FROM ordin o
WHERE o.status_ordin IN ('NOU', 'PARTIAL')
AND o.data_ordin < DATE '2026-02-20'
AND NOT EXISTS (
   SELECT 1
   FROM executie_ordin eo
   WHERE eo.id_ordin = o.id_ordin
);

-- Update itself
UPDATE ordin o
SET o.status_ordin = 'ANULAT'
WHERE o.status_ordin IN ('NOU', 'PARTIAL')
AND o.data_ordin < DATE '2026-02-20'
AND NOT EXISTS (
   SELECT 1
   FROM executie_ordin eo
   WHERE eo.id_ordin = o.id_ordin
);

-- Fara commit pe moment
-- COMMIT; 
ROLLBACK;
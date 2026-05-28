/*
15. Formulați în limbaj natural și implementați în SQL: 
   - a) o cerere ce utilizează operația outer-join pe minimum 4 tabele, 
   - b) o cerere ce utilizează operația division 
   - c) și o cerere care implementează analiza top-n.
   - Observație: Cele 3 cereri sunt diferite de cererile de la exercițiul 12.
*/

-- 15. a) Cerere ce utilizazea outer-join pe min 4 tabele
SELECT * 
FROM ordin o
LEFT JOIN simbol_bursier sb ON o.ticker = sb.ticker
LEFT JOIN companie c ON sb.id_companie = c.id_companie
LEFT JOIN portofoliu p ON o.id_portofoliu = p.id_portofoliu
LEFT JOIN investitor i ON p.id_investitor = i.id_investitor
WHERE o.ticker = 'NVDA';

SELECT *
FROM ordin o, simbol_bursier sb, companie c, portofoliu p, investitor i
WHERE o.ticker(+) = sb.ticker
AND sb.id_companie(+) = c.id_companie
AND o.id_portofoliu(+) = p.id_portofoliu
AND p.id_investitor(+) = i.id_investitor
AND o.ticker = 'NVDA';

-- 15. b) Cerere ce utilizeaza operatia division
-- Investitorii care au tranzactionat TOATE simbolurile din sectorul 'Tehnologie'
SELECT i.*
FROM investitor i
WHERE NOT EXISTS (
   SELECT 1
   FROM simbol_bursier sb
   WHERE sb.sector = 'Tehnologie'
   AND NOT EXISTS (
      SELECT 1
      FROM portofoliu p
      JOIN ordin o ON o.id_portofoliu = p.id_portofoliu
      WHERE p.id_investitor = i.id_investitor
      AND o.ticker = sb.ticker
   )
);

-- 15. c) Cerere care implementeaza analiza top-n
-- Top 2 investitori dupa numarul de ordine
SELECT i.id_investitor, i.nume, i.prenume, COUNT(o.id_ordin) AS nr_ordine
FROM investitor i
JOIN portofoliu p ON p.id_investitor = i.id_investitor
JOIN ordin o ON o.id_portofoliu = p.id_portofoliu
GROUP BY i.id_investitor, i.nume, i.prenume
ORDER BY nr_ordine DESC
FETCH FIRST 2 ROWS ONLY;